/// scr_spawn_entity.gml
///
/// Purpose:
///   Spawns an entity of the specified type ID at the given location using the appropriate controller object.
///   Uses the entity data from global.GameData (retrieved via GetProfileFromID) to determine which controller to use.
///
/// Metadata:
///   Summary:       Core entity spawning function that routes to the correct controller object.
///   Usage:         Call scr_spawn_entity(ID.DEER_RED, x, y, layer_id) to spawn a deer.
///   Parameters:    entity_type_id : enum.ID — The ID of the entity type to spawn (from the ID enum).
///                  x : real — The x-coordinate for spawning.
///                  y : real — The y-coordinate for spawning.
///                  [layer_id] : string/id — Optional layer to spawn on (defaults to "Instances").
///   Returns:       instance id — The ID of the spawned instance, or noone if creation failed.
///   Tags:          [entity, spawning, world]
///   Version:       1.1 — YYYY-MM-DD (Updated to use GetProfileFromID and entity_type_id)
///   Dependencies:  scr_database.gml (for GetProfileFromID and ID enum), controller objects

function scr_spawn_entity(entity_type_id, spawn_x, spawn_y, layer_id = "Entities") {
    // =========================================================================
    // 0. VALIDATION & PREPARATION
    // =========================================================================
    #region 0.1 Get entity data and validate
    // Retrieve the entity's profile data from the global game data using its ID.
    // This ensures we are using data defined in our database (e.g., scr_database.gml).
    var entity_data = GetProfileFromID(entity_type_id);
    
    // If no data is found for the given ID, it's an invalid type. Log an error and exit.
    if (entity_data == undefined) {
        // It's crucial to know if an invalid ID is passed, as it indicates a logic error elsewhere.
        show_debug_message("ERROR: scr_spawn_entity — Invalid entity_type_id: " + string(entity_type_id) + ". No profile found in global.GameData.");
        return noone; // Return 'noone' to indicate failure.
    }
    
    // Default to obj_placeholder_entity if no object_index is specified in the data.
    // This acts as a fallback to prevent crashes if a controller isn't properly defined.
    var controller_obj = obj_placeholder_entity;
    #endregion
    
    // =========================================================================
    // 1. DETERMINE APPROPRIATE CONTROLLER
    // =========================================================================
    #region 1.1 Select controller based on tags or explicit setting
    // If object_index is explicitly specified in the entity data, use that.
    // This allows for direct mapping of an entity type to a specific controller object.
    if (variable_struct_exists(entity_data, "object_index") && entity_data.object_index != undefined) {
        controller_obj = entity_data.object_index;
    } 
    // Otherwise, determine the controller based on tags associated with the entity.
    // Tags provide a flexible way to categorize entities and assign behaviors.
    else if (variable_struct_exists(entity_data, "tags") && is_array(entity_data.tags)) {
        if (array_contains(entity_data.tags, "hominid")) {
            controller_obj = obj_pop; // Hominids are controlled by obj_pop.
        }
        else if (array_contains(entity_data.tags, "animal") || 
                 array_contains(entity_data.tags, "fauna")) {
            controller_obj = obj_creature_ai_controller; // Animals/fauna use the creature AI controller.
        }
        else if (array_contains(entity_data.tags, "structure")) {
            controller_obj = obj_structure_controller; // Structures use the structure controller.
        }
        else if (array_contains(entity_data.tags, "resource_node")) {
            // Resource nodes use a specific controller. The string_pos check previously here
            // is removed as tag-based or name-based identification is more robust with enums.
            controller_obj = obj_resource_node_controller;
        }
        else if (array_contains(entity_data.tags, "hazard")) {
            controller_obj = obj_hazard_controller; // Hazards use the hazard controller.
        }
        // Add more controller mappings based on tags as needed.
    }
    // If no specific controller is found, it will default to obj_placeholder_entity (set earlier).
    #endregion
    
    // =========================================================================
    // 2. CREATE INSTANCE & INITIALIZE
    // =========================================================================
    #region 2.1 Spawn the controller instance
    // Create the instance on the specified layer (or default "Instances" layer).
    // We pass a struct with entity_type_id and entity_data directly to instance_create_layer.
    // This ensures these variables are available in the instance's Create event.
    var _init_struct = {
        entity_type_id: entity_type_id,
        entity_data: entity_data
    };
    var inst = instance_create_layer(spawn_x, spawn_y, layer_id, controller_obj, _init_struct);
    
    // If instance creation fails for some reason, log an error and return 'noone'.
    if (inst == noone) {
        // Provide a detailed error message including the controller object and entity ID.
        show_debug_message("ERROR: scr_spawn_entity — Failed to create instance of " + 
                         object_get_name(controller_obj) + " for entity_type_id: " + 
                         string(entity_type_id)); // Changed from entity_type to entity_type_id
        return noone;
    }
    
    // Log successful creation for debugging purposes.
    // Using entity_data.name provides a human-readable name for the spawned entity.
    var _display_name = "Unknown Entity"; // Default display name
    if (variable_struct_exists(entity_data, "type_tag")) {
        _display_name = entity_data.type_tag;
    } else if (variable_struct_exists(entity_data, "name")) {
        // Fallback to "name" if "type_tag" doesn't exist
        _display_name = entity_data.name; 
    } else {
        _display_name = "Entity";
    }
    show_debug_message("Entity spawned: " + _display_name + " (ID: " + string(entity_type_id) + ") at (" + 
                     string(spawn_x) + ", " + string(spawn_y) + ") using controller " + object_get_name(controller_obj));
    #endregion
    
    return inst; // Return the ID of the newly created instance.
}

/// Helper function to convert entity_type enum to string for debugging
/// IMPORTANT: This function as-is will just convert the enum's integer value to a string.
/// For more descriptive names (e.g., "ID.POP_GEN1"), a dedicated mapping or
/// using `nameof()` if available in a future GML version, or a global struct/map would be needed.
/// For now, most debug messages in scr_spawn_entity use entity_data.name or direct string(entity_type_id).
function entity_type_to_string(entity_type) { // Parameter name kept for now if used elsewhere
    // This is a simple implementation - ideally you would have a mapping
    // or use a more robust method if the actual enum member name is needed.
    return string(entity_type);
}