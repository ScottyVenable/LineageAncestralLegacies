// Make sure we're drawing on the GUI layer
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(font);

// --- 2. Set Clipping Region ---
// This ensures that text and anything else drawn for the console stays within its bounds.
var _clip_x1 = x + text_padding_x;
var _clip_y1 = y + text_padding_y;
var _clip_x2 = x + width - text_padding_x - (max_scroll_offset_y > 0 ? scrollbar_width : 0); // Adjust for scrollbar if present
var _clip_y2 = y + height - text_padding_y;
draw_set_clip_rectangle(_clip_x1, _clip_y1, _clip_x2, _clip_y2);

// --- 3. Draw Messages ---
draw_set_color(text_color);

var _current_y = _clip_y1 - scroll_offset_y; // Apply scroll offset to the starting Y position

for (var i = 0; i < array_length(global.Debug.Console.Messages); i++) {
    var _message = global.Debug.Console.Messages[i];
/*    
    // Only draw messages that are within the visible Y range
    if (_current_y + line_height > _clip_y1 && _current_y < _clip_y2) {
        draw_text(_clip_x1, _current_y, _message);
    }
    _current_y += line_height;
     */
}

// --- 4. Clear Clipping Region ---
draw_set_clip_rectangle(-1, -1, -1, -1); // Reset clipping to draw the scrollbar outside the text area

// --- 5. Draw Scrollbar (if needed) ---
if (max_scroll_offset_y > 0) {
    var _scrollbar_x = x + width - scrollbar_width;
    var _scrollbar_y = y + text_padding_y;
    var _scrollbar_h = height - (text_padding_y * 2);

    // Draw scrollbar track
    draw_set_color(scrollbar_color);
    draw_rectangle(_scrollbar_x, _scrollbar_y, _scrollbar_x + scrollbar_width, _scrollbar_y + _scrollbar_h, false);

    // Draw scrollbar handle
    draw_set_color(scrollbar_handle_color);
    draw_rectangle(_scrollbar_x, scrollbar_y_pos, _scrollbar_x + scrollbar_width, scrollbar_y_pos + scrollbar_handle_height, false);
}

// Reset draw settings to default
draw_set_color(c_white);
draw_set_font(-1);