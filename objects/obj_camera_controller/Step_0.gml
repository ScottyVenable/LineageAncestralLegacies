//
/// @description Handles smooth camera zoom (centered on mouse) and middle-mouse drag.
// Logic moved from scr_camera_controller.

// =========================================================================
//    0. INITIALIZATION & SETUP (Local to Step)
// =========================================================================
#region Initialization & Setup

// 0.1. Imports & Cached Locals
var _cam    = view_camera[0]; // Get the camera ID for view 0
var _rw     = room_width;
var _rh     = room_height;
var _gui_mx = device_mouse_x_to_gui(0); // Mouse X in GUI coordinates
var _gui_my = device_mouse_y_to_gui(0); // Mouse Y in GUI coordinates

// Instance variables (zoom_level, cam_x, etc.) are directly accessible as they are part of this object.

#endregion // Initialization & Setup

// =========================================================================
//    1. PRE-CONDITION CHECKS & VALIDATION
// =========================================================================
#region Pre-condition Checks & Validation

// 1.1. Camera Validation
if (!is_real(_cam) || _cam < 0) {
    show_debug_message($"ERROR (obj_camera_controller): Camera ID from view_camera[0] is invalid or 'noone' (Value: {_cam}). Cannot proceed.");
    exit; // Stop further execution of this event if camera is not valid.
}

#endregion // Pre-condition Checks & Validation

// =========================================================================
//    2. CONFIGURATION & CONSTANTS (IF ANY) - Handled by instance vars
// =========================================================================

// =========================================================================
//    3. CORE LOGIC
// =========================================================================
#region Core Logic

/* Optional: Re-centering logic if obj_controller requests it
if (re_center_on_target) {
    var _current_view_width = _rw / zoom_level;
    var _current_view_height = _rh / zoom_level;
    cam_x = target_center_x - (_current_view_width / 2);
    cam_y = target_center_y - (_current_view_height / 2);
    re_center_on_target = false; // Reset flag
    show_debug_message($"DEBUG (obj_camera_controller): Re-centered on target: ({target_center_x},{target_center_y}). New cam_x,cam_y: ({cam_x},{cam_y})");
}
*/

// 3.1. Pre-Zoom: Record World Coordinates Under Mouse
var _world_mx_before_zoom = cam_x + (_gui_mx / zoom_level);
var _world_my_before_zoom = cam_y + (_gui_my / zoom_level);

// 3.2. Zoom Input
if (mouse_wheel_up()) {
    zoom_target = clamp(zoom_target + zoom_speed, zoom_min, zoom_max);
    show_debug_message($"DEBUG (obj_camera_controller): Mouse Wheel Up. Zoom Target: {zoom_target}");
}
if (mouse_wheel_down()) {
    zoom_target = clamp(zoom_target - zoom_speed, zoom_min, zoom_max);
    show_debug_message($"DEBUG (obj_camera_controller): Mouse Wheel Down. Zoom Target: {zoom_target}");
}

// 3.3. Smooth Zoom Interpolation
if (abs(zoom_target - zoom_level) > 0.001) { // Check if a significant change is needed
    zoom_level += (zoom_target - zoom_level) * zoom_smooth;
} else {
    zoom_level = zoom_target; // Snap to target if very close
}

// 3.4. Recalculate Camera Position for Centered Zoom
cam_x = _world_mx_before_zoom - (_gui_mx / zoom_level);
cam_y = _world_my_before_zoom - (_gui_my / zoom_level);

// 3.5. Middle-Mouse Drag for Camera Panning
if (mouse_check_button_pressed(mb_middle)) {
    dragging_camera = true;
    drag_start_x    = _gui_mx; // Store initial mouse position for drag calculation
    drag_start_y    = _gui_my;
    show_debug_message($"DEBUG (obj_camera_controller): Middle Mouse Pressed. Dragging: {dragging_camera}. Start: ({drag_start_x},{drag_start_y})");
}
if (mouse_check_button_released(mb_middle)) {
    dragging_camera = false;
    show_debug_message($"DEBUG (obj_camera_controller): Middle Mouse Released. Dragging: {dragging_camera}");
}

if (dragging_camera) {
    var _delta_gui_mx = _gui_mx - drag_start_x; // Change in mouse X since last frame
    var _delta_gui_my = _gui_my - drag_start_y; // Change in mouse Y since last frame

    // Adjust camera position based on mouse movement, scaled by zoom level.
    cam_x -= _delta_gui_mx / zoom_level;
    cam_y -= _delta_gui_my / zoom_level;
    show_debug_message($"DEBUG (obj_camera_controller): Dragging. Delta: ({_delta_gui_mx},{_delta_gui_my}). New Cam Pos: ({cam_x},{cam_y})");

    // Update drag_start positions for the next frame's calculation.
    drag_start_x = _gui_mx;
    drag_start_y = _gui_my;
}

// 3.6. Apply Calculated Position and Size to Camera
var _view_width_actual  = _rw / zoom_level;
var _view_height_actual = _rh / zoom_level;

camera_set_view_pos(_cam, cam_x, cam_y);
camera_set_view_size(_cam, _view_width_actual, _view_height_actual);

#endregion // Core Logic

// =========================================================================
//    4. CLEANUP & RETURN VALUE (Not applicable for direct event code)
// =========================================================================