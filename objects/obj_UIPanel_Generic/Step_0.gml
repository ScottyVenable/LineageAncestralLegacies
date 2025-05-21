// --- obj_UI_InventoryPanel ---
// Event: Step > Step GUI (or Step Event)
// Purpose: Updates panel position if dragging.
// ============================================================================
#region Step GUI Event (for dragging)
// Assumes panel_x, panel_y, panel_width, panel_height, dragging, 
// drag_offset_x, drag_offset_y are instance variables.

if (dragging) {
    // Check if the left mouse button is still being held down
    if (mouse_check_button(mb_left)) { 
        var _gui_mx = device_mouse_x_to_gui(0);
        var _gui_my = device_mouse_y_to_gui(0);

		x = _gui_mx + drag_offset_x; // Update instance's x
		y = _gui_my + drag_offset_y; // Update instance's y
		x = clamp(x, 0, _screen_w - width);
		y = clamp(y, 0, _screen_h - height);

        // Optional: Clamp panel position to stay within screen bounds
        var _screen_w = display_get_gui_width();
        var _screen_h = display_get_gui_height();
        
        panel_x = clamp(panel_x, 0, _screen_w - panel_width);
        panel_y = clamp(panel_y, 0, _screen_h - panel_height);

    } else {
        // If mouse button is somehow released while dragging is still true
        // (e.g., if Left Released event didn't fire for some reason), stop dragging.
        dragging = false; 
    }
}
#endregion
