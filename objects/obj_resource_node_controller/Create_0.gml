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
///    Version:         1.0 - YYYY-MM-DD
///    Dependencies:    scr_spawn_entity, scr_entities (get_entity_data)

// This controller instance expects entity_type and entity_data to be injected by scr_spawn_entity
// entity_type = undefined; // Example: EntityType.BERRY_BUSH_GENERIC_RED
// entity_data = undefined; // Struct containing all data from get_entity_data()

// Method to initialize the instance based on the provided entity_data
initialize_from_data = function() {
    // Ensure entity_data has been set by the spawner
    if (is_struct(entity_data)) {
        // Store the entity_data for easy access, if preferred
        // self.node_data = entity_data; // Or directly use entity_data.field

        // --- Core Properties ---
        // Set the sprite based on the entity data
        if (variable_struct_exists(entity_data, "default_sprite") && entity_data.default_sprite != undefined) {
            sprite_index = entity_data.default_sprite;
        } else {
            // Fallback sprite if none is defined in data (consider a placeholder sprite)
            sprite_index = spr_placeholder_resource; // Ensure spr_placeholder_resource exists
            debug_log($"Warning (obj_resource_node_controller): EntityType '{entity_type_to_string(entity_type)}' has no default_sprite defined. Using placeholder.", "ResourceNode:Init", "yellow");
        }
        
        // Set image speed, if applicable (e.g., for animated resources)
        if (variable_struct_exists(entity_data, "image_speed")) {
            image_speed = entity_data.image_speed;
        } else {
            image_speed = 0; // Default for static sprites
        }

        // --- Resource-Specific Properties ---
        // Max yield (how much can be gathered in total before depletion)
        self.max_yield = variable_struct_exists(entity_data, "max_yield") ? entity_data.max_yield : 100;
        self.current_yield = self.max_yield; // Start with full yield

        // Yield per gather action (how much is given per interaction)
        self.yield_per_gather = variable_struct_exists(entity_data, "yield_per_gather") ? entity_data.yield_per_gather : 1;
        
        // Item yielded (enum or string identifier for the item)
        self.item_yielded_enum = variable_struct_exists(entity_data, "item_yielded_enum") ? entity_data.item_yielded_enum : undefined; // e.g., ItemType.BERRIES_RED

        // Regeneration time (in game steps or seconds, if the node regenerates)
        // -1 or undefined could mean it does not regenerate
        self.regeneration_time_steps = variable_struct_exists(entity_data, "regeneration_time_steps") ? entity_data.regeneration_time_steps : -1; 
        self.current_regeneration_timer = 0;

        // Tool required to harvest (e.g., "axe", "pickaxe", "none")
        self.tool_required_tag = variable_struct_exists(entity_data, "tool_required_tag") ? entity_data.tool_required_tag : "none";
        
        // Skill associated with harvesting (e.g., "foraging", "mining", "woodcutting")
        self.harvest_skill_tag = variable_struct_exists(entity_data, "harvest_skill_tag") ? entity_data.harvest_skill_tag : "foraging";

        // Durability / Health (if the node can be "destroyed" or depleted through gathering)
        // This might be tied to max_yield or be a separate health pool.
        // For simplicity, we can tie it to current_yield. When current_yield is 0, it's depleted.

        // --- State Variables ---
        self.is_depleted = false;
        self.is_regenerating = false;

        // --- Debug Logging ---
        debug_log($"Resource Node Initialized: '{entity_data.name}' (Type: {entity_type_to_string(entity_type)}). Yield: {self.current_yield}/{self.max_yield} of {self.item_yielded_enum}. Regen: {self.regeneration_time_steps} steps.", "ResourceNode:Init", "green");

    } else {
        show_error("ERROR (obj_resource_node_controller): entity_data was not provided or is not a struct. Cannot initialize.", true);
        instance_destroy(); // Destroy self if no data
        return;
    }
};

// Note: The actual call to initialize_from_data() is expected to be made by scr_spawn_entity
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
    if (self.is_depleted) {
        debug_log($"Node '{self.entity_data.name}' is depleted. Cannot gather.", "ResourceNode:Gather", "orange");
        return undefined;
    }

    // TODO: Add checks for tool_required_tag against gatherer's capabilities/inventory
    // TODO: Add checks for harvest_skill_tag for skill checks/XP gain

    var _gathered_amount = min(self.current_yield, self.yield_per_gather);
    
    if (_gathered_amount > 0) {
        self.current_yield -= _gathered_amount;
        debug_log($"Gathered {_gathered_amount} of {self.item_yielded_enum} from '{self.entity_data.name}'. Remaining: {self.current_yield}", "ResourceNode:Gather", "cyan");

        if (self.current_yield <= 0) {
            self.is_depleted = true;
            debug_log($"Node '{self.entity_data.name}' is now depleted.", "ResourceNode:Gather", "orange");
            
            // Handle depletion:
            // 1. Change sprite to depleted version (if one exists in entity_data)
            if (variable_struct_exists(self.entity_data, "sprite_depleted") && self.entity_data.sprite_depleted != undefined) {
                sprite_index = self.entity_data.sprite_depleted;
            } else {
                // Option: self-destruct if not regenerating, or become non-interactive
                // instance_destroy(); 
            }

            // 2. Start regeneration if applicable
            if (self.regeneration_time_steps > 0) {
                self.is_regenerating = true;
                self.current_regeneration_timer = self.regeneration_time_steps;
                debug_log($"Node '{self.entity_data.name}' starting regeneration ({self.regeneration_time_steps} steps).", "ResourceNode:Gather", "yellow");
            }
        }
        
        return {
            item_enum: self.item_yielded_enum,
            quantity: _gathered_amount
        };
    }
    return undefined;
};

// --- Step Event (for regeneration) ---
// (This would typically be in the Step Event of obj_resource_node_controller)
/*
if (self.is_regenerating) {
    self.current_regeneration_timer--;
    if (self.current_regeneration_timer <= 0) {
        self.is_regenerating = false;
        self.is_depleted = false;
        self.current_yield = self.max_yield;
        
        // Change sprite back to normal
        if (variable_struct_exists(self.entity_data, "default_sprite") && self.entity_data.default_sprite != undefined) {
            sprite_index = self.entity_data.default_sprite;
        }
        debug_log($"Node '{self.entity_data.name}' has regenerated.", "ResourceNode:Step", "green");
    }
}
*/

// Make sure to add a Step Event to the obj_resource_node_controller object in GameMaker
// and move the regeneration logic there.
