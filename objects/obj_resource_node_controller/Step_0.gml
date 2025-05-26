/// obj_resource_node_controller - Step Event
///
/// Purpose:
///    Handles per-step logic for resource nodes, primarily regeneration.
///
/// Metadata:
///    Summary:         Manages resource regeneration timers.
///    Usage:           Automatically called each step by GameMaker.
///    Tags:            [controller][resource_node][step][regeneration]
///    Version:         1.0 - 2025-05-25 // Scotty's Current Date
///    Dependencies:    Uses variables initialized in the Create Event (e.g., self.is_regenerating, self.entity_data)

// Check if the node is currently in a regenerating state
if (self.is_regenerating) {
    // Decrement the regeneration timer each step
    self.current_regeneration_timer--;

    // Check if the regeneration timer has reached zero
    if (self.current_regeneration_timer <= 0) {
        // Reset regeneration state flags
        self.is_regenerating = false;
        self.is_depleted = false;
        
        // Restore the node's yield to its maximum capacity
        self.current_yield = self.max_yield;
        
        // Change sprite back to the default 'full' sprite
        // Ensure entity_data and default_sprite are valid before attempting to use them
        if (is_struct(self.entity_data) && variable_struct_exists(self.entity_data, "default_sprite") && self.entity_data.default_sprite != undefined) {
            sprite_index = self.entity_data.default_sprite;
        } else {
            // Fallback if data is missing, though ideally this shouldn't happen if initialized correctly
            sprite_index = spr_placeholder_resource; 
            debug_log($"Warning (obj_resource_node_controller:Step): Missing default_sprite for {entity_type_to_string(entity_type)} during regeneration. Using placeholder.", "ResourceNode:Regen", "yellow");
        }
        
        // Log that the node has successfully regenerated
        // Ensure entity_data and name are valid before attempting to use them for logging
        var _node_name = (is_struct(self.entity_data) && variable_struct_exists(self.entity_data, "name")) ? self.entity_data.name : "Unknown Node";
        debug_log($"Node '{_node_name}' has regenerated.", "ResourceNode:Step", "green");
    }
}
