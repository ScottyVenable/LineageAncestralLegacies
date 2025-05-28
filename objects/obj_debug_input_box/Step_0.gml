// --- 1. Cursor Blinking ---
blink_timer++;
if (blink_timer >= cursor_blink_speed * 2) { // Reset after a full blink cycle (on + off)
    blink_timer = 0;
}

// --- 2. Mouse Input (for cursor placement & selection) ---
// Convert mouse coordinates to GUI layer if using a separate GUI layer
var _mouse_gui_x = device_mouse_x_to_gui(0);
var _mouse_gui_y = device_mouse_y_to_gui(0);

// Calculate the effective text drawing X (adjust for padding)
var _text_draw_x = x + 5; // 5 pixels padding from the left edge of the box

// This part is a bit tricky for precise text cursor/selection with variable-width fonts.
// You need to find which character index the mouse is over based on accumulated string widths.
// For simplicity, we'll use a basic approach and you can refine it if needed.
var _mouse_x_in_text_area = _mouse_gui_x - _text_draw_x;

// Function to get cursor position from mouse X (could be a separate script)
function get_cursor_pos_from_mouse_x(_mouse_x_in_text, _current_text, _font) {
    draw_set_font(_font);
    var _current_width = 0;
    for (var i = 0; i < string_length(_current_text); i++) {
        var _char = string_char_at(_current_text, i + 1);
        _current_width += string_width(_char);
        if (_mouse_x_in_text <= _current_width - (string_width(_char) / 2)) { // Check if mouse is within this char's half-width
            return i;
        }
    }
    return string_length(_current_text); // If mouse is past all text, put cursor at end
}

if (mouse_check_button_pressed(mb_left)) {
    // Check if the click is within the input box's bounds
    if (point_in_rectangle(_mouse_gui_x, _mouse_gui_y, x, y, x + width, y + height)) {
        has_focus = true; // Gain focus when clicked inside.
        // Calculate the new cursor position based on mouse click
        cursor_pos = get_cursor_pos_from_mouse_x(_mouse_x_in_text_area, text, font);
        selection_start = cursor_pos;
        selection_end = cursor_pos;
        selecting = true; // Start selecting if mouse is held down
    } else {
        has_focus = false; // Lose focus when clicked outside.
        // Clicked outside the box, clear any selection
        selection_start = 0;
        selection_end = 0;
    }
}

if (mouse_check_button(mb_left) && selecting) {
    // Update selection_end while dragging
    selection_end = get_cursor_pos_from_mouse_x(_mouse_x_in_text_area, text, font);
}

if (mouse_check_button_released(mb_left)) {
    selecting = false; // Stop selecting when mouse button is released
}

// --- 3. Keyboard Input Handling (Only if focused) ---
// If the input box does not have focus, no keyboard input should be processed by it.
if (!has_focus) {
    exit; // Stop further execution of this Step event for this instance.
}

// A. Basic Text Input (handled by keyboard_string)
// keyboard_string captures the last character typed. We'll append it.
if (keyboard_string != "") {
    // If there's a selection, delete it before inserting new text
    if (selection_start != selection_end) {
        var _min_sel = min(selection_start, selection_end);
        var _max_sel = max(selection_start, selection_end);
        text = string_delete(text, _min_sel + 1, _max_sel - _min_sel);
        cursor_pos = _min_sel; // Move cursor to the start of the deleted selection
    }

    // Insert new characters
    text = string_insert(keyboard_string, text, cursor_pos + 1);
    cursor_pos += string_length(keyboard_string); // Move cursor to the end of the new text
    cursor_pos = clamp(cursor_pos, 0, string_length(text)); // Keep cursor within bounds

    selection_start = cursor_pos; // Clear selection after typing
    selection_end = cursor_pos;
    
    keyboard_string = ""; // Crucial: Clear keyboard_string for the next step
}

// B. Special Key Handling (Backspace, Delete, Arrows, Home, End, Enter)
// Backspace
if (keyboard_check_pressed(vk_backspace)) {
    if (selection_start != selection_end) {
        var _min_sel = min(selection_start, selection_end);
        var _max_sel = max(selection_start, selection_end);
        text = string_delete(text, _min_sel + 1, _max_sel - _min_sel);
        cursor_pos = _min_sel;
    } else if (cursor_pos > 0) { // If no selection, delete char before cursor
        text = string_delete(text, cursor_pos, 1);
        cursor_pos--;
    }
    selection_start = cursor_pos; // Clear selection
    selection_end = cursor_pos;
    backspace_held_timer = 0; // Reset timer on initial press
} else if (keyboard_check(vk_backspace)) { // Check if backspace is being held
    backspace_held_timer++;
    // After an initial delay, start repeating the backspace action
    if (backspace_held_timer > backspace_initial_delay && (backspace_held_timer - backspace_initial_delay) % backspace_repeat_rate == 0) {
        if (selection_start != selection_end) {
            // This case might be complex to handle with repeat,
            // for now, we only repeat for single character deletion.
            // If a selection exists, the initial press would have cleared it.
            // Or, we could re-evaluate selection here if needed.
            // For simplicity, we assume selection is cleared by the first press.
        } else if (cursor_pos > 0) {
            text = string_delete(text, cursor_pos, 1);
            cursor_pos--;
            selection_start = cursor_pos; // Keep selection cleared
            selection_end = cursor_pos;
        }
    }
} else {
    backspace_held_timer = -1; // Reset when backspace is not held or pressed
}

// Delete
if (keyboard_check_pressed(vk_delete)) {
    if (selection_start != selection_end) {
        var _min_sel = min(selection_start, selection_end);
        var _max_sel = max(selection_start, selection_end);
        text = string_delete(text, _min_sel + 1, _max_sel - _min_sel);
        cursor_pos = _min_sel;
    } else if (cursor_pos < string_length(text)) { // If no selection, delete char after cursor
        text = string_delete(text, cursor_pos + 1, 1);
    }
    selection_start = cursor_pos; // Clear selection
    selection_end = cursor_pos;
}

// Left Arrow
if (keyboard_check_pressed(vk_left)) {
    if (cursor_pos > 0) {
        cursor_pos--;
    }
    if (!_shift_held) { // If Shift not held, clear selection
        selection_start = cursor_pos;
        selection_end = cursor_pos;
    } else { // If Shift held, extend selection
        selection_end = cursor_pos;
    }
}

// Right Arrow
if (keyboard_check_pressed(vk_right)) {
    if (cursor_pos < string_length(text)) {
        cursor_pos++;
    }
    if (!_shift_held) { // If Shift not held, clear selection
        selection_start = cursor_pos;
        selection_end = cursor_pos;
    } else { // If Shift held, extend selection
        selection_end = cursor_pos;
    }
}

// Home Key
if (keyboard_check_pressed(vk_home)) {
    cursor_pos = 0;
    if (!_shift_held) {
        selection_start = cursor_pos;
        selection_end = cursor_pos;
    } else {
        selection_end = cursor_pos;
    }
}

// End Key
if (keyboard_check_pressed(vk_end)) {
    cursor_pos = string_length(text);
    if (!_shift_held) {
        selection_start = cursor_pos;
        selection_end = cursor_pos;
    } else {
        selection_end = cursor_pos;
    }
}

// Enter Key (Submit Command)
// Check if the Enter key (vk_enter or vk_numpadenter) was just pressed.
if (keyboard_check_pressed(vk_enter))
{
    // Extract the command text. Assuming the prompt is always ">",
    // we copy the string starting from the second character.
    var _command_to_submit = string_copy(text, 2, string_length(text) - 1);
    
    // Call the on_submit_command function, passing the extracted command.
    // This function is expected to be defined by the controller of this input box.
    on_submit_command(_command_to_submit);
    
    // Note: The on_submit_command function itself is responsible for clearing
    // the input text and resetting cursor_pos if that's the desired behavior after submission.
}

// C. Copy, Paste, Cut (Ctrl+C, Ctrl+V, Ctrl+X)
// Copy (Ctrl+C)
if (keyboard_check(vk_control) && keyboard_check_pressed(ord("C"))) {
    if (selection_start != selection_end) {
        var _min_sel = min(selection_start, selection_end);
        var _max_sel = max(selection_start, selection_end);
        clipboard_set_text(string_copy(text, _min_sel + 1, _max_sel - _min_sel));
    }
}

// Paste (Ctrl+V)
if (keyboard_check(vk_control) && keyboard_check_pressed(ord("V"))) {
    var _paste_text = clipboard_get_text();
    if (_paste_text != "") { // Only paste if there's something in the clipboard
        // If there's a selection, delete it first
        if (selection_start != selection_end) {
            var _min_sel = min(selection_start, selection_end);
            var _max_sel = max(selection_start, selection_end);
            text = string_delete(text, _min_sel + 1, _max_sel - _min_sel);
            cursor_pos = _min_sel;
        }

        // Insert pasted text
        text = string_insert(_paste_text, text, cursor_pos + 1);
        cursor_pos += string_length(_paste_text);
        cursor_pos = clamp(cursor_pos, 0, string_length(text));
        selection_start = cursor_pos; // Clear selection after pasting
        selection_end = cursor_pos;
    }
}

// Cut (Ctrl+X)
if (keyboard_check(vk_control) && keyboard_check_pressed(ord("X"))) {
    if (selection_start != selection_end) {
        var _min_sel = min(selection_start, selection_end);
        var _max_sel = max(selection_start, selection_end);
        clipboard_set_text(string_copy(text, _min_sel + 1, _max_sel - _min_sel)); // Copy first
        text = string_delete(text, _min_sel + 1, _max_sel - _min_sel); // Then delete
        cursor_pos = _min_sel; // Move cursor to the cut area
        selection_start = cursor_pos; // Clear selection
        selection_end = cursor_pos;
    }
}

// D. Enter to Submit Functionality
if (keyboard_check_pressed(vk_enter)) {
    // --- THIS IS WHERE YOU PROCESS YOUR COMMAND ---
    // For now, let's just show it in the debug console:
    show_debug_message("Debug Command Submitted: " + text);
    array_push(global.Debug.Console.Messages, text);

    // After submission, clear the input box
    text = "";
    cursor_pos = 0;
    selection_start = 0;
    selection_end = 0;
}