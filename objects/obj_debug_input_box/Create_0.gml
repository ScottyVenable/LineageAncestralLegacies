// --- Input Box State ---
text = ">";             // The actual text string currently in the input box
cursor_pos = string_length(text); // Current position of the text cursor, start after the prompt
selection_start = 0;   // Start of text selection (index)
selection_end = 0;     // End of text selection (index)
selecting = false;     // True if the user is currently dragging the mouse to select
visible = false;

// --- Visuals & Sizing ---
width = 400; // Width of the input box
height = 30;           // Height of the input box

text_color = global.Debug.Console.InputColor;         // Color of the typed text
cursor_color = c_white;       // Color of the blinking cursor
selection_color = c_blue;     // Color of the selected text highlight

// --- Cursor Blinking Effect ---
blink_timer = 0;             // Timer for cursor blinking
cursor_blink_speed = 30;     // Frames until the cursor changes visibility (e.g., 30 frames = 0.5 seconds at 60 FPS)

// --- Font (Important! Create this as a Font Asset in GMS2) ---
// Make sure you create a Font asset in GMS2 (e.g., right-click Fonts -> Create Font)
// and give it the name 'fnt_debug_font' (or whatever you prefer).
font = fnt_debug_font;

// --- Other Settings ---
max_length = 200; // Maximum number of characters allowed in the input box (optional)

// --- Focus Management ---
// This variable will be true if the input box is currently active and should accept keyboard input.
has_focus = false;

// --- Command Submission ---
// This function will be called when Enter is pressed.
// It should be overridden by the object creating/managing this input box (e.g., obj_dev_console_controller)
// to define what happens with the submitted command text.
/// @param {string} command_text The text entered by the user (excluding the initial prompt).
on_submit_command = function(command_text) {
    // Default behavior: Show a debug message and reset the input field.
    show_debug_message("obj_debug_input_box Default Submission: " + command_text);
    text = ">"; // Reset text to the prompt
    cursor_pos = string_length(text); // Place cursor after the prompt
    selection_start = cursor_pos; // Clear any selection
    selection_end = cursor_pos;
};

// For accurate text width calculations (crucial for mouse cursor positioning)
// This will store the width of each character or be a function for it
// For simple fonts, a fixed character width might suffice, but for variable width fonts:
var _test_string = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
var _char_width_avg = string_width(_test_string) / string_length(_test_string);
// This is still a rough estimate; true precision requires string_width for substrings.
// We'll calculate specific widths in the step/draw events for better accuracy.

// --- Backspace Repeat Functionality ---
backspace_held_timer = 0;      // Timer to track how long backspace is held
backspace_initial_delay = 30; // Frames to wait before repeat delete starts (e.g., 0.5s at 60fps)
backspace_repeat_rate = 3;     // Frames between each character deletion once repeating (e.g., 12 chars/sec at 60fps)