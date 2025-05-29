// --- 1. Calculate Max Scroll Offset ---
var _total_messages_height = array_length(global.Debug.Console.Messages) * line_height;
var _visible_console_height = height - (text_padding_y * 2);

// If total messages height is greater than visible console height, we need to scroll
if (_total_messages_height > _visible_console_height) {
    max_scroll_offset_y = _total_messages_height - _visible_console_height;
} else {
    max_scroll_offset_y = 0; // No scrolling needed
    scroll_offset_y = 0;    // Reset scroll if no longer needed
}

// --- 2. Handle Mouse Wheel Scrolling ---
var _mouse_gui_x = device_mouse_x_to_gui(0);
var _mouse_gui_y = device_mouse_y_to_gui(0);

// Check if mouse is over the console area
if (point_in_rectangle(_mouse_gui_x, _mouse_gui_y, x, y, x + width, y + height)) {
    var _mouse_wheel_up = mouse_wheel_up();
    var _mouse_wheel_down = mouse_wheel_down();

    if (_mouse_wheel_up) {
        scroll_offset_y -= line_height * 3; // Scroll up by 3 lines
    }
    if (_mouse_wheel_down) {
        scroll_offset_y += line_height * 3; // Scroll down by 3 lines
    }
}

// --- 3. Handle Scrollbar Dragging ---
var _scrollbar_x = x + width - scrollbar_width;
var _scrollbar_y = y + text_padding_y;
var _scrollbar_h = height - (text_padding_y * 2);

// Calculate scrollbar handle height and position
if (max_scroll_offset_y > 0) {
    scrollbar_handle_height = (_visible_console_height / _total_messages_height) * _scrollbar_h;
    scrollbar_handle_height = max(scrollbar_handle_height, 20); // Minimum handle height
    
    // Calculate current scrollbar handle Y position based on scroll_offset_y
    scrollbar_y_ratio = scroll_offset_y / max_scroll_offset_y;
    var _handle_y_range = _scrollbar_h - scrollbar_handle_height;
    scrollbar_y_pos = _scrollbar_y + (scrollbar_y_ratio * _handle_y_range);
} else {
    scrollbar_handle_height = _scrollbar_h; // Full height if no scrolling
    scrollbar_y_pos = _scrollbar_y;
}

// Check for mouse click on scrollbar handle
if (mouse_check_button_pressed(mb_left)) {
    if (max_scroll_offset_y > 0 && point_in_rectangle(_mouse_gui_x, _mouse_gui_y, _scrollbar_x, scrollbar_y_pos, _scrollbar_x + scrollbar_width, scrollbar_y_pos + scrollbar_handle_height)) {
        is_scrolling = true;
        last_mouse_y = _mouse_gui_y; // Store initial mouse Y for dragging
    }
}

// If dragging, update scroll_offset_y
if (mouse_check_button(mb_left) && is_scrolling) {
    var _delta_y = _mouse_gui_y - last_mouse_y;
    last_mouse_y = _mouse_gui_y;

    var _handle_y_range = _scrollbar_h - scrollbar_handle_height;
    if (_handle_y_range > 0) {
        var _scroll_ratio_change = _delta_y / _handle_y_range;
        scroll_offset_y += _scroll_ratio_change * max_scroll_offset_y;
    }
}

// Stop scrolling when mouse button is released
if (mouse_check_button_released(mb_left)) {
    is_scrolling = false;
}

// --- 4. Clamp Scroll Offset ---
scroll_offset_y = clamp(scroll_offset_y, 0, max_scroll_offset_y);

// --- 5. Auto-Scroll to Bottom (if enabled and new messages added) ---
// This is a common console behavior. When a new message is added,
// we want to jump to the bottom of the log.
// You'll need to set a flag or check array length if you add messages.
// For simplicity, let's just make it always snap to bottom if auto_scroll_to_bottom is true
// and the scroll_offset_y is very close to max_scroll_offset_y (or if max_scroll_offset_y changes significantly)
// A better way: In the script that ADDS messages to global.Debug.Console.Messages,
// set a flag like `obj_dev_console.auto_scroll_to_bottom_next_frame = true;`
// and then here in the Step event:
/*
if (auto_scroll_to_bottom_next_frame) {
    scroll_offset_y = max_scroll_offset_y;
    auto_scroll_to_bottom_next_frame = false;
}
*/
// For now, let's just force it to the bottom if it's within a few lines of the bottom
if (auto_scroll_to_bottom && scroll_offset_y >= max_scroll_offset_y - (line_height * 2)) {
    scroll_offset_y = max_scroll_offset_y;
}