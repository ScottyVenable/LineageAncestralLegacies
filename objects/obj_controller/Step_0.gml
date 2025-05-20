/// obj_controller – Step Event
///
/// Purpose:
///    Handles continuous updates for camera control, player input for formation
///    selection (Shift+MouseWheel and debug F-keys), and manages the display
///    timing and fade effect for formation change notifications.
///
/// Metadata:
///    Summary:         Updates camera, handles formation input, manages notification UI.
///    Usage:           obj_controller Step Event.
///    Parameters:    none
///    Returns:         void
///    Tags:            [controller][update][camera][input][debug][formation][notification][ui_logic]
///    Version:         1.3 - [Current Date] (Integrated Shift+MouseWheel formation cycle & notification system)
///    Dependencies:  scr_camera_controller, Formation (enum), global variables for formation and notification,
///                     scr_trigger_formation_notification, scr_get_formation_name, keyboard_check, mouse_wheel_up/down

// ============================================================================
// 0. INPUT STATES & EARLY CHECKS
// ============================================================================
#region 0.1 Input States
var _shift_held = keyboard_check(vk_shift); // True if either Shift key is held down
#endregion

// ============================================================================
// 1. CAMERA CONTROL (Conditional based on Shift key)
// ============================================================================
#region 1.1 Camera Controller
if (!_shift_held) {
    // Only allow camera zoom/pan from scr_camera_controller if Shift is NOT held.
    // This prevents zooming while cycling formations with Shift+MouseWheel.
    scr_camera_controller();
}
#endregion

// ============================================================================
// 2. FORMATION SELECTION & NOTIFICATION LOGIC
// ============================================================================
#region 2.1 Formation Control Input
var _formation_changed_this_step = false;
var _current_formation_val = global.current_formation_type; // Current enum value (integer)

// Define the order and bounds for cycling. Assumes enums are 0-indexed and contiguous.
var _formation_enum_first = Formation.NONE;
var _formation_enum_last = Formation.GRID; // MANUALLY UPDATE THIS if you add more formations to the enum

// --- Shift + Mouse Wheel Cycling ---
if (_shift_held) {
    var _wheel_direction = 0;
    if (mouse_wheel_up()) {
        _wheel_direction = -1; // Cycle "up" or "previous" in the enum order
    } else if (mouse_wheel_down()) {
        _wheel_direction = 1;  // Cycle "down" or "next" in the enum order
    }

    if (_wheel_direction != 0) {
        _current_formation_val += _wheel_direction;

        // Wrap around logic
        if (_current_formation_val < _formation_enum_first) {
            _current_formation_val = _formation_enum_last; // Wrap to last
        } else if (_current_formation_val > _formation_enum_last) {
            _current_formation_val = _formation_enum_first; // Wrap to first
        }
        
        if (global.current_formation_type != _current_formation_val) {
            global.current_formation_type = _current_formation_val;
            _formation_changed_this_step = true;
        }
    }
}

// --- F-Key Debug Cycling (Kept for alternative testing) ---
if (keyboard_check_pressed(vk_f1) && global.current_formation_type != Formation.NONE) {
    global.current_formation_type = Formation.NONE; _formation_changed_this_step = true;
} else if (keyboard_check_pressed(vk_f2) && global.current_formation_type != Formation.LINE_HORIZONTAL) {
    global.current_formation_type = Formation.LINE_HORIZONTAL; _formation_changed_this_step = true;
} else if (keyboard_check_pressed(vk_f3) && global.current_formation_type != Formation.LINE_VERTICAL) {
    global.current_formation_type = Formation.LINE_VERTICAL; _formation_changed_this_step = true;
} else if (keyboard_check_pressed(vk_f4) && global.current_formation_type != Formation.GRID) {
    global.current_formation_type = Formation.GRID; _formation_changed_this_step = true;
}

// --- Trigger Notification if Formation Actually Changed ---
if (_formation_changed_this_step) {
    var _formation_name_string = scr_get_formation_name(global.current_formation_type);
    scr_trigger_formation_notification("Formation: " + _formation_name_string);
    show_debug_message("Formation changed to: " + _formation_name_string); // Keep for console log
}
#endregion

#region 2.2 Update Formation Notification Display Timer & Alpha
if (global.formation_notification_alpha > 0) {
    global.formation_notification_timer++; // Increment timer (counts game steps)

    // Check if the text should start fading out
    if (global.formation_notification_timer > global.formation_notification_stay_time) {
        var _time_into_fade = global.formation_notification_timer - global.formation_notification_stay_time;
        var _fade_progress_percent = _time_into_fade / global.formation_notification_fade_time;
        global.formation_notification_alpha = 1.0 - clamp(_fade_progress_percent, 0, 1.0);
    }

    // If fully faded, clear the text to prevent re-drawing an invisible string
    if (global.formation_notification_alpha <= 0) {
        global.formation_notification_text = "";
        global.formation_notification_alpha = 0; // Ensure it's exactly 0
    }
}
#endregion

// ============================================================================
// 3. OTHER CONTINUOUS CONTROLLER LOGIC
// ============================================================================
// (Placeholder for other logic)
#endregion