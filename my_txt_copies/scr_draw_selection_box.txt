/// scr_draw_selection_box.gml
///
/// Purpose:
///   Draws the translucent GUI‐space selection rectangle while dragging.
///
/// Metadata:
///   Summary:       Render selection box from sel_start to current mouse position  
///   Usage:         obj_controller Draw GUI Event: scr_draw_selection_box();  
///   Parameters:    none  
///   Returns:       void  
///   Tags:          [ui]  
///   Version:       1.0 — 2025-05-18  
///   Dependencies:  device_mouse_x_to_gui(), draw_rectangle()

function scr_draw_selection_box() {
    // =========================================================================
    // 1. DRAW GUI SELECTION BOX
    // =========================================================================
    #region Selection Box
    if (is_dragging) {
        // GUI‐space mouse coordinates
        var gx = device_mouse_x_to_gui(0);
        var gy = device_mouse_y_to_gui(0);

        // Draw translucent rectangle from drag start to current
        draw_set_color(c_lime);
        draw_set_alpha(0.25);
        draw_rectangle(
            min(sel_start_x, gx),
            min(sel_start_y, gy),
            max(sel_start_x, gx),
            max(sel_start_y, gy),
            false
        );
        draw_set_alpha(1);
    }
    #endregion

    // =========================================================================
    // 2. CLEANUP & RETURN
    // =========================================================================
    #region Cleanup
    return;
    #endregion
}
