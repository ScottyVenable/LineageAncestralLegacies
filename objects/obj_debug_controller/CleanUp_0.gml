/// @description obj_debug_controller - Clean Up Event
/// @purpose Cleans up resources used by the debug controller, primarily the debug message queue.
/// This event is triggered when the instance is destroyed.

// Check if the global debug message queue exists and is a ds_list
if (variable_global_exists("debug_message_queue") && ds_exists(global.debug_message_queue, ds_type_list)) {
    // Destroy the ds_list to free up memory
    ds_list_destroy(global.debug_message_queue);
    
    // Set the global variable to noone to indicate it's no longer valid
    // This helps prevent errors if other parts of the code try to access it after destruction.
    global.debug_message_queue = noone;
    
    // Optional: Log that the queue has been cleaned up, if the debug system itself isn't reliant on this queue
    // show_debug_message("Debug message queue destroyed."); 
    // Note: Can't use queue_debug_message here as the queue is being destroyed.
}
