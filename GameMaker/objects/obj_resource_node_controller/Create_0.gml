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
///    Version:         1.2 - 2025-05-26 // Updated to use entity_data directly
///    Dependencies:    scr_spawn_entity, scr_database (for ID enum and GetProfileFromID structure)

// These instance variables are expected to be populated by scr_spawn_entity via the init struct
// passed to instance_create_layer.
// entity_type_id = undefined; // Example: ID.NODE_FLINT_DEPOSIT
// entity_data = undefined;    // Struct containing all data from GetProfileFromID(entity_type_id)

// --- Validate entity_data ---
if (is_undefined(self.entity_data) || !is_struct(self.entity_data)) {
    var _error_msg = "FATAL (obj_resource_node_controller Create): self.entity_data is not a valid struct or is undefined.";
    if (!is_undefined(self.entity_type_id)) {
        _error_msg += " (Passed entity_type_id: " + string(self.entity_type_id) + ")";
    }
    show_error(_error_msg, true);
    instance_destroy(); // Critical error, remove the node
    return; // Stop further initialization
}

var _profile = self.entity_data; // Convenience alias, using the directly provided data
var _profile_id_string_for_debug = !is_undefined(self.entity_type_id) ? string(self.entity_type_id) : "ENTITY_ID_UNDEFINED";

// --- Core Properties ---
// Set the sprite based on the profile data
if (variable_struct_exists(_profile, "sprite_info") && is_struct(_profile.sprite_info) && variable_struct_exists(_profile.sprite_info, "default")) {
    // Assuming sprite names are stored as strings in the profile and need to be converted to asset indices
    var _default_sprite_name = _profile.sprite_info.default;
    if (is_string(_default_sprite_name) && asset_exists(_default_sprite_name)) {
        sprite_index = asset_get_index(_default_sprite_name);
    } else {
        sprite_index = spr_placeholder_resource; // Ensure spr_placeholder_resource exists
        debug_log("Warning (obj_resource_node_controller Create): Profile '" + _profile_id_string_for_debug + "' sprite_info.default '" + string(_default_sprite_name) + "' is not a valid sprite asset. Using placeholder.", "ResourceNode:Init", "yellow");
    }
} else {
    sprite_index = spr_placeholder_resource; // Fallback
    debug_log("Warning (obj_resource_node_controller Create): Profile '" + _profile_id_string_for_debug + "' has no sprite_info or sprite_info.default. Using placeholder.", "ResourceNode:Init", "yellow");
}

// Set image speed, if applicable
if (variable_struct_exists(_profile, "image_speed")) {
    image_speed = _profile.image_speed;
} else {
    image_speed = 0; // Default for static sprites
}

// --- Resource-Specific Properties ---
self.max_yield = variable_struct_exists(_profile, "base_max_health") ? _profile.base_max_health : 100;
self.current_yield = self.max_yield;

self.yield_per_gather = variable_struct_exists(_profile, "yield_amount_per_gather_action") ? _profile.yield_amount_per_gather_action : 1;

// The profile has 'yielded_item_profile_path' which should be a direct reference to the item struct in global.GameData
self.yielded_item_profile = variable_struct_exists(_profile, "yielded_item_profile_path") ? _profile.yielded_item_profile_path : undefined;
if (is_undefined(self.yielded_item_profile)) {
    debug_log("ERROR (obj_resource_node_controller Create): Profile '" + _profile_id_string_for_debug + "' missing 'yielded_item_profile_path'. Node will not yield items.", "ResourceNode:Init", "red");
}

self.regeneration_time_seconds = variable_struct_exists(_profile, "respawn_time_seconds") ? _profile.respawn_time_seconds : -1; 
self.current_regeneration_timer = 0;

self.required_tool_tags = (variable_struct_exists(_profile, "required_tool_tags") && is_array(_profile.required_tool_tags)) ? _profile.required_tool_tags : [];

// Assuming skill and XP are optional or might not be in all resource node profiles
self.harvest_skill_profile = variable_struct_exists(_profile, "skill_used_for_harvest_profile_path") ? _profile.skill_used_for_harvest_profile_path : undefined;
self.xp_gained_on_harvest = variable_struct_exists(_profile, "xp_gained_on_harvest") ? _profile.xp_gained_on_harvest : 0;

// --- State Variables ---
self.is_depleted = false;
self.is_regenerating = false;

// --- Debug Logging ---
var _display_name = variable_struct_exists(_profile, "display_name_concept") ? _profile.display_name_concept : _profile_id_string_for_debug;
var _item_name_for_debug = "Undefined Item";
if (!is_undefined(self.yielded_item_profile) && variable_struct_exists(self.yielded_item_profile, "display_name_key")) {
    // Assuming display_name_key needs to be localized or is a direct string.
    // For simplicity, using it directly. If it's a key, localization logic would be needed.
    _item_name_for_debug = self.yielded_item_profile.display_name_key; 
}
debug_log("Resource Node Initialized: '" + string(_display_name) + "' (Profile ID: " + _profile_id_string_for_debug + "). Yield: " + string(self.current_yield) + "/" + string(self.max_yield) + " of item '" + string(_item_name_for_debug) + "'. Regen: " + string(self.regeneration_time_seconds) + " sec.", "ResourceNode:Init", "green");

// --- Example Gather Function (can be called by a pop) ---
/// @function gather_resource(gatherer_instance_id)
/// @description Attempts to gather from this resource node.
/// @param {Id.Instance} gatherer_instance_id The instance attempting to gather.
/// @returns {Struct|undefined} A struct with item_profile and quantity if successful, else undefined.
self.gather_resource = function(gatherer_instance_id) {
    // Check if the entity_data struct exists (it should, due to validation above).
    if (is_undefined(self.entity_data)) { // Redundant check if Create event validation is thorough, but safe.
        debug_log("Error (obj_resource_node_controller:Gather): self.entity_data is undefined. Node not properly initialized.", "ResourceNode:Gather", "red");
        return undefined;
    }

    var _node_profile_for_gather = self.entity_data; // Use the validated entity_data
    var _node_name_for_gather = variable_struct_exists(_node_profile_for_gather, "display_name_concept") ? _node_profile_for_gather.display_name_concept : string(self.entity_type_id);

    if (self.is_depleted) {
        debug_log("Node '" + _node_name_for_gather + "' is depleted. Cannot gather.", "ResourceNode:Gather", "orange");
        return undefined;
    }

    // TODO: Add checks for tool_required_tag against gatherer's capabilities/inventory
    // TODO: Add checks for harvest_skill_tag for skill checks/XP gain

    var _gathered_amount = min(self.current_yield, self.yield_per_gather);
    
    if (_gathered_amount > 0) {
        self.current_yield -= _gathered_amount;
        var _item_name_gathered_for_debug = "Unknown Item";
        if (!is_undefined(self.yielded_item_profile) && variable_struct_exists(self.yielded_item_profile, "display_name_key")) {
            _item_name_gathered_for_debug = self.yielded_item_profile.display_name_key;
        }
        debug_log("Gathered " + string(_gathered_amount) + " of item '" + _item_name_gathered_for_debug + "' from '" + _node_name_for_gather + "'. Remaining: " + string(self.current_yield), "ResourceNode:Gather", "cyan");

        if (self.current_yield <= 0) {
            self.is_depleted = true;
            debug_log("Node '" + _node_name_for_gather + "' is now depleted.", "ResourceNode:Gather", "orange");
            
            // Handle depletion:
            // 1. Change sprite to depleted version
            if (variable_struct_exists(_node_profile_for_gather, "sprite_info") && is_struct(_node_profile_for_gather.sprite_info) && variable_struct_exists(_node_profile_for_gather.sprite_info, "depleted")) {
                var _depleted_sprite_name = _node_profile_for_gather.sprite_info.depleted;
                if (is_string(_depleted_sprite_name) && asset_exists(_depleted_sprite_name)) {
                    sprite_index = asset_get_index(_depleted_sprite_name);
                } else {
                    debug_log("Node '" + _node_name_for_gather + "' depleted, but sprite_info.depleted '" + string(_depleted_sprite_name) + "' is not a valid sprite asset.", "ResourceNode:Gather", "yellow");
                }
            } else {
                 debug_log("Node '" + _node_name_for_gather + "' depleted, but no 'sprite_info.depleted' found in profile.", "ResourceNode:Gather", "yellow");
            }

            // 2. Start regeneration if applicable
            if (self.regeneration_time_seconds > 0) {
                self.is_regenerating = true;
                self.current_regeneration_timer = self.regeneration_time_seconds;
                debug_log("Node '" + _node_name_for_gather + "' starting regeneration (" + string(self.regeneration_time_seconds) + " seconds).", "ResourceNode:Gather", "yellow");
            }
        }
        
        return {
            item_profile: self.yielded_item_profile, 
            quantity: _gathered_amount
        };
    }
    return undefined;
};
