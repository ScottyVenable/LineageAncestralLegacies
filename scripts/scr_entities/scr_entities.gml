/// scr_entities.gml
///
/// Purpose:
///    Defines the EntityType enum and provides the function get_entity_data()
///    to retrieve base data (stats, behaviors, etc.) for all defined entity types.
///
/// Metadata:
///   Summary:       EntityType enumerations and base entity data definitions.
///   Usage:         Enum EntityType is global. Call get_entity_data(EntityType.ENUM_VALUE) anywhere.
///   Tags:          [data][entities][database][definitions][enums][ai]
///   Version:       1.0 - [Current Date]
///   Dependencies:  Sprite assets (e.g., spr_pop_male, spr_deer), PopState enum (for default states)

// ============================================================================
// 1. ENTITY TYPE ENUMERATION
// ============================================================================
#region 1.1 EntityType Enum Definition
enum EntityType {
    NONE,

    // Playable / Domesticated (or to be)
    POP_HOMINID, // Our main pop type

    // Wildlife - Herbivores
    DEER,
    RABBIT,
    WILD_BOAR,

    // Wildlife - Predators
    WOLF,
    SABERTOOTH_CAT,
    DIRE_BEAR, // Example

    // Mythical / Special (Future examples)
    // ANCIENT_GUARDIAN,
    // SPIRIT_WISP,

    // Inanimate but interactable (if you want to define them this way)
    // RESOURCE_NODE_BERRY_BUSH, // Alternative to obj_redBerryBush if defining via data
}
show_debug_message("Enum 'EntityType' (scr_entities) Initialized.");
#endregion

// ============================================================================
// 2. ENTITY DATA ACCESS FUNCTION & DATABASE
// ============================================================================
#region 2.1 get_entity_data() Function

/// @function get_entity_data(entity_enum_id)
/// @description Returns a struct containing the base properties for the given entity type.
/// @param {enum.EntityType} entity_enum_id The enum ID of the entity.
/// @returns {Struct|undefined}
function get_entity_data(entity_enum_id) {
    static entity_database = __internal_init_entity_database(); 
    
    if (struct_exists(entity_database, entity_enum_id)) {
        return entity_database[$ entity_enum_id];
    }
    show_debug_message($"Warning (get_entity_data): No data found for entity enum: {entity_enum_id}.");
    return undefined; 
}
#endregion

#region 2.2 __internal_init_entity_database() Helper Function

function __internal_init_entity_database() {
    show_debug_message("Initializing Entity Database (scr_entities)...");
    var _db = {}; 

    // --- POP_HOMINID ---
    _db[$ EntityType.POP_HOMINID] = {
        name: "Hominid Pop",
        description: "An early hominid, member of the player's tribe.",
        object_index: obj_pop, // The GameMaker object to spawn for this entity type
        default_sprite: spr_man_idle, // Or a base sprite if it changes
        base_health: 100,
        base_speed: 2,
		base_max_items_carried: 10,
        base_perception_radius: 150, // Pixels
        default_fsm_state: PopState.IDLE,
        faction: "PlayerTribe", // For AI interactions
        loot_table: undefined, // Pops typically don't drop loot on natural death this way
        can_evolve: true,
        can_form_relationships: true,
        tags: ["sentient", "tribal", "player_controlled_indirectly"]
    };



    //// --- DEER ---
    //_db[$ EntityType.DEER] = {
    //    name: "Deer",
    //    description: "A swift and timid herbivore.",
    //    object_index: obj_deer_ai, // You'd create an obj_deer_ai for its behavior
    //    default_sprite: spr_deer_idle,
    //    base_health: 50,
    //    base_speed: 3.5,
    //    base_perception_radius: 200,
    //    default_fsm_state: undefined, // obj_deer_ai would handle its own AI states
    //    faction: "Wildlife_Herbivore",
    //    loot_table: [ // Example loot: item enum and quantity chance
    //        { item: Item.FOOD_ROAST_MEAT, quantity_min: 2, quantity_max: 4, chance: 1.0 }, // Assuming meat needs processing
    //        { item: Item.MATERIAL_FLINT, quantity_min: 0, quantity_max: 1, chance: 0.2 } // Example: hide/bone as 'flint' placeholder
    //    ],
    //    behavior_type: "Prey", // For AI (flees from threats)
    //    tags: ["animal", "herbivore", "prey", "fast"]
    //};
    
    //// --- WOLF ---
    //_db[$ EntityType.WOLF] = {
    //    name: "Wolf",
    //    description: "A cunning pack hunter.",
    //    object_index: obj_wolf_ai, // You'd create an obj_wolf_ai
    //    default_sprite: spr_wolf_idle,
    //    base_health: 70,
    //    base_speed: 3.0,
    //    base_attack_damage: 8,
    //    base_perception_radius: 250,
    //    default_fsm_state: undefined,
    //    faction: "Wildlife_Predator",
    //    loot_table: [
    //         { item: Item.MATERIAL_FLINT, quantity_min: 1, quantity_max: 2, chance: 0.6 } // Example: pelt/teeth as 'flint'
    //    ],
    //    behavior_type: "Predator_Pack", // Hunts in packs
    //    tags: ["animal", "carnivore", "predator", "pack_animal"]
    //};

    //// ... ADD OTHER ENTITY DEFINITIONS ...

    show_debug_message($"Entity Database Initialized. {struct_names_count(_db)} entities defined.");
    return _db;
}
#endregion