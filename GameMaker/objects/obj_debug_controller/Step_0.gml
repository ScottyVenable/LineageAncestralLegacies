/// @description obj_debug_controller - Step Event
/// @purpose Processes the debug message queue each step, displaying messages based on category and global settings.

// Check if the global debug message queue exists and is a ds_list
// Also, ensure the global.Debug and global.Debug.Logging structures are initialized.
if (variable_global_exists("debug_message_queue") && 
    ds_exists(global.debug_message_queue, ds_type_list) &&
    variable_global_exists("Debug") && 
    is_struct(global.Debug) &&
    variable_struct_exists(global.Debug, "Logging") &&
    is_struct(global.Debug.Logging)) {

    // Only process the queue if AllEnabled is true. 
    // This acts as a master switch for all categorized logging.
    if (global.Debug.Logging.AllEnabled) {
        var queue_size = ds_list_size(global.debug_message_queue);
        
        // Iterate through the message queue
        for (var i = 0; i < queue_size; i++) {
            var message_data = global.debug_message_queue[| i];
            
            // Ensure message_data is a struct and has the expected fields
            if (is_struct(message_data) && variable_struct_exists(message_data, "category") && variable_struct_exists(message_data, "message")) {
                var category = message_data.category;
                var message_content = message_data.message;
                var show_msg = false; // Flag to determine if the message should be shown

                // Check if the specific category is enabled for logging
                // This uses a switch for clarity and easy expansion.
                switch (category) {
                    case "Worldgen":
                        if (global.Debug.Logging.WorldgenEnabled) {
                            show_msg = true;
                        }
                        break;
                    case "Pops":
                        if (global.Debug.Logging.PopsEnabled) {
                            show_msg = true;
                        }
                        break;
                    case "Entities":
                        if (global.Debug.Logging.EntitiesEnabled) {
                            show_msg = true;
                        }
                        break;
                    case "UI":
                        if (global.Debug.Logging.UIEnabled) {
                            show_msg = true;
                        }
                        break;
                    case "AI": // Added AI category as per potential future need
                        if (variable_struct_exists(global.Debug.Logging, "AIEnabled") && global.Debug.Logging.AIEnabled) {
                             show_msg = true;
                        }
                        break;
                    case "Inventory": // Added Inventory category
                         if (variable_struct_exists(global.Debug.Logging, "InventoryEnabled") && global.Debug.Logging.InventoryEnabled) {
                             show_msg = true;
                        }
                        break;
                    // Add more cases here for other categories as needed
                    default:
                        // For uncategorized messages or categories not explicitly handled,
                        // we can decide to show them or not. For now, let's assume they are shown if AllEnabled is on.
                        // Alternatively, you might want a specific "DefaultEnabled" or "OtherEnabled" flag.
                        // For this implementation, if it doesn't match a known category, it won't be shown unless a general fallback is desired.
                        // Consider adding a general "Other" category if you want to catch these.
                        // show_debug_message("Debug: Uncategorized message or category '" + category + "' not explicitly handled.");
                        break;
                }
                
                if (show_msg) {
                    // Display the formatted debug message
                    // The timestamp could also be included here if desired: string(message_data.timestamp)
                    show_debug_message("[" + string(category) + "] " + string(message_content));
                }
            } else {
                // Log an error if the message_data is not in the expected format
                show_debug_message("Error: Invalid message format in debug queue at index " + string(i));
            }
        }
    }
    
    // Clear the list after processing all messages for this step
    // This ensures messages are only processed once.
    ds_list_clear(global.debug_message_queue);
} else {
    // This message indicates that the debug system isn't properly initialized.
    // It uses show_debug_message directly because the queueing system itself might be the issue.
    // This should ideally only appear if obj_debug_controller's Create event hasn't run or there's an issue with global variable setup.
    // show_debug_message("Debug system warning: global.debug_message_queue or global.Debug.Logging not initialized.");
}
