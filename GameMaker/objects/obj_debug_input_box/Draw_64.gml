// Make sure we're drawing on the GUI layer for consistent scaling
// (You'll likely want to set your room's GUI layer resolution in Room Editor)
draw_set_halign(fa_left); // Align text to the left
draw_set_valign(fa_top);  // Align text to the top
draw_set_font(font);      // Set the font you defined in the Create event

// --- 1. Draw Background and Border (Visual cue for the input box) ---
// Set a background color for the input box area.
draw_set_color(c_black); // Example: Black background
draw_rectangle(x, y, x + width, y + height, false); // false = filled rectangle

// Draw a border around the input box.
// This helps visually define its clickable area and focus state.
draw_set_color(has_focus ? c_yellow : c_gray); // Example: Yellow border if focused, gray otherwise
draw_rectangle(x, y, x + width, y + height, true); // true = outline rectangle

// --- 2. Calculate Text Drawing Position ---
var _text_draw_x = x + 2; // Add some padding from the left edge of the box
var _text_draw_y = y + (height - string_height(text)) / 2; // Vertically center text in the box

// --- 3. Draw Selection Highlight ---
if (selection_start != selection_end) {
    var _draw_sel_start = min(selection_start, selection_end);
    var _draw_sel_end = max(selection_start, selection_end);

    // Calculate pixel positions for selection start and end
    var _sel_x1 = _text_draw_x + string_width(string_copy(text, 1, _draw_sel_start));
    var _sel_x2 = _text_draw_x + string_width(string_copy(text, 1, _draw_sel_end));

    draw_set_color(selection_color);
    draw_rectangle(_sel_x1, y + 2, _sel_x2, y + height - 2, false); // Draw selection box with small vertical padding
}

// --- 4. Draw Text ---
draw_set_color(text_color);
draw_text(_text_draw_x, _text_draw_y, text);

// --- 5. Draw Cursor ---
// Only draw cursor if the box has focus, no text is selected AND during the 'on' phase of the blink timer
// The cursor indicates where new text will be inserted.
if (has_focus && selection_start == selection_end && (blink_timer < cursor_blink_speed || keyboard_check(vk_lshift) || keyboard_check(vk_rshift) || keyboard_check(vk_control))) {
    // Calculate cursor's X position based on the text width up to cursor_pos
    var _cursor_draw_x = _text_draw_x + string_width(string_copy(text, 1, cursor_pos));
    
    draw_set_color(cursor_color);
    draw_line_width(_cursor_draw_x, y + 2, _cursor_draw_x, y + height - 2, 2); // Draw a 2-pixel wide vertical line
}

// Reset draw settings to default if other drawing happens in your game
draw_set_color(c_white);
draw_set_font(-1);