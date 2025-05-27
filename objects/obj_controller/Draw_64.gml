/// obj_controller – Draw GUI Event
///
/// Purpose:
///    Handles drawing of GUI elements that are managed by the controller,
///    such as the mouse drag selection box and the formation change notification text.
///
/// Metadata:
///    Summary:         Draws controller-managed GUI elements.
///    Usage:           obj_controller Draw GUI Event.
///    Parameters:    none
///    Returns:         void
///    Tags:            [controller][ui][drawing][feedback][notification]
///    Version:         1.2 - [Current Date] (Added formation notification drawing logic)
///    Dependencies:  scr_draw_selection_box, global formation_notification variables,
///                     fnt_ui_header (or other font for notifications)

// =========================================================================
// 1. DRAW SELECTION BOX (During Mouse Drag)
// =========================================================================
#region 1.1 Draw Selection Box
// This script should handle its own checks (e.g., if is_dragging is true)
if(is_dragging){
	scr_draw_selection_box();
}

// Defensive: Check if _shift_held is defined before using it to avoid runtime errors
if (variable_global_exists("_shift_held") && _shift_held && (mouse_wheel_up() || mouse_wheel_down())) {
    global.block_zoom_this_frame = true; // Signal to your zoom code to block zooming this frame
    // Educational: This prevents zooming when changing formation spacing/type with Shift+mouse wheel.
}

// Only log the debug message once every 60 frames to avoid flooding the log
// Use a global variable for the timer, since static cannot be used in the Draw event in GMS2
if (!variable_global_exists("debug_draw64_log_timer")) {
    global.debug_draw64_log_timer = 0;
}
if (global.debug_draw64_log_timer <= 0) {
    show_debug_message("DEBUG obj_controller Draw_64: AFTER call to scr_draw_selection_box.");
    global.debug_draw64_log_timer = 60; // Log once every 60 frames (about once per second at 60fps)
} else {
    global.debug_draw64_log_timer--;
}
#endregion

// =========================================================================
// 2. DRAW FORMATION CHANGE NOTIFICATION
// =========================================================================
#region 2.1 Draw Formation Notification Text
// Only draw if the notification is active (alpha > 0) and has text
if (global.formation_notification_alpha > 0 && global.formation_notification_text != "") {
    // Positioning: bottom-left at (192, 798) in GUI coordinates (user request)
    var _text_x_pos = 185;
    var _text_y_pos = 840;

    // Set drawing properties for the notification text
    draw_set_font(fnt_ui_header); // Or a specific fnt_notification if you create one
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);   // Vertically center the text around _text_y_pos
    draw_set_alpha(global.formation_notification_alpha); // Apply fade effect

    // Make the text 50% smaller (scale = 0.5)
    var _scale = 0.5;
    draw_set_color(c_black);
    draw_text_transformed(_text_x_pos + 2, _text_y_pos + 2, global.formation_notification_text, _scale, _scale, 0);
    draw_set_color(c_white); // Or another prominent color like c_yellow or c_lime
    draw_text_transformed(_text_x_pos, _text_y_pos, global.formation_notification_text, _scale, _scale, 0);

    draw_set_alpha(1.0);
    // Font, halign, valign will likely be reset by other drawing calls
    // or should be reset if this is the last GUI element drawn by this object.
    // For safety, can add resets here or at the end of all obj_controller GUI drawing.
}
#endregion

// =========================================================================
// 3. STATUS BAR
// =========================================================================





/*
#region X.1 Final GUI Resets
draw_set_font(-1);          // Reset to default font
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1.0);
#endregion
*/