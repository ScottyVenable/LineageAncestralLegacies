/// Create Event for obj_temp_ui_message
///
/// Purpose:
///   Initializes the temporary UI message object with the necessary properties.

/// Initialize properties passed from the script
message = "";          // The message to display (set by the script)
text_color = c_white;  // Default text color
text_size = 24;        // Default font size
position_x = 0;        // X position of the message
position_y = 0;        // Y position of the message
display_time = 60;     // Duration to display the message (in frames)

/// Track the creation time to calculate when to destroy the object
creation_time = current_time;

/// Set up the font and alignment for drawing
font = -1;             // Default font (can be customized)
halign = fa_center;    // Center horizontally
valign = fa_middle;    // Center vertically