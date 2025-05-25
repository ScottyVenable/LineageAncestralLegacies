/// scr_ui_showDropoffText.gml
///
/// Purpose:
///   Displays a UI message when a pop finishes hauling resources to the gathering hut.
///
/// Metadata:
///   Summary:       Displays a dropoff message for hauling completion.
///   Usage:         Called when a pop completes a hauling action.
///   Parameters:    message : string — The text to display.
///                  duration : real — How long the message should appear (in seconds).
///   Returns:       void
///   Tags:          [ui]
///   Version:       1.1 — 2025-05-24
///   Dependencies:  obj_temp_ui_message

function scr_ui_showDropoffText(message, duration) {
    // =========================================================================
    // 0. VALIDATION & EARLY RETURNS
    // =========================================================================
    #region 0.1 Parameter Validation
    if (!is_string(message) || string_length(message) == 0) {
        show_debug_message("ERROR: scr_ui_showDropoffText — invalid message");
        return;
    }
    if (!is_real(duration) || duration <= 0) {
        show_debug_message("ERROR: scr_ui_showDropoffText — invalid duration");
        return;
    }
    #endregion

    // =========================================================================
    // 1. CREATE TEMPORARY UI OBJECT
    // =========================================================================
    #region 1.1 Create Temporary Object
    var temp_obj = instance_create_layer(0, 0, "UI", obj_temp_ui_message);

    // Pass parameters to the temporary object
    temp_obj.message = message;
    temp_obj.display_time = duration * room_speed; // Convert seconds to frames
    #endregion

    return;
}