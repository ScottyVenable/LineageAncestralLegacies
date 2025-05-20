/// obj_controller – Event Global Left Released
///
/// Purpose:
///    Handles global left-click mouse release. Finalizes drag selection
///    or processes a single click selection.
///
/// Metadata:
///    Summary:        Finalizes selection (drag or click).
///    Usage:          obj_controller Event: Mouse > Global Mouse > Global Left Released
///    Parameters:     none
///    Returns:        void
///    Tags:           [input][selection][drag_selection]
///    Version:        1.0
///    Dependencies:   device_mouse_x_to_gui(), device_mouse_y_to_gui(), scr_selection_controller(),
///                     instance_position(), obj_pop

// =========================================================================
// 0. IMPORTS & CACHES
// =========================================================================
#region 0.1 Imports & Cached Locals
var _gui_mx = device_mouse_x_to_gui(0);
var _gui_my = device_mouse_y_to_gui(0);
#endregion

// =========================================================================
// 1. FINALIZE DRAG STATE
// =========================================================================
#region 1.1 End Drag
var _was_dragging = is_dragging; // Store if we were actually dragging
is_dragging = false;
show_debug_message($"DEBUG (obj_controller GLR): is_dragging set to false.");
#endregion

// =========================================================================
// 2. PROCESS SELECTION
// =========================================================================
#region 2.1 Deselect All Pops (Standard practice before applying new selection)
with (obj_pop) {
    selected = false;
}
// Clear the single selected pop in the controller.
// This will be re-populated if a single pop is selected by the click/drag.
selected_pop = noone;
#endregion

#region 2.2 Define Selection Area
// Coordinates for the selection rectangle
var _sel_x1 = min(sel_start_x, _gui_mx);
var _sel_y1 = min(sel_start_y, _gui_my);
var _sel_x2 = max(sel_start_x, _gui_mx);
var _sel_y2 = max(sel_start_y, _gui_my);

// Define a small threshold to differentiate a click from a drag
var _drag_threshold = 5; // If mouse moved less than 5 pixels, consider it a click
var _is_click = (abs(sel_start_x - _gui_mx) < _drag_threshold && abs(sel_start_y - _gui_my) < _drag_threshold);
#endregion

#region 2.3 Perform Selection
var _newly_selected_pop_id = noone;
var _selected_count = 0;

if (_is_click && _was_dragging) { // Process as a single click
    show_debug_message("DEBUG (obj_controller GLR): Processing as CLICK.");
    // Convert GUI mouse coordinates to room coordinates for instance_position
    // Note: This assumes your pops are NOT drawn in the GUI layer for selection.
    // If pops are in room space, you need to convert GUI click to room click.
    // The camera script shows you have cam_x, cam_y, and zoom_level.
    var _click_room_x = camera_get_view_x(view_camera[0]) + (_gui_mx / camera_get_view_width(view_camera[0])) * room_width;
    var _click_room_y = camera_get_view_y(view_camera[0]) + (_gui_my / camera_get_view_height(view_camera[0])) * room_height;
    
    // Simpler conversion using your existing variables:
    // This needs the current camera view properties
    var _cam_current_x = camera_get_view_x(view_camera[0]);
    var _cam_current_y = camera_get_view_y(view_camera[0]);
    var _view_w_on_gui = display_get_gui_width(); // This might not be what you want if letterboxed
    var _view_h_on_gui = display_get_gui_height();

    // Correct conversion from GUI to World space:
    // This assumes your GUI overlay matches your view port aspect ratio,
    // and zoom_level is the world space zoom factor of the camera.
    // Get current camera properties
    var current_cam = view_camera[0];
    var cam_view_x = camera_get_view_x(current_cam);
    var cam_view_y = camera_get_view_y(current_cam);
    var cam_view_w = camera_get_view_width(current_cam);
    var cam_view_h = camera_get_view_height(current_cam);
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    // Map GUI coordinates to view coordinates (0 to 1 range within the view)
    var _vx = _gui_mx / gui_w;
    var _vy = _gui_my / gui_h;

    // Map view coordinates to world coordinates
    _click_room_x = cam_view_x + (_vx * cam_view_w);
    _click_room_y = cam_view_y + (_vy * cam_view_h);

    var _clicked_instance = instance_position(_click_room_x, _click_room_y, obj_pop);
    if (instance_exists(_clicked_instance)) {
        _clicked_instance.selected = true;
        _newly_selected_pop_id = _clicked_instance.id;
        _selected_count = 1;
        show_debug_message($"DEBUG (obj_controller GLR): Click selected Pop ID: {_newly_selected_pop_id} at world ({_click_room_x},{_click_room_y}) from gui ({_gui_mx},{_gui_my})");
    } else {
        show_debug_message($"DEBUG (obj_controller GLR): Click at world ({_click_room_x},{_click_room_y}) found no pop.");
    }

} else if (_was_dragging) { // Process as a drag box selection
    show_debug_message($"DEBUG (obj_controller GLR): Processing as DRAG BOX: ({_sel_x1},{_sel_y1}) to ({_sel_x2},{_sel_y2}) in GUI space.");
    var _first_selected_in_box = noone; // To handle single selection for panel

    with (obj_pop) {
        // For pops in room space, we need to check their GUI bounding box against the selection box.
        // This is more complex as you need to project pop's room AABB to GUI space.

        // Simpler: iterate all pops and check if their *center* (converted to GUI) is in the box.
        // Or, convert the GUI selection box back to world coordinates and use collision_rectangle.
        // Let's try converting selection box to world space, as it's more robust.

        var current_cam = view_camera[0];
        var cam_view_x = camera_get_view_x(current_cam);
        var cam_view_y = camera_get_view_y(current_cam);
        var cam_view_w = camera_get_view_width(current_cam);
        var cam_view_h = camera_get_view_height(current_cam);
        var gui_w = display_get_gui_width();
        var gui_h = display_get_gui_height();

        // Convert GUI selection box corners to world coordinates
        var _world_sel_x1 = cam_view_x + ((_sel_x1 / gui_w) * cam_view_w);
        var _world_sel_y1 = cam_view_y + ((_sel_y1 / gui_h) * cam_view_h);
        var _world_sel_x2 = cam_view_x + ((_sel_x2 / gui_w) * cam_view_w);
        var _world_sel_y2 = cam_view_y + ((_sel_y2 / gui_h) * cam_view_h);
        
        // Ensure correct ordering for collision_rectangle
        var _rect_left   = min(_world_sel_x1, _world_sel_x2);
        var _rect_top    = min(_world_sel_y1, _world_sel_y2);
        var _rect_right  = max(_world_sel_x1, _world_sel_x2);
        var _rect_bottom = max(_world_sel_y1, _world_sel_y2);

        // Check if this pop's bounding box intersects the world-space selection rectangle
        // Using the pop's own bounding box (bbox_left, etc.)
        if (rectangle_in_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom,
                                   _rect_left, _rect_top, _rect_right, _rect_bottom) > 0) // 0=no, 1=part, 2=full
        {
            selected = true;
            if (_first_selected_in_box == noone) {
                _first_selected_in_box = id;
            }
            _selected_count++;
            show_debug_message($"DEBUG (obj_controller GLR): Pop ID {id} selected by drag box.");
        }
    }
    if (_selected_count == 1 && _first_selected_in_box != noone) {
        _newly_selected_pop_id = _first_selected_in_box;
    }
     show_debug_message($"DEBUG (obj_controller GLR): Drag box selected {_selected_count} pops. First selected was {_first_selected_in_box}");
}
#endregion

#region 2.4 Update Controller's Selected Pop, UI, and Pop Selection Flags
// First, clear is_solely_selected for all pops
with (obj_pop) {
    is_solely_selected = false;
}

if (_selected_count == 1 && _newly_selected_pop_id != noone) {
    selected_pop = _newly_selected_pop_id; // Controller tracks the single selected pop
    if (instance_exists(selected_pop)) {
        selected_pop.is_solely_selected = true; // Set flag for the one pop
    }
    scr_selection_controller(_newly_selected_pop_id); // Update UI panel
} else if (_selected_count > 1) {
    selected_pop = noone; // No single pop is "the" selected_pop for the controller
    // is_solely_selected remains false for all pops
    scr_selection_controller(noone);
} else { // No pops selected
    selected_pop = noone;
    scr_selection_controller(noone);
}
#endregion