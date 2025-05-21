// --- obj_UI_InventoryPanel ---
// Event: Mouse > GUI > Left Pressed
// Purpose: Handles initiating a drag, clicking the close button, or consuming the click if within the panel.
// ============================================================================
#region GUI Left Pressed Event
// Get mouse coordinates in GUI space
var _gui_mx = device_mouse_x_to_gui(0);
var _gui_my = device_mouse_y_to_gui(0);

// --- Check if click is within the panel's overall bounds ---
// Assumes panel_x, panel_y, panel_width, panel_height are instance variables
// NEW:
var _panel_x1 = x;          // Use instance's actual x
var _panel_y1 = y;          // Use instance's actual y
var _panel_x2 = x + width;  // Use instance's actual width
var _panel_y2 = y + height; // Use instance's actual height

if (point_in_rectangle(_gui_mx, _gui_my, _panel_x1, _panel_y1, _panel_x2, _panel_y2)) {
    // Click is inside the panel. Now check for specific actions.

    // --- Check for Close Button Click ---
    // Assumes close_button_size, close_button_margin, header_height are instance variables
    var _close_btn_x1 = panel_x + panel_width - close_button_size - close_button_margin;
    var _close_btn_y1 = panel_y + close_button_margin;
    var _close_btn_x2 = _close_btn_x1 + close_button_size;
    var _close_btn_y2 = _close_btn_y1 + close_button_size;

    if (point_in_rectangle(_gui_mx, _gui_my, _close_btn_x1, _close_btn_y1, _close_btn_x2, _close_btn_y2)) {
        target_pop_instance_id = noone; // Reset target
        visible = false;                // Hide the panel
        dragging = false;               // Ensure dragging stops
        
        // Consume the mouse event so it doesn't affect game world selection
        if (variable_global_exists("mouse_event_consumed_by_ui")) {
            global.mouse_event_consumed_by_ui = true; 
        }
        exit; // Action handled (closed the panel)
    }

    // --- Check for Drag Initiation (click on panel header area) ---
    var _header_x1 = panel_x;
    var _header_y1 = panel_y;
    var _header_x2 = panel_x + panel_width;
    var _header_y2 = panel_y + header_height; // Draggable header area

    if (point_in_rectangle(_gui_mx, _gui_my, _header_x1, _header_y1, _header_x2, _header_y2)) {
        dragging = true;
		drag_offset_x = x - _gui_mx;
		drag_offset_y = y - _gui_my;
        
        // Consume the mouse event
        if (variable_global_exists("mouse_event_consumed_by_ui")) {
            global.mouse_event_consumed_by_ui = true; 
        }
        exit; // Action handled (started dragging)
    }

    // If the click was inside the panel but not on the close button or header,
    // it's just a click on the panel body (e.g., on an item, scrollbar, etc.). Consume it.
    if (variable_global_exists("mouse_event_consumed_by_ui")) {
        global.mouse_event_consumed_by_ui = true;
    }
    // No 'exit' here is strictly needed if there are no other UI elements below this one
    // that might also react to this click. The flag itself will stop scr_selection_controller.

} else {
    // Click was outside the panel. Do nothing here regarding consumption.
    // The selection controller will handle it as a world click.
    // Ensure dragging is false if somehow clicked outside while dragging was true (should be rare)
    dragging = false; 
}
#endregion
