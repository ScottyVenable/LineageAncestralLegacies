// --- Visuals ---
text_color = global.Debug.Console.OutputColor;    // Color of the console text (classic green!)
scrollbar_color = c_dkgray;   // Color of the scrollbar
scrollbar_handle_color = c_gray; // Color of the scrollbar handle

// --- Font (Same as input box, ensure it's created as a Font Asset) ---
font = fnt_debug_font; // Make sure 'fnt_debug_font' exists in your GMS2 project

// --- Text Display Settings ---
text_padding_x = 5;    // Horizontal padding for text inside the box
text_padding_y = 5;    // Vertical padding for text inside the box
line_height = 0;       // Will be calculated based on font height
height = 300
width = 300

// --- Scrolling Variables ---
scroll_offset_y = 0;   // Current vertical scroll offset (how far down we've scrolled)
max_scroll_offset_y = 0; // Maximum possible scroll offset (calculated dynamically)
scrollbar_width = 10;  // Width of the scrollbar itself
scrollbar_handle_height = 0; // Height of the draggable part of the scrollbar
scrollbar_y_ratio = 0; // Ratio of scrollbar handle position (0 to 1)
is_scrolling = false;  // Flag to check if the user is currently dragging the scrollbar handle
last_mouse_y = 0;      // Stores mouse Y for scrollbar dragging calculation
auto_scroll_to_bottom = true; // Automatically scroll to the newest message
visible = false; // Whether the console is currently visible

// --- Initialize Global Debug Message Array (IMPORTANT: Do this once, e.g., in a persistent init object) ---
// You should put this in a persistent object's Create event or your very first room's Create event.
// For demonstration, I'll put it here, but ideally, it's global and persistent.
if (!variable_global_exists("Debug")) {
    global.Debug = {
        Console: {
            Messages: []
        }
    };
}

// Calculate initial line height
draw_set_font(font);
line_height = string_height("Tg") + 2; // "Tg" usually gives a good average height, +2 for spacing