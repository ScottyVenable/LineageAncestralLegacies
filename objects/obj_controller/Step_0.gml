/// obj_controller – Step Event
///
/// Purpose:
///    Handles camera control, player input for formation selection (Shift+MouseWheel & F-Keys),
///    formation spacing adjustment (Ctrl+MouseWheel), and manages the display
///    timing and fade effect for formation change notifications.
///
/// Metadata:
///    Version:         1.7 - [Current Date] (Corrected _formation_enum_last for mouse wheel cycling)
///    Dependencies:  scr_camera_controller, Formation (enum), global variables for formation & notification,
///                     scr_trigger_formation_notification, scr_formations (scr_formation_get_name),
///                     keyboard_check, mouse_wheel_up/down

// ============================================================================
// 0. INPUT STATES & EARLY CHECKS
// ============================================================================
#region 0.1 Input States
var _shift_held = keyboard_check(vk_shift);
var _ctrl_held  = keyboard_check(vk_control);
#endregion

// ============================================================================
// 1. CAMERA CONTROL (Conditional based on Shift or Ctrl key)
// ============================================================================
#region 1.1 Camera Controller
// The call to scr_camera_controller(); is removed.
// Camera logic is now handled by the obj_camera_controller instance in its own Step Event.
if (!_shift_held && !_ctrl_held) {
    // If you need obj_controller to tell obj_camera_controller to do something specific
    // (e.g., enable/disable controls), you would do it here, e.g.:
    // if (instance_exists(obj_camera_controller)) {
    //     obj_camera_controller.can_control = true; // Assuming obj_camera_controller has such a variable
    // }
} else {
    // if (instance_exists(obj_camera_controller)) {
    //     obj_camera_controller.can_control = false;
    // }
}
#endregion

// ============================================================================
// 2. FORMATION & SPACING CONTROL
// ============================================================================
#region 2.1 Formation Control Input & Spacing Adjustment
var _formation_changed_this_step = false;
var _spacing_changed_this_step = false;

// --- Ctrl + Mouse Wheel for Formation Spacing ---
if (_ctrl_held) {
    var _wheel_up_spacing = mouse_wheel_up();
    var _wheel_down_spacing = mouse_wheel_down();
    var _spacing_increment = 4; 
    var _min_spacing = 16;     
    var _max_spacing = 128;    

    if (_wheel_up_spacing) {
        global.formation_spacing += _spacing_increment; _spacing_changed_this_step = true;
    } else if (_wheel_down_spacing) {
        global.formation_spacing -= _spacing_increment; _spacing_changed_this_step = true;
    }

    if (_spacing_changed_this_step) {
        global.formation_spacing = clamp(global.formation_spacing, _min_spacing, _max_spacing);
        show_debug_message("Formation Spacing set to: " + string(global.formation_spacing));
        // scr_trigger_formation_notification("Spacing: " + string(global.formation_spacing)); 
    }
}
// --- Shift + Mouse Wheel Cycling for Formation Type ---
else if (_shift_held) { 
    // Block zoom logic when changing formation type
    global.block_zoom_this_frame = true; // Set a flag for your zoom code to check

    var _current_formation_val = global.current_formation_type;
    var _formation_enum_first = FormationType.NONE;
    var _formation_enum_last = FormationType.CIRCLE; // <<<<< CORRECTED: Use FormationType for enum consistency

    var _wheel_up_type = mouse_wheel_up();
    var _wheel_down_type = mouse_wheel_down();

    if (_wheel_up_type) {
        _current_formation_val--;
        if (_current_formation_val < _formation_enum_first) { 
            _current_formation_val = _formation_enum_last; // Wrap to last
        }
        global.current_formation_type = _current_formation_val;
        _formation_changed_this_step = true;
    } else if (_wheel_down_type) {
        _current_formation_val++;
        if (_current_formation_val > _formation_enum_last) { 
            _current_formation_val = _formation_enum_first; // Wrap to first
        }
        global.current_formation_type = _current_formation_val;
        _formation_changed_this_step = true;
    }
}

// --- F-Key Debug Cycling ---
// Condition `!_shift_held && !_ctrl_held` ensures F-keys don't interfere with wheel actions
if (!_shift_held && !_ctrl_held) {
    if (keyboard_check_pressed(vk_f1) && global.current_formation_type != FormationType.NONE) {
        global.current_formation_type = FormationType.NONE; _formation_changed_this_step = true;
    } else if (keyboard_check_pressed(vk_f2) && global.current_formation_type != FormationType.LINE_HORIZONTAL) {
        global.current_formation_type = FormationType.LINE_HORIZONTAL; _formation_changed_this_step = true;
    } else if (keyboard_check_pressed(vk_f3) && global.current_formation_type != FormationType.LINE_VERTICAL) {
        global.current_formation_type = FormationType.LINE_VERTICAL; _formation_changed_this_step = true;
    } else if (keyboard_check_pressed(vk_f4) && global.current_formation_type != FormationType.GRID) {
        global.current_formation_type = FormationType.GRID; _formation_changed_this_step = true;
    } else if (keyboard_check_pressed(vk_f5) && global.current_formation_type != FormationType.STAGGERED_LINE_HORIZONTAL) {
        global.current_formation_type = FormationType.STAGGERED_LINE_HORIZONTAL; _formation_changed_this_step = true;
    } else if (keyboard_check_pressed(vk_f6) && global.current_formation_type != FormationType.CIRCLE) {
        global.current_formation_type = FormationType.CIRCLE; _formation_changed_this_step = true;
    }
}

// --- Trigger Formation Type Notification if Changed ---
if (_formation_changed_this_step) {
    var _formation_name_string = "Formation: " + scr_formation_get_name(global.current_formation_type);
    scr_trigger_formation_notification(_formation_name_string);
    show_debug_message("Formation changed to: " + _formation_name_string);
}
#endregion

#region 2.2 Update Formation Notification Display Timer & Alpha
if (global.formation_notification_alpha > 0) {
    global.formation_notification_timer++;
    if (global.formation_notification_timer > global.formation_notification_stay_time) {
        var _time_into_fade = global.formation_notification_timer - global.formation_notification_stay_time;
        var _fade_progress_percent = _time_into_fade / global.formation_notification_fade_time;
        global.formation_notification_alpha = 1.0 - clamp(_fade_progress_percent, 0, 1.0);
    }
    if (global.formation_notification_alpha <= 0) {
        global.formation_notification_text = "";
        global.formation_notification_alpha = 0;
    }
}
#endregion

// ============================================================================
// 3. POPULATION & LINEAGE CHECKS
// ============================================================================
#region 3.1 Update Status Bar Info

if (is_struct(global.ui_text_elements)) {
    if (struct_exists(global.ui_text_elements, "food") && layer_exists(text_layer_id)){ //&& layer_has_instance("UI", global.ui_text_elements.food) ) {
        layer_text_text(global.ui_text_elements.food, global.lineage_food_stock)
		
	}
	if (struct_exists(global.ui_text_elements, "wood") && layer_exists(text_layer_id) && layer_has_instance("UI", global.ui_text_elements.wood) ) {
    layer_text_text(global.ui_text_elements.wood, string(global.lineage_wood_stock));
	}
	if (struct_exists(global.ui_text_elements, "stone") && layer_exists(text_layer_id) && layer_has_instance("UI", global.ui_text_elements.stone) ) {
    layer_text_text(global.ui_text_elements.stone, string(global.lineage_stone_stock));
	}
	if (struct_exists(global.ui_text_elements, "metal") && layer_exists(text_layer_id) && layer_has_instance("UI", global.ui_text_elements.metal) ) {
    layer_text_text(global.ui_text_elements.metal, string(global.lineage_metal_stock));
	}
}
#endregion

// ============================================================================
// 4. SELECTED POP UI UPDATE (Inspector Panel)
// ============================================================================
#region 4.1 Continuously Update Selected Pop Details
// If a pop is selected, refresh its details in the UI every step.
// This ensures that if a pop's displayed attributes (e.g., age, status) change,
// the Inspector panel reflects this immediately.
if (global.selected_pop != noone && global.selected_pop != undefined) {
    // Check if the scr_selection_controller script exists to prevent errors
    var _selection_script = asset_get_index("scr_selection_controller");
    if (script_exists(_selection_script)) {
        // Call the script to update the UI elements with the selected pop's data.
        // scr_selection_controller handles fetching name, sex, age, etc., and updating text elements.
        script_execute(_selection_script, global.selected_pop);
    } else {
        // Log an error if the script is missing, which would be a critical issue.
        if (!global.logged_missing_selection_script) { // Log only once to avoid spam
            show_debug_message("ERROR: scr_selection_controller not found. Pop details UI will not update.");
            global.logged_missing_selection_script = true; // Set flag to prevent repeated logging
        }
    }
} else {
    // If no pop is selected, or selection is invalid, ensure the UI is cleared (or set to "N/A")
    // This is typically handled by scr_selection_controller when passed 'noone' or an invalid ID,
    // but we can explicitly call it here if needed, or ensure Create event sets initial "N/A" state.
    // For now, we assume scr_selection_controller handles the 'noone' case correctly to clear/reset UI fields.
    // If global.selected_pop was just cleared, scr_selection_controller would have been called with 'noone' already.
    // This continuous call ensures that if it becomes 'noone' for other reasons, UI is also reset.
    var _selection_script = asset_get_index("scr_selection_controller");
    if (script_exists(_selection_script)) {
        // Call with 'noone' to ensure UI fields are reset if no pop is selected.
        script_execute(_selection_script, noone);
    }
}
// Initialize the logging flag in the Create event of obj_controller if it's not already there.
// (This comment is a reminder for where global.logged_missing_selection_script should be initialized)
#endregion

// ==========================================================================
// X. INPUT HANDLING (Example Section - Add to your Step Event structure)
// ==========================================================================
#region X.1 Overlay Toggle
// Overlay toggle: Press Ctrl+S to show/hide overlays for sight lines and radii
if (keyboard_check(vk_control) && keyboard_check_pressed(ord("S"))) {
    // Initialize global.show_overlays if it doesn't exist
    if (!variable_global_exists("show_overlays")) {
        global.show_overlays = false;
    }
    global.show_overlays = !global.show_overlays;
    debug_log($"Toggled overlays to: {global.show_overlays}", "OverlayToggle", "yellow");
}
#endregion
