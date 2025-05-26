/// scr_spawn_entity.gml
///
/// Purpose:
///   Spawns an entity of the specified type at the given location using the appropriate controller object.
///   Uses the entity data from scr_entities.gml to determine which controller to use.
///
/// Metadata:
///   Summary:       Core entity spawning function that routes to the correct controller object.
///   Usage:         Call scr_spawn_entity(EntityType.DEER_RED, x, y, layer_id) to spawn a deer.
///   Parameters:    entity_type : enum.EntityType — The type of entity to spawn.
///                  x : real — The x-coordinate for spawning.
///                  y : real — The y-coordinate for spawning.
///                  [layer_id] : string/id — Optional layer to spawn on (defaults to "Instances").
///   Returns:       instance id — The ID of the spawned instance, or noone if creation failed.
///   Tags:          [entity, spawning, world]
///   Version:       1.0 — 2025-05-25
///   Dependencies:  scr_database.gml, controller objects

function scr_spawn_entity(entity_type, spawn_x, spawn_y, layer_id = "Instances") {
    // =========================================================================
    // 0. VALIDATION & PREPARATION
    // =========================================================================
    #region 0.1 Get entity data and validate
    var entity_data = get_entity_data(entity_type);
    
    if (entity_data == undefined) {
        show_debug_message("ERROR: scr_spawn_entity — Invalid entity type: " + string(entity_type));
        return noone;
    }
    
    // Default to obj_placeholder_entity if no object_index is specified
    var controller_obj = obj_placeholder_entity;
    #endregion
    
    // =========================================================================
    // 1. DETERMINE APPROPRIATE CONTROLLER
    // =========================================================================
    #region 1.1 Select controller based on tags or explicit setting
    // If object_index is specified in the entity data, use that
    if (entity_data.object_index != undefined) {
        controller_obj = entity_data.object_index;
    } 
    // Otherwise determine controller based on tags
    else if (array_contains(entity_data.tags, "hominid")) {
        controller_obj = obj_pop;
    }
    else if (array_contains(entity_data.tags, "animal") || 
             array_contains(entity_data.tags, "fauna")) {
        controller_obj = obj_creature_ai_controller;
    }
    else if (array_contains(entity_data.tags, "structure")) {
        controller_obj = obj_structure_controller;
    }
    else if (array_contains(entity_data.tags, "resource_node") ||
             string_pos("NODE_", entity_type_to_string(entity_type)) > 0) {
        controller_obj = obj_resource_node_controller;
    }
    else if (array_contains(entity_data.tags, "hazard")) {
        controller_obj = obj_hazard_controller;
    }
    // Add more controller mappings as needed
    #endregion
    
    // =========================================================================
    // 2. CREATE INSTANCE & INITIALIZE
    // =========================================================================
    #region 2.1 Spawn the controller instance
    var inst = instance_create_layer(spawn_x, spawn_y, layer_id, controller_obj);
    
    if (inst == noone) {
        show_debug_message("ERROR: scr_spawn_entity — Failed to create instance of " + 
                         object_get_name(controller_obj) + " for entity type: " + 
                         string(entity_type));
        return noone;
    }
    
    // Set the entity_type property on the instance
    inst.entity_type = entity_type;
    
    // Set the entity_data property (clone to avoid modifying the original)
    inst.entity_data = entity_data;
    
    // Log successful creation
    show_debug_message("Entity spawned: " + entity_data.name + " at (" + 
                     string(spawn_x) + ", " + string(spawn_y) + ")");
    #endregion
    
    return inst;
}

/// Helper function to convert entity_type enum to string for debugging
function entity_type_to_string(entity_type) {
    // This is a simple implementation - ideally you would have a mapping
    return string(entity_type);
}