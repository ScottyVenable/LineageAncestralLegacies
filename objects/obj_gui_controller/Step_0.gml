// obj_gui_controller - Step Event
//
// Purpose:
//   Handles updating all floating UI dropoff texts (e.g., food deposit popups).
//   This event updates the position, alpha, and lifetime of each floating text.
//
// Educational Note:
//   - This uses a global list to store all active floating dropoff texts.
//   - Each entry is a struct with x, y, sprite, amount, alpha, and timer fields.
//   - The Step event moves the text up and fades it out over time.
//
// Project Convention:
//   - This logic is in the GUI controller for centralized UI management.
//   - See also: scr_ui_showDropoffText (for adding new popups).

// Initialize the global list if it doesn't exist
if (!variable_global_exists("floating_dropoff_texts")) {
    global.floating_dropoff_texts = [];
}

// Update all floating dropoff texts
for (var i = array_length(global.floating_dropoff_texts) - 1; i >= 0; i--) {
    var popup = global.floating_dropoff_texts[i];
    // Move text up (float effect)
    popup.y -= popup.float_speed;
    // Fade out over time
    popup.alpha -= popup.fade_speed;
    // Decrease timer
    popup.timer--;
    // Remove if fully faded or timer expired
    if (popup.timer <= 0 || popup.alpha <= 0) {
        array_delete(global.floating_dropoff_texts, i, 1);
    } else {
        global.floating_dropoff_texts[i] = popup; // Save changes
    }
}
