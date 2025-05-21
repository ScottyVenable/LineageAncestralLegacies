/// obj_controller – Event Global Left Released
///
/// Purpose:
///    Handles global left-click release. Finalizes drag selection or performs single pop selection.
///    Updates selection states and the global selected pops list. Enhanced debugging.
///
/// Metadata:
///    Summary:        Finalizes selection (drag or single) and updates UI.
///    Usage:          obj_controller Event: Mouse > Global Mouse > Global Left Released
///    Tags:           [input][selection][drag_selection][ui_update][debug]
///    Version:        1.1 — 2024-05-19 // Scotty's Current Date - Enhanced debugging for click_start_world_x
///    Dependencies:   device_mouse_x_to_gui(), device_mouse_y_to_gui(), obj_pop,
///                    global.selected_pops_list, scr_selection_controller()

show_debug_message("========================================================");
show_debug_message("DEBUG GLR: Entered Global Left Released. self is: " + object_get_name(object_index) + " (ID: " + string(id) + ")");
if (variable_instance_exists(id, "click_start_world_x")) {
    show_debug_message($"DEBUG GLR: Initial click_start_world_x: {click_start_world_x}, exists: true");
} else {
    show_debug_message("DEBUG GLR: Initial click_start_world_x: UNDEFINED, exists: false");
}


// =========================================================================
// 0. IMPORTS & CACHES
// =========================================================================
#region 0.1 Imports & Cached Locals
var _gui_mx = device_mouse_x_to_gui(0);
var _gui_my = device_mouse_y_to_gui(0);
var _world_mx = mouse_x; 
var _world_my = mouse_y; 

var _drag_threshold = 5; 
#endregion

// =========================================================================
// 1. PREPARE FOR NEW SELECTION: DESELECT PREVIOUSLY SELECTED POPS
// =========================================================================
#region 1.1 Deselect All
show_debug_message("DEBUG GLR: Region 1.1 Before 'with (obj_pop)'. self is: " + object_get_name(object_index));
if (variable_instance_exists(id, "click_start_world_x")) { show_debug_message($"DEBUG GLR: Region 1.1 click_start_world_x: {click_start_world_x}"); }

if (ds_exists(global.selected_pops_list, ds_type_list)) {
    ds_list_clear(global.selected_pops_list);
}

if (instance_exists(obj_pop)) {
    with (obj_pop) {
        selected = false;
    }
} else {
    show_debug_message("DEBUG GLR: Region 1.1 No obj_pop instances found to deselect.");
}

show_debug_message("DEBUG GLR: Region 1.1 After 'with (obj_pop)'. self is: " + object_get_name(object_index));
if (variable_instance_exists(id, "click_start_world_x")) { show_debug_message($"DEBUG GLR: Region 1.1 click_start_world_x: {click_start_world_x}"); }
selected_pop = noone; 
#endregion

// =========================================================================
// 2. PROCESS SELECTION (DRAG OR CLICK)
// =========================================================================
#region 2.1 Drag Selection Logic
show_debug_message("DEBUG GLR: Region 2.1 Before 'if (is_dragging)'. self is: " + object_get_name(object_index));
if (variable_instance_exists(id, "click_start_world_x")) { show_debug_message($"DEBUG GLR: Region 2.1 click_start_world_x: {click_start_world_x}"); }

if (is_dragging) { // This instance variable 'is_dragging' was set in GLP
    is_dragging = false; // Stop dragging state now

    var _drag_dist_x = abs(_gui_mx - sel_start_x); // sel_start_x is instance var of obj_controller
    var _drag_dist_y = abs(_gui_my - sel_start_y); // sel_start_y is instance var of obj_controller

    show_debug_message("DEBUG GLR: Region 2.1 Inside 'if (is_dragging)'. self is: " + object_get_name(object_index));
    if (variable_instance_exists(id, "click_start_world_x")) { show_debug_message($"DEBUG GLR: Region 2.1 click_start_world_x: {click_start_world_x}"); }
    
    if (_drag_dist_x > _drag_threshold || _drag_dist_y > _drag_threshold) {
        // --- It was a DRAG BOX selection ---
        show_debug_message("DEBUG GLR: Region 2.1 Processing Drag Box. self is: " + object_get_name(object_index));
        if (variable_instance_exists(id, "click_start_world_x")) {
            show_debug_message($"DEBUG GLR: Region 2.1 click_start_world_x BEFORE min/max: {click_start_world_x}");
            
            var _tmp_click_start_world_x = click_start_world_x; // Try caching it to a local var RIGHT BEFORE USE
            var _tmp_click_start_world_y = click_start_world_y; // Cache Y as well for consistency
            show_debug_message($"DEBUG GLR: Region 2.1 Cached _tmp_click_start_world_x = {_tmp_click_start_world_x}");

            var _world_sel_x1 = min(_tmp_click_start_world_x, _world_mx); // USE THE TEMP VAR
            var _world_sel_y1 = min(_tmp_click_start_world_y, _world_my); 
            var _world_sel_x2 = max(_tmp_click_start_world_x, _world_mx); // USE THE TEMP VAR
            var _world_sel_y2 = max(_tmp_click_start_world_y, _world_my);
            
            show_debug_message($"DEBUG GLR: Region 2.1 Drag box world coords: ({_world_sel_x1},{_world_sel_y1}) to ({_world_sel_x2},{_world_sel_y2})");

            with (obj_pop) {
                if (point_in_rectangle(x, y, _world_sel_x1, _world_sel_y1, _world_sel_x2, _world_sel_y2)) {
                    selected = true;
                    ds_list_add(global.selected_pops_list, id);
                }
            }
        } else {
            show_debug_message("CRITICAL DEBUG GLR: Region 2.1 click_start_world_x NOT DEFINED just before drag box min/max calculations!");
            // This case should ideally not be reached if Create and GLP are working
        }
    } else {
        // --- It was a CLICK (drag distance was too small) ---
        show_debug_message("DEBUG GLR: Region 2.1 Processing as Single Click (short drag). self is: " + object_get_name(object_index));
        if (variable_instance_exists(id, "click_start_world_x")) {
            show_debug_message($"DEBUG GLR: Region 2.1 click_start_world_x for single click: {click_start_world_x}");
            var _clicked_pop = instance_position(click_start_world_x, click_start_world_y, obj_pop);
            if (instance_exists(_clicked_pop)) {
                _clicked_pop.selected = true;
                ds_list_add(global.selected_pops_list, _clicked_pop.id);
                selected_pop = _clicked_pop.id; 
            }
        } else {
            show_debug_message("CRITICAL DEBUG GLR: Region 2.1 click_start_world_x NOT DEFINED for single click check!");
        }
    }
} else {
    show_debug_message("DEBUG GLR: Region 2.1 'is_dragging' was false. No selection processing.");
}
#endregion

// =========================================================================
// 3. UPDATE UI / SELECTION CONTROLLER
// =========================================================================

if (ds_exists(global.selected_pops_list, ds_type_list)) {
    show_debug_message($"DEBUG GLR: Selection finalized. {ds_list_size(global.selected_pops_list)} pops selected.");
}
show_debug_message("========================================================");