/// obj_resource_node_controller - Create Event
///
/// Purpose:
///    Initializes a generic resource node based on entity_data provided
///    during its creation by scr_spawn_entity.
///
/// Metadata:
///    Summary:         Sets up resource node properties from data.
///    Usage:           Called when a resource node controller is spawned.
///    Tags:            [controller][resource_node][init][data_driven]
///    Version:         1.1 - 2025-05-25 // Updated to current date and reflect ongoing dev
///    Dependencies:    scr_spawn_entity, scr_database (get_entity_data)

// This controller instance expects entity_type and entity_data to be injected by scr_spawn_entity
// entity_type = undefined; // Example: EntityType.BERRY_BUSH_GENERIC_RED
// entity_data = undefined; // Struct containing all data from get_entity_data()

// Method to initialize the instance based on the provided profile data
initialize_from_profile = function() {
    // Ensure staticProfileData has been set by the spawner (spawn_single_instance)
    if (!is_struct(self.staticProfileData)) {
        show_error($"ERROR (obj_resource_node_controller.initialize_from_profile): self.staticProfileData was not provided or is not a struct for profile_id '{self.entity_profile_id_string}'. Cannot initialize.", true);
        instance_destroy(); // Destroy self if no data
        return;
    }

    var _profile = self.staticProfileData; // Convenience alias

    // --- Core Properties ---
    // Set the sprite based on the profile data
    // Assuming profile structure: sprite_info: { default: spr_..., depleted: spr_... }
    if (variable_struct_exists(_profile, "sprite_info") && is_struct(_profile.sprite_info) && variable_struct_exists(_profile.sprite_info, "default")) {
        if (_profile.sprite_info.default != undefined) {
            sprite_index = _profile.sprite_info.default;
        } else {
            sprite_index = spr_placeholder_resource; // Ensure spr_placeholder_resource exists
            debug_log($"Warning (obj_resource_node_controller.initialize_from_profile): Profile '{self.entity_profile_id_string}' has no sprite_info.default defined. Using placeholder.", "ResourceNode:Init", "yellow");
        }
    } else {
        sprite_index = spr_placeholder_resource; // Fallback
        debug_log($"Warning (obj_resource_node_controller.initialize_from_profile): Profile '{self.entity_profile_id_string}' has no sprite_info or sprite_info.default. Using placeholder.", "ResourceNode:Init", "yellow");
    }
    
    // Set image speed, if applicable (e.g., for animated resources)
    // Assuming image_speed is directly in the profile, or could be in sprite_info
    if (variable_struct_exists(_profile, "image_speed")) {
        image_speed = _profile.image_speed;
    } else {
        image_speed = 0; // Default for static sprites
    }

    // --- Resource-Specific Properties (matching your new scr_database.gml structure for ResourceNode) ---
    // Max yield (how much can be gathered in total before depletion)
    // Your new structure uses "base_max_health" for the node's "health" or total yield.
    self.max_yield = variable_struct_exists(_profile, "base_max_health") ? _profile.base_max_health : 100;
    self.current_yield = self.max_yield; // Start with full yield

    // Yield per gather action (how much is given per interaction)
    self.yield_per_gather = variable_struct_exists(_profile, "yield_amount_per_gather_action") ? _profile.yield_amount_per_gather_action : 1;
    
    // Item yielded (path to item profile in GameData)
    // The profile has 'yielded_item_profile_path' which is a direct reference to the item struct.
    self.yielded_item_profile = variable_struct_exists(_profile, "yielded_item_profile_path") ? _profile.yielded_item_profile_path : undefined;
    if (is_undefined(self.yielded_item_profile)) {
        debug_log($"ERROR (obj_resource_node_controller.initialize_from_profile): Profile '{self.entity_profile_id_string}' missing 'yielded_item_profile_path'. Node will not yield items.", "ResourceNode:Init", "red");
    }

    // Regeneration time (in game steps or seconds, if the node regenerates)
    // Your new structure uses "respawn_time_seconds". Convert to steps if needed, or use as seconds.
    // For now, let's assume game logic will handle seconds vs steps conversion if necessary.
    self.regeneration_time_seconds = variable_struct_exists(_profile, "respawn_time_seconds") ? _profile.respawn_time_seconds : -1; 
    self.current_regeneration_timer = 0; // Timer in seconds or steps, consistent with regeneration_time_seconds

    // Tool required to harvest (tags)
    self.required_tool_tags = variable_struct_exists(_profile, "required_tool_tags") && is_array(_profile.required_tool_tags) ? _profile.required_tool_tags : [];
    
    // Skill associated with harvesting (path to skill profile)
    // Your new structure has 'skill_used_for_harvest_profile_path' (example from my earlier gamedata_init)
    // Let's assume it's 'skill_used_for_harvest_profile_path' or similar in your actual profile.
    // For now, I'll use a generic placeholder if it's not directly in your provided FLINT_DEPOSIT example.
    // Based on your BERRY_BUSH example, it was `skill_used_for_harvest_profile_path`
    // The FLINT_DEPOSIT example in your new scr_database doesn't explicitly show this, so I'll make it optional.
    self.harvest_skill_profile = variable_struct_exists(_profile, "skill_used_for_harvest_profile_path") ? _profile.skill_used_for_harvest_profile_path : undefined;
    self.xp_gained_on_harvest = variable_struct_exists(_profile, "xp_gained_on_harvest") ? _profile.xp_gained_on_harvest : 0;


    // --- State Variables ---
    self.is_depleted = false;
    self.is_regenerating = false;

    // --- Debug Logging ---
    var _display_name = variable_struct_exists(_profile, "display_name_concept") ? _profile.display_name_concept : self.entity_profile_id_string;
    var _item_name = (!is_undefined(self.yielded_item_profile) && variable_struct_exists(self.yielded_item_profile, "display_name_key")) ? self.yielded_item_profile.display_name_key : "Undefined Item";
    debug_log($"Resource Node Initialized: '{_display_name}' (Profile: {self.entity_profile_id_string}). Yield: {self.current_yield}/{self.max_yield} of item '{_item_name}'. Regen: {self.regeneration_time_seconds} sec.", "ResourceNode:Init", "green");

};

// Note: The actual call to initialize_from_profile() is expected to be made by spawn_single_instance
// after this instance is created and entity_type/entity_data are injected.
// Example:
// var _inst = instance_create_layer(x, y, layer, obj_resource_node_controller);
// _inst.entity_type = my_entity_type;
// _inst.entity_data = get_entity_data(my_entity_type);
// if (method_exists(_inst, "initialize_from_data")) {
//     _inst.initialize_from_data();
// }

// --- Example Gather Function (can be called by a pop) ---
/// @function gather_resource(gatherer_instance_id)
/// @description Attempts to gather from this resource node.
/// @param {Id.Instance} gatherer_instance_id The instance attempting to gather.
/// @returns {Struct|undefined} A struct with item_enum and quantity if successful, else undefined.
self.gather_resource = function(gatherer_instance_id) {
    // Check if the entity_data struct exists, if not, the node wasn't initialized correctly.
    if (!is_struct(self.entity_data)) {
        debug_log("Error (obj_resource_node_controller:Gather): entity_data is not a struct. Node may not be initialized.", "ResourceNode:Gather", "red");
        return undefined;
    }

    // Ensure self.entity_data.name is accessible for logging, provide a fallback.
    // var _node_name = variable_struct_exists(self.entity_data, "name") ? self.entity_data.name : "Unknown Node";
    // With the new system, we use staticProfileData and its display_name_concept
    var _node_name = (is_struct(self.staticProfileData) && variable_struct_exists(self.staticProfileData, "display_name_concept")) ? self.staticProfileData.display_name_concept : self.entity_profile_id_string;

    if (self.is_depleted) {
        debug_log($"Node '{_node_name}' is depleted. Cannot gather.", "ResourceNode:Gather", "orange");
        return undefined;
    }

    // TODO: Add checks for tool_required_tag against gatherer's capabilities/inventory
    // TODO: Add checks for harvest_skill_tag for skill checks/XP gain

    var _gathered_amount = min(self.current_yield, self.yield_per_gather);
    
    if (_gathered_amount > 0) {
        self.current_yield -= _gathered_amount;
        // Use yielded_item_profile for item name
        var _item_name_gathered = (!is_undefined(self.yielded_item_profile) && variable_struct_exists(self.yielded_item_profile, "display_name_key")) ? self.yielded_item_profile.display_name_key : "Unknown Item";
        debug_log($"Gathered {_gathered_amount} of item '{_item_name_gathered}' from '{_node_name}'. Remaining: {self.current_yield}", "ResourceNode:Gather", "cyan");

        if (self.current_yield <= 0) {
            self.is_depleted = true;
            debug_log($"Node '{_node_name}' is now depleted.", "ResourceNode:Gather", "orange");
            
            // Handle depletion:
            // 1. Change sprite to depleted version (if one exists in profile.sprite_info.depleted)
            if (is_struct(self.staticProfileData) && variable_struct_exists(self.staticProfileData, "sprite_info") && is_struct(self.staticProfileData.sprite_info) && variable_struct_exists(self.staticProfileData.sprite_info, "depleted")) {
                if (self.staticProfileData.sprite_info.depleted != undefined) {
                    sprite_index = self.staticProfileData.sprite_info.depleted;
                } else {
                    // Option: self-destruct if not regenerating, or become non-interactive
                    // instance_destroy(); 
                }
            } else {
                 // Optional: Log if depleted sprite is missing
                 debug_log($"Node '{_node_name}' depleted, but no 'sprite_info.depleted' found in profile '{self.entity_profile_id_string}'.", "ResourceNode:Gather", "yellow");
            }

            // 2. Start regeneration if applicable
            // Using regeneration_time_seconds from profile
            if (self.regeneration_time_seconds > 0) {
                self.is_regenerating = true;
                self.current_regeneration_timer = self.regeneration_time_seconds; // Assuming timer is in seconds
                debug_log($"Node '{_node_name}' starting regeneration ({self.regeneration_time_seconds} seconds).", "ResourceNode:Gather", "yellow");
            }
        }
        
        return {
            item_profile: self.yielded_item_profile, // Return the actual item profile struct
            quantity: _gathered_amount
        };
    }
    return undefined;
};

// --- Step Event (for regeneration) ---
// The regeneration logic has been moved to the Step Event of obj_resource_node_controller (Step_0.gml)
// Make sure to add a Step Event to the obj_resource_node_controller object in GameMaker
// and move the regeneration logic there. // This comment is now outdated, logic moved.
