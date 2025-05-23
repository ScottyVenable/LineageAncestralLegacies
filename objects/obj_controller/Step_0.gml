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
if (!_shift_held && !_ctrl_held) {
    scr_camera_controller();
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
    var _current_formation_val = global.current_formation_type;
    var _formation_enum_first = Formation.NONE;
    var _formation_enum_last = Formation.CIRCLE; // <<<<< CORRECTED TO THE ACTUAL LAST ENUM VALUE

    var _wheel_up_type = mouse_wheel_up();
    var _wheel_down_type = mouse_wheel_down();

    if (_wheel_up_type) {
        _current_formation_val--;
        if (_current_formation_val < _formation_enum_first) { 
            _current_formation_val = _formation_enum_last; // Wrap to last
        }
        // Only update global and set changed flag if the value actually differs
        if (global.current_formation_type != _current_formation_val) {
            global.current_formation_type = _current_formation_val;
            _formation_changed_this_step = true;
        }
    } else if (_wheel_down_type) {
        _current_formation_val++;
        if (_current_formation_val > _formation_enum_last) { 
            _current_formation_val = _formation_enum_first; // Wrap to first
        }
        // Only update global and set changed flag if the value actually differs
        if (global.current_formation_type != _current_formation_val) {
            global.current_formation_type = _current_formation_val;
            _formation_changed_this_step = true;
        }
    }
}

// --- F-Key Debug Cycling ---
// Condition `!_shift_held && !_ctrl_held` ensures F-keys don't interfere with wheel actions
if (!_shift_held && !_ctrl_held) {
    if (keyboard_check_pressed(vk_f1) && global.current_formation_type != Formation.NONE) {
        global.current_formation_type = Formation.NONE; _formation_changed_this_step = true;
    } else if (keyboard_check_pressed(vk_f2) && global.current_formation_type != Formation.LINE_HORIZONTAL) {
        global.current_formation_type = Formation.LINE_HORIZONTAL; _formation_changed_this_step = true;
    } else if (keyboard_check_pressed(vk_f3) && global.current_formation_type != Formation.LINE_VERTICAL) {
        global.current_formation_type = Formation.LINE_VERTICAL; _formation_changed_this_step = true;
    } else if (keyboard_check_pressed(vk_f4) && global.current_formation_type != Formation.GRID) {
        global.current_formation_type = Formation.GRID; _formation_changed_this_step = true;
    } else if (keyboard_check_pressed(vk_f5) && global.current_formation_type != Formation.STAGGERED_LINE_HORIZONTAL) {
        global.current_formation_type = Formation.STAGGERED_LINE_HORIZONTAL; _formation_changed_this_step = true;
    } else if (keyboard_check_pressed(vk_f6) && global.current_formation_type != Formation.CIRCLE) {
        global.current_formation_type = Formation.CIRCLE; _formation_changed_this_step = true;
    }
}

// --- Trigger Formation Type Notification if Changed ---
if (_formation_changed_this_step) {
    var _formation_name_string = scr_formation_get_name(global.current_formation_type);
    scr_trigger_formation_notification("Formation: " + _formation_name_string);
    show_debug_message("Formation Type set to: " + _formation_name_string);
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
// This region handles updating the Inspector Panel UI based on the currently selected pop.
// It ensures that if a pop's details change, the UI reflects this.
// It also handles clearing the UI when no pop is selected, but only when the selection state *changes* to noone.

// Get the script ID for scr_selection_controller once to avoid repeated calls to asset_get_index.
var _selection_script = asset_get_index("scr_selection_controller");

// --- Update UI if a pop is selected ---
// This block executes if global.selected_pop refers to a valid instance.
if (global.selected_pop != noone && global.selected_pop != undefined) {
    // A pop is currently selected.
    if (script_exists(_selection_script)) {
        // Call the selection controller script to update the UI elements with the selected pop's data.
        // This script is responsible for fetching details like name, age, status, etc.
        script_execute(_selection_script, global.selected_pop);
    } else {
        // If scr_selection_controller is missing, log an error.
        // The global.logged_missing_selection_script flag prevents spamming the console with this error.
        if (!global.logged_missing_selection_script) {
            show_debug_message("ERROR: scr_selection_controller not found. Pop details UI will not update.");
            global.logged_missing_selection_script = true; // Set flag to true after logging once.
        }
    }
    // Store the ID of the currently selected pop in our instance variable _last_known_selected_pop.
    // This helps us detect when the selection changes from this pop to 'noone' in a future step.
    _last_known_selected_pop = global.selected_pop;
}
// --- Handle UI when no pop is selected (or selection is cleared) ---
// This block executes if global.selected_pop is 'noone' or 'undefined'.
else {
    // We only want to tell the UI to clear itself (by calling scr_selection_controller with 'noone')
    // IF a pop WAS selected in the previous step (_last_known_selected_pop is a valid ID)
    // AND NOW no pop is selected (current global.selected_pop is 'noone').
    // This prevents calling the script every single step when nothing is selected, which was causing the log spam.
    if (_last_known_selected_pop != noone && _last_known_selected_pop != undefined) {
        // This condition means a pop *was* selected, but now it's not. The selection has just been cleared.
        if (script_exists(_selection_script)) {
            // Call the selection controller script with 'noone'.
            // This tells the script to reset or clear the UI fields in the Inspector panel.
            script_execute(_selection_script, noone);
        }
        // After clearing the UI, update _last_known_selected_pop to 'noone'.
        // This is crucial! It ensures that in the next step (if no pop is still selected),
        // this block won't execute again, thus preventing the repeated calls.
        _last_known_selected_pop = noone; // Reflect that the UI has been reset for 'no selection'.
    }
    // If _last_known_selected_pop was already 'noone', it means either:
    // 1. No pop was selected in the previous step either.
    // 2. The UI was already cleared in a previous step when the selection changed from a pop to 'noone'.
    // In either of these cases, no action is needed here, avoiding redundant calls to scr_selection_controller.
}
// Reminder: The instance variable `_last_known_selected_pop` must be initialized in obj_controller's Create event.
// Example: _last_known_selected_pop = noone;
// Also, ensure `global.logged_missing_selection_script` is initialized (e.g., to `false`) in the Create event.
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
