// scr_database.gml (or scr_gamedata_init.gml)
// Purpose: Initializes the global.GameData structure, serving as the central
//          database for all static game definitions in Lineage: Ancestral Legacies.
//          This script should be run once at the very start of the game.

// Ensure prerequisite enums and entity definitions are loaded first.
scr_constants(); // Defines global enums like FormationType, EntityState, etc.

show_debug_message("Initializing scr_database: Populating global.GameData...");

// -----------------------------------------------------------------------------
// Optional: ID Enum (Flat enum for convenience, maps to GameData paths)
// -----------------------------------------------------------------------------
enum ID {
    // Entity Profiles - Pops
    POP_GEN1,
    POP_GEN2,
    POP_GEN3,
    POP_GEN4,
    POP_ROLE_HUNTER, // Example Role

    // Entity Profiles - Animals
    ANIMAL_WOLF,
    ANIMAL_DEER,

    // Entity Profiles - Structures
    STRUCTURE_TOOL_HUT_BASIC,
    STRUCTURE_STORAGE_PIT,
    STRUCTURE_FIRE_PIT,

    // Entity Profiles - Resource Nodes
    NODE_FLINT_DEPOSIT,
    NODE_BERRY_BUSH_RED,

    // Entity Profiles - Hazards
    HAZARD_QUICKSAND,
    HAZARD_ROCKSLIDE_TRIGGER,

    // Item Profiles
    ITEM_FLINT,
    ITEM_STICK,
    ITEM_STONE_AXE,
    ITEM_RAW_MEAT,
    ITEM_COOKED_MEAT,
    ITEM_BERRY_RED,


    // Recipe Profiles
    RECIPE_STONE_AXE,
    RECIPE_COOKED_MEAT,

    // Trait Profiles
    TRAIT_KEEN_EYES,
    TRAIT_STRONG_BACK,
    TRAIT_PRIMITIVE_CRAFTER,
    TRAIT_FIRE_KEEPER,
    TRAIT_QUICK_LEARNER,

    // Skill Profiles
    SKILL_FORAGING,
    SKILL_CRAFTING_PRIMITIVE,
    SKILL_HUNTING_BASIC,
    SKILL_FIRE_MAKING
}

// -----------------------------------------------------------------------------
// global.GameData Definition
// -----------------------------------------------------------------------------
global.GameData = {};

// =============================================================================
// SECTION: SPAWN FORMATIONS
// =============================================================================
global.GameData.SpawnFormations = {
    Type: { // Enum-like struct for formation types
        SINGLE_POINT: 0,
        CLUSTERED: 1,
        LINE: 2,
        GRID: 3,
        PACK_SCATTER: 4 // For more organic animal groups
    },
    // Default parameters for formations could be defined here too if desired,
    // or they can live within the entity profiles that use them by default.
    // Example:
    // DefaultParams: {
    //     CLUSTERED: { default_radius: 50, default_min_spacing: 16, default_attempts_per_entity: 5 },
    //     PACK_SCATTER: { default_radius: 80, default_min_spacing: 32, default_attempts_per_entity: 3 }
    // }
};

// =============================================================================
// SECTION: MOVEMENT EFFECTS (NEW)
// =============================================================================
global.GameData.MovementEffects = {
    Type: { // Enum-like struct for movement effect types
        NONE: 0,
        SLOWED_MILD: 1,
        SLOWED_MODERATE: 2,
        SLOWED_SEVERE: 3,
        IMPASSABLE_TEMPORARY: 4, // e.g., a fallen tree that might be cleared
        IMPASSABLE_TRAPPED: 5,   // e.g., quicksand, tar pit
        IMPASSABLE_SOLID: 6,     // e.g., cliff wall
        HASTENED_MILD: 7,
        SLIPPERY: 8
        // ... more movement altering effects
    },
    // Profiles for specific movement effects could be defined here if they need more data
    // than just an enum, e.g.:
    // Profiles: {
    //     SLOWED_MUD: { type_enum: global.GameData.MovementEffects.Type.SLOWED_MODERATE, speed_multiplier: 0.5, visual_effect: "vfx_mud_splash" }
    // }
};

// =============================================================================
// SECTION: STATUS EFFECTS (NEW - Placeholder, expand as needed)
// =============================================================================
global.GameData.StatusEffects = {
    Type: { // Enum-like struct for status effect types
        POISONED: 0,
        BLEEDING: 1,
        STUNNED: 2,
        BURNING: 3,
        FROZEN: 4,
        SINKING: 5, // For Quicksand
        // ... more status effects
    },
    // Profiles for specific status effects could be defined here, e.g.:
    // Profiles: {
    //     POISON_WEAK: { type_enum: global.GameData.StatusEffects.Type.POISONED, dps: 1, duration: 10, stat_modifiers: [{stat:"STR", mod: -2}] }
    // }
};

// =============================================================================
// SECTION: HAZARD TRIGGER TYPES (NEW - Placeholder, expand as needed)
// =============================================================================
global.GameData.Hazards = {
    TriggerType: {
        PROXIMITY_ENTER: 0, // Triggers when an entity enters the AoE
        PROXIMITY_STAY: 1,  // Triggers repeatedly while an entity is in the AoE
        ON_INTERACT: 2,     // Triggers when an entity interacts with the hazard object
        TIMED_EVENT: 3,     // Triggers after a certain time or at specific game events
        DAMAGE_RECEIVED: 4  // e.g., a crystal that shatters and explodes when damaged
        // ... more trigger types
    }
    // Other hazard-related enums or data can go here
};

// =============================================================================
// SECTION: SKILLS
// =============================================================================
global.GameData.Skills = {
    Type: { // Enum-like struct for skill types
        FORAGING: 0,
        CRAFTING_PRIMITIVE: 1,
        HUNTING_BASIC: 2,
        FIRE_MAKING: 3,
        CONSTRUCTION_BASIC: 4,
        SOCIAL_COMMUNICATION: 5,
        // ... more skills
    },
    Profiles: {} // Will be populated below
};

global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.FORAGING] = {
    skill_id_enum: global.GameData.Skills.Type.FORAGING,
    display_name_key: "skill_name_foraging",
    description_key: "skill_desc_foraging",
    max_level: 100,
    xp_curve_id: "CURVE_STANDARD" // ID to look up an XP curve formula
};
global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.CRAFTING_PRIMITIVE] = {
    skill_id_enum: global.GameData.Skills.Type.CRAFTING_PRIMITIVE,
    display_name_key: "skill_name_crafting_primitive",
    description_key: "skill_desc_crafting_primitive",
    max_level: 100,
    xp_curve_id: "CURVE_STANDARD"
};
// ... Add other skill profiles

// =============================================================================
// SECTION: TRAITS
// =============================================================================
global.GameData.Traits = {
    Type: { // Enum-like struct for trait categories or specific trait IDs if preferred
        PHYSICAL: 0,
        MENTAL: 1,
        SOCIAL: 2,
        // Specific Traits if not categorizing heavily here
        KEEN_EYES_ID: 100,
        STRONG_BACK_ID: 101,
        PRIMITIVE_CRAFTER_ID: 102,
        FIRE_KEEPER_ID: 103,
        QUICK_LEARNER_ID: 104,
    },
    Profiles: {} // Will be populated below
};

global.GameData.Traits.Profiles[$ ID.TRAIT_KEEN_EYES] = { // Using ID for keying trait profiles
    trait_id_enum: global.GameData.Traits.Type.KEEN_EYES_ID, // The internal ID
    display_name_key: "trait_name_keen_eyes",
    description_key: "trait_desc_keen_eyes",
    effects: [{ stat_to_modify: "perception_radius_pixels", modifier_type: "ADD", value: 20 }],
    category_enum: global.GameData.Traits.Type.PHYSICAL,
    tags: ["perception", "sensory"]
};
global.GameData.Traits.Profiles[$ ID.TRAIT_STRONG_BACK] = {
    trait_id_enum: global.GameData.Traits.Type.STRONG_BACK_ID,
    display_name_key: "trait_name_strong_back",
    description_key: "trait_desc_strong_back",
    effects: [{ stat_to_modify: "base_carrying_capacity", modifier_type: "MULTIPLY", value: 1.25 }], // 25% more capacity
    category_enum: global.GameData.Traits.Type.PHYSICAL,
    tags: ["physical", "strength", "hauling"]
};
global.GameData.Traits.Profiles[$ ID.TRAIT_PRIMITIVE_CRAFTER] = {
    trait_id_enum: global.GameData.Traits.Type.PRIMITIVE_CRAFTER_ID,
    display_name_key: "trait_name_primitive_crafter",
    description_key: "trait_desc_primitive_crafter",
    effects: [{ skill_to_modify_enum: global.GameData.Skills.Type.CRAFTING_PRIMITIVE, modifier_type: "BONUS_LEVEL", value: 5 }],
    category_enum: global.GameData.Traits.Type.MENTAL,
    tags: ["crafting", "skill_related"]
};
// ... Add other trait profiles

// =============================================================================
// SECTION: ITEMS
// =============================================================================
global.GameData.Items = {
    Resource: {},
    Tool: {},
    Food: {},
    Apparel: {}
};

global.GameData.Items.Resource.FLINT = {
    item_id_string: "ITEM_RESOURCE_FLINT",
    display_name_key: "item_name_flint",
    description_key: "item_desc_flint",
    sprite_inventory: "spr_item_icon_flint", // Store sprite name as a string
    max_stack_size: 50,
    tags: ["resource", "stone", "crafting_material", "tool_component", "sharp"],
    value_barter_base: 2,
    weight_per_unit: 0.1
};

global.GameData.Items.Resource.BERRY_RED = {
    item_id_string: "ITEM_RESOURCE_BERRY_RED",
    display_name_key: "item_name_berry_red",
    description_key: "item_desc_berry_red",
    sprite_inventory: "spr_item_icon_berry_red", // Store sprite name as a string
    max_stack_size: 50,
    tags: ["resource", "berry", "crafting_material", "food"],
    value_barter_base: 2,
    weight_per_unit: 0.02
};

global.GameData.Items.Resource.STICK = {
    item_id_string: "ITEM_RESOURCE_STICK",
    display_name_key: "item_name_stick",
    description_key: "item_desc_stick",
    sprite_inventory: "spr_item_icon_stick",
    max_stack_size: 100,
    tags: ["resource", "wood", "crafting_material", "fuel_basic"],
    value_barter_base: 1,
    weight_per_unit: 0.05
};

// Define WOOD_LOG and PLANT_FIBER before they are referenced
global.GameData.Items.Resource.WOOD_LOG = {
    item_id_string: "ITEM_RESOURCE_WOOD_LOG",
    display_name_key: "item_name_wood_log",
    description_key: "item_desc_wood_log",
    sprite_inventory: "spr_item_icon_wood_log", // Assuming this sprite exists
    max_stack_size: 20,
    tags: ["resource", "wood", "crafting_material", "construction_material", "fuel_good"],
    value_barter_base: 5,
    weight_per_unit: 2.0
};

global.GameData.Items.Resource.PLANT_FIBER = {
    item_id_string: "ITEM_RESOURCE_PLANT_FIBER",
    display_name_key: "item_name_plant_fiber",
    description_key: "item_desc_plant_fiber",
    sprite_inventory: "spr_item_icon_plant_fiber", // Assuming this sprite exists
    max_stack_size: 100,
    tags: ["resource", "plant", "crafting_material", "binding"],
    value_barter_base: 1,
    weight_per_unit: 0.03
};


// ... More items (RAW_MEAT etc. can be defined here or after Tool section)

global.GameData.Items.Tool.STONE_AXE = {
    item_id_string: "ITEM_TOOL_STONE_AXE",
    display_name_key: "item_name_stone_axe",
    description_key: "item_desc_stone_axe",
    sprite_inventory: "spr_item_icon_stone_axe",
    sprite_world_equipped: "spr_stone_axe_equipped", // For showing on pop - ensure this is a string
    max_stack_size: 1,
    tags: ["tool", "axe", "cutting", "woodcutting", "weapon_crude"],
    value_barter_base: 10,
    weight_per_unit: 1.5,
    durability_max: 100,
    tool_properties: {
        damage_bonus_melee: 5,
        gathering_bonus_wood: 1.5, // 50% faster wood gathering
        effective_against_tags: ["wood_source", "animal_small_hide"]
    }
};

// Define RAW_WOLF_MEAT and WOLF_PELT before they are referenced in LootTables
global.GameData.Items.Food.RAW_WOLF_MEAT = {
    item_id_string: "ITEM_FOOD_RAW_WOLF_MEAT",
    display_name_key: "item_name_raw_wolf_meat",
    description_key: "item_desc_raw_wolf_meat",
    sprite_inventory: "spr_item_icon_raw_meat", // Generic raw meat icon or specific
    max_stack_size: 10,
    tags: ["food", "meat", "raw", "wolf_product", "cookable"],
    value_barter_base: 4,
    weight_per_unit: 0.5,
    // Food-specific properties
    nutrition_value: 30, // Example value
    spoilage_rate_modifier: 1.5 // Spoils faster than some other foods
};

global.GameData.Items.Resource.WOLF_PELT = {
    item_id_string: "ITEM_RESOURCE_WOLF_PELT",
    display_name_key: "item_name_wolf_pelt",
    description_key: "item_desc_wolf_pelt",
    sprite_inventory: "spr_item_icon_wolf_pelt", // Assuming this sprite exists
    max_stack_size: 5,
    tags: ["resource", "pelt", "animal_product", "crafting_material", "clothing_material"],
    value_barter_base: 15,
    weight_per_unit: 1.0
};


// =============================================================================
// SECTION: LOOT TABLES
// =============================================================================
// This section defines the actual data for loot tables. Each key (e.g., WOLF)
// corresponds to a specific loot table profile that entities can reference.
// The loot system will use these profiles to determine drops.
global.GameData.LootTables = {}; // Initialize as an empty struct

// --- Loot Table: WOLF ---
// Defines the items dropped by a wolf.
global.GameData.LootTables.WOLF = {
    loot_table_id_string: "LOOT_WOLF_STANDARD", // A unique identifier string for this loot table.
    description: "Standard loot dropped by a grey wolf.",
    // 'entries' is an array of structs, each defining a potential item drop.
    // - item_profile_ref: A direct reference to the item's definition in global.GameData.Items.
    // - min_quantity: The minimum number of this item to drop if selected.
    // - max_quantity: The maximum number of this item to drop if selected.
    // - chance: The probability (0.0 to 1.0) of this specific entry dropping.
    //           Each entry is rolled independently.
    entries: [
        { 
            item_profile_ref: global.GameData.Items.Food.RAW_WOLF_MEAT, 
            min_quantity: 1, 
            max_quantity: 2, 
            chance: 0.80 // 80% chance to drop 1-2 raw wolf meat
        },
        { 
            item_profile_ref: global.GameData.Items.Resource.WOLF_PELT,  
            min_quantity: 1, 
            max_quantity: 1, 
            chance: 0.60 // 60% chance to drop 1 wolf pelt
        }
        // TODO: Add other potential drops like 'wolf_fang' or 'wolf_bone' items
        // once they are defined in the global.GameData.Items section.
    ]
};

// Example for adding another loot table (e.g., for a DEER):
// global.GameData.LootTables.DEER = {
//     loot_table_id_string: "LOOT_DEER_STANDARD",
//     description: "Standard loot dropped by a deer.",
//     entries: [
//         // Assuming global.GameData.Items.Food.RAW_VENISON and global.GameData.Items.Resource.DEER_HIDE are defined
//         //{ item_profile_ref: global.GameData.Items.Food.RAW_VENISON, min_quantity: 2, max_quantity: 3, chance: 0.90 },
//         //{ item_profile_ref: global.GameData.Items.Resource.DEER_HIDE, min_quantity: 1, max_quantity: 1, chance: 0.70 }
//     ]
// };

// =============================================================================
// SECTION: BEHAVIOR AND AI
// =============================================================================



// =============================================================================
// SECTION: ENTITY PROFILES
// =============================================================================
global.GameData.Entity = {
    Pop: {},
    Animal: { Predator: {}, Herbivore: {}, Domesticated: {}, Tamable: {} },
    Structure: { Functional: {}, Storage: {}, Defensive: {}, Ritual: {} },
    ResourceNode: {},
    Hazard: { AreaEffect: {}, EventBased: {} }
};

// --- Entity.Pop Profiles ---
global.GameData.Entity.Pop.GEN1 = {
    // --- Core Identification & Classification ---
    ID: 1, // Unique numerical ID for this profile (optional, if you use it)
    profile_id_string: "POP_GEN1_PIONEERS", // Descriptive unique string ID
    name_display_type: "Hominid (Gen 1)", // Display name for this TYPE of pop.
                                        // Individual instance names (e.g., "Uga", "Groka")
                                        // will be generated randomly at spawn time.
    type_tag: "Hominid",    // Broad category
    species_concept: "Early Hominid (Habilis-inspired)", // Anthropological inspiration

    // --- Spawning & Visuals ---
    object_to_spawn: obj_pop, // The GameMaker object asset to instance
    // Sprite information will now be structured to support sex-specific sprites.
    // The actual sprite (e.g., spr_pop_man_idle, spr_pop_woman_idle) will be chosen
    // by the obj_pop's initialize_from_profile method based on the instance's assigned sex.
    sprite_info: {
        male_idle: "spr_pop_man_idle", // Store sprite name as a string
        female_idle: "spr_pop_woman_idle", // Store sprite name as a string
        male_walk_prefix: "spr_pop_man_gen1_walk_", 
        female_walk_prefix: "spr_pop_woman_gen1_walk_",
        male_portrait: "spr_pop_man_gen1_portrait", // Store sprite name as a string
        female_portrait: "spr_pop_woman_gen1_portrait", // Store sprite name as a string
        // Consider: attack_prefix, gather_prefix, craft_prefix, death_sprite for both sexes
    },
    base_scale: 1.0,
    // Default sex assignment can be 50/50 or weighted if desired.
    // The instance will determine its actual sex in its initialize_from_profile method.
    // This profile field can indicate typical sex distribution or be used if not randomizing.
    // For now, we'll let obj_pop handle the 50/50 randomization.

    // --- Ability Score RANGES (for randomization at instance creation) ---
    AbilityScoreRanges: {
        Strength:     { min: 8,  max: 12 }, // Physical power
        Dexterity:    { min: 6,  max: 10 }, // Agility, coordination
        Constitution: { min: 10, max: 14 }, // Health, resilience
        Intelligence: { min: 4,  max: 8  }, // Problem-solving, learning basic tools
        Wisdom:       { min: 5,  max: 9  }, // Environmental awareness, basic foresight
        Charisma:     { min: 3,  max: 7  }  // Basic social interaction
    },

    // --- Base Stats & Formulas (Static definitions for the type) ---
    // Instance-specific runtime stats (current_health, current_stamina, actual_carrying_capacity)
    // will be derived from these bases and the instance's rolled AbilityScores at spawn time.
    StatsBase: {
        Health: {
            base_max: 75 // Starting point for max health calculation
            // This can be modified by the instance's rolled Constitution.
            // Example: instance_max_health = base_max + (rolled_constitution - 10) * 5
        },
        Stamina: {
            base_max: 80 // Starting point for max stamina
            // Can be modified by Constitution/Dexterity.
        },
        Speed: { // Typically static for the type, but could have slight variance
            walk: 1.7, // units per second
            run: 2.5
        },
        Perception: {
            base_radius: 120 // pixels
            // Can be modified by Wisdom/Traits.
        },
        // Defines HOW max carrying capacity is calculated, not a fixed value.
        carrying_capacity_formula: {
            base_value: 0, // A flat base if any
            strength_multiplier: 2 // e.g., max_carry = base + (rolled_strength * multiplier)
        }
    },

    // --- Behavioral & Gameplay Tags ---
    tags: ["hominid", "pop", "gen1", "pioneer", "scavenger", "simple_tools", "early_game"],
    diet_type_tags: ["omnivorous_opportunistic", "eats_berries", "eats_roots", "scavenges_meat_small"],

    // --- Skill Aptitudes (How well they learn or their starting inclination) ---
    // These are base values; actual skill levels are per instance.
    // The scale (e.g., 1-10) depends on your skill system design.
    base_skill_aptitudes: {}, // Initialize as an empty struct first
    // Then populate using enum keys with the $ accessor
    // (This section will be populated immediately after the GEN1 struct definition)

    // --- Innate Traits (References to Trait Profiles in GameData.Traits.Profiles) ---
    innate_trait_profile_paths: [ // Array of paths to full trait profiles
        // Example: "ID.Trait.CURIOUS_MIND_LOW"
        // These should be string identifiers that GetProfileFromID can resolve.
        // Add actual string paths here, e.g.:
        // "ID.Trait.KEEN_EYES", // Assuming ID.Trait.KEEN_EYES is a string path
        // "ID.Trait.STRONG_BACK"  // Or however your ID strings are formatted
    ],

    // --- AI & Faction ---
    default_ai_behavior_package_id: "AI_POP_GEN1_SURVIVALIST", // ID for AI controller logic
    faction_default_id: "FACTION_PLAYER_TRIBE_DAWN", // Default faction alignment

    // --- World Generation & Default Spawning Parameters ---
    default_spawn_amount_range: { min: 3, max: 6 },
    default_spawn_formation_type: global.GameData.SpawnFormations.Type.CLUSTERED, // Enum value
    default_formation_params: { // Parameters for its preferred CLUSTERED formation
        radius: 40,
        min_spacing_from_others: 20, // Min distance between spawned entities
        attempts_per_entity: 8      // How many times to try placing before giving up (for dense areas)
    },

    // --- Behavior Settings (NEW) ---
    // Defines default values for various AI behavior timers and parameters.
    // These can be overridden by instance logic or specific AI states.
    behavior_settings: {
        idle_min_seconds: 2.0,          // Minimum time (in seconds) an instance will idle.
        idle_max_seconds: 4.0,          // Maximum time (in seconds) an instance will idle.
        after_command_idle_seconds: 0.5,// Short idle time after completing a direct command.
        wander_min_points: 1,           // Minimum number of waypoints in a single wander sequence.
        wander_max_points: 3,           // Maximum number of waypoints in a single wander sequence.
        wander_min_distance_pixels: 50, // Minimum distance for a single wander leg.
        wander_max_distance_pixels: 150 // Maximum distance for a single wander leg.
        // Add other behavior-related settings here as needed, e.g.:
        // forage_duration_seconds: 10,
        // social_interaction_chance: 0.1,
        // flee_health_threshold_percent: 0.25
    },

    // --- Other Information ---
    loot_table_profile_path: undefined, // Path to a loot table in GameData.LootTables (e.g., global.GameData.LootTables.HOMINID_GEN1)
    tool_use_level_tags: ["opportunistic_found_tools", "basic_stone_choppers_simple"], // e.g., Oldowan-like
    fire_use_level_tags: ["fire_aware_natural_sources", "no_fire_making_skill"],
    shelter_preference_tags: ["natural_cave_basic", "rock_overhang"]
};

// Populate base_skill_aptitudes for GEN1 using enum keys
global.GameData.Entity.Pop.GEN1.base_skill_aptitudes[$ global.GameData.Skills.Type.FORAGING] = 4;
global.GameData.Entity.Pop.GEN1.base_skill_aptitudes[$ global.GameData.Skills.Type.CRAFTING_PRIMITIVE] = 3;
// global.GameData.Entity.Pop.GEN1.base_skill_aptitudes[$ global.GameData.Skills.Type.SCAVENGING] = 4; Assuming SCAVENGING is defined in Skills.Type

global.GameData.Entity.Pop.GEN1.base_skill_aptitudes[$ global.GameData.Skills.Type.SOCIAL_COMMUNICATION] = 3;


#region --- Entity.Animal Profiles ---
global.GameData.Entity.Animal.Predator.WOLF = {
    profile_id_string: "ANIMAL_WOLF_GREY",
    display_name_concept: "Grey Wolf",
    object_to_spawn: obj_creature_ai_controller, // Changed from obj_animal_wolf
    sprite_info: {default: "spr_wolf_idle", walk_prefix: "spr_wolf_walk_" }, // Store sprite name as a string
    base_max_health: 70,
    base_speed_walk: 3.5,
    base_speed_run: 6.0,
    base_attack_damage: 12,
    attack_range: 32,
    tags: ["animal", "predator", "carnivore", "canine", "pack_hunter"],
    diet_type_tags: ["carnivore_hunts_deer_boar"],
    default_ai_behavior_package_id: "AI_ANIMAL_WOLF_PACK_HUNTER",
    faction_default_id: "FACTION_WILDLIFE_PREDATOR",
    default_spawn_amount_range: { min: 2, max: 5 },
    default_spawn_formation_type: global.GameData.SpawnFormations.Type.PACK_SCATTER,
    default_formation_params: { radius: 100, min_spacing_from_others: 40, attempts_per_entity: 5 },
    loot_table_profile_path: global.GameData.LootTables.WOLF // Path to where loot tables will be defined
};

// --- Entity.Structure Profiles ---
global.GameData.Entity.Structure.Functional.TOOL_HUT_BASIC = {
    profile_id_string: "STRUCTURE_TOOL_HUT_BASIC",
    display_name_concept: "Basic Tool Hut",
    object_to_spawn: obj_structure_controller, // Generic structure controller
    sprite_info: { default: "spr_tool_hut_basic" }, // Store sprite name as a string
    base_max_health: 200,
    is_destructible: true,
    tags: ["structure", "crafting_station", "tools", "functional"],
    build_materials_cost: [ // Array of { item_profile_path: ..., quantity: ... }
        { item_profile_path: global.GameData.Items.Resource.WOOD_LOG, quantity: 10 },
        { item_profile_path: global.GameData.Items.Resource.PLANT_FIBER, quantity: 5 }
    ],
    build_time_seconds: 60,
    worker_slots_max: 1,
    supported_recipe_tags: ["stone_tools_basic", "wood_tools_simple"], // Tags for recipes craftable here
    // Other structure-specific properties from the Idea Document...
    inventory_capacity: 10, // Small internal storage for crafting
    provided_buffs: [{ buff_type: "CRAFTING_SPEED_PRIMITIVE", value: 0.1, radius: 0 }] // 10% speed boost if working at it
};

// --- Entity.ResourceNode Profiles ---
global.GameData.Entity.ResourceNode.FLINT_DEPOSIT = {
    profile_id_string: "NODE_FLINT_DEPOSIT",
    display_name_concept: "Flint Deposit",
    object_to_spawn: obj_resource_node_controller, // Generic node controller
    sprite_info: { default: "spr_flint_deposit_full", depleted: "spr_flint_deposit_empty" }, // Store sprite names as strings
    base_max_health: 50, // "Health" of the node, i.e., how much can be gathered
    is_destructible: true, // Depletes
    tags: ["resource_node", "stone", "flint", "gatherable"],
    yielded_item_profile_path: global.GameData.Items.Resource.FLINT,
    yield_amount_per_gather_action: irandom_range(1,3),
    gather_time_per_action_seconds: 5,
    required_tool_tags: ["tool_pickaxe_crude", "tool_hammerstone"], // Optional: tags of tools that are effective
    respawn_time_seconds: -1 // -1 for no respawn, or time in seconds
};

// --- Entity.Hazard Profiles ---
global.GameData.Entity.Hazard.AreaEffect.QUICKSAND = {
    profile_id_string: "HAZARD_QUICKSAND",
    display_name_concept: "Quicksand Pit",
    object_to_spawn: obj_hazard_controller, // Generic hazard controller
    // ... properties from the hazard idea document:
    hazard_category_tag: "TerrainTrap",
    tags: ["movement_impairing", "dangerous_terrain"],
    damage_type_enum: undefined, // Or a suffocation damage type
    damage_on_enter_amount: 0,
    status_effects_applied: [{ effect_enum: global.GameData.StatusEffects.Type.SINKING, potency: 0.1, duration_seconds_on_entity: -1 }], // -1 while in
    area_of_effect_shape_enum: global.GameData.SpawnFormations.Type.SINGLE_POINT, // Visually might be a decal/area
    area_dimensions: { radius: 64 }, // Example
    trigger_condition_enum: global.GameData.Hazards.TriggerType.PROXIMITY_ENTER, // Need to define these enums
    is_temporary: false,
    lifespan_seconds_active: -1,
    movement_modifier_enum: global.GameData.MovementEffects.Type.IMPASSABLE_TRAPPED // Need to define
    // ... visual and audio properties
};
#endregion


// =============================================================================
// SECTION: RECIPES
// =============================================================================
// Assign the frequently accessed skill profile to a temporary variable
var _crafting_skill_profile_ref = undefined;
if (is_struct(global.GameData.Skills.Profiles) && variable_struct_exists(global.GameData.Skills.Profiles, string(global.GameData.Skills.Type.CRAFTING_PRIMITIVE))) {
    // Corrected: Use the $ accessor for enum/integer keys with structs.
    // This was causing the "trying to index a variable which is not an array" error.
    // The $ accessor converts the enum value (which is an integer) to its string representation
    // for the struct lookup, matching how it was stored (e.g., Profiles[$ 1] = ...).
    _crafting_skill_profile_ref = global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.CRAFTING_PRIMITIVE];
} else {
    // It's good practice to log an error if a critical reference cannot be established.
    // This helps in debugging if recipes fail to load or behave unexpectedly.
    show_debug_message("ERROR (scr_database): Could not assign _crafting_skill_profile_ref for recipes. global.GameData.Skills.Profiles might be invalid or the CRAFTING_PRIMITIVE key is missing.");
}

global.GameData.Recipes = {};

/// @desc Recipe definition for crafting a Stone Axe.
/// @educational
/// This struct defines all the data needed for the crafting system to allow players to create a Stone Axe.
/// Each property is explained below to help beginners understand how recipes work in this project.

global.GameData.Recipes[$ ID.RECIPE_STONE_AXE] = { // Keyed by ID for convenience
    recipe_id_string: "RECIPE_TOOL_STONE_AXE", // Unique string ID for this recipe (used for lookups and debugging)
    display_name_key: "recipe_name_stone_axe", // Localization key for the recipe's display name
    produces_item_profile_path: global.GameData.Items.Tool.STONE_AXE, // Reference to the item profile this recipe creates
    produces_quantity: 1, // Number of items produced per craft
    ingredients: [
        // Each ingredient is a struct with a reference to the item profile and the required quantity
        { item_profile_path: global.GameData.Items.Resource.FLINT, quantity: 2 }, // Requires 2 flint
        { item_profile_path: global.GameData.Items.Resource.STICK, quantity: 1 }  // Requires 1 stick
    ],
    base_crafting_time_seconds: 15, // How long crafting takes (in seconds) before any skill or station modifiers
    required_skill_profile: {
        skill_profile_path: _crafting_skill_profile_ref, // Use temporary variable
        min_level_required: 1 // Minimum skill level required to craft this recipe
    },
    required_crafting_station_tags: ["crafting_surface_basic", "tool_making_spot"], // Tags for stations where this recipe can be crafted (e.g., flat rock, work stump)
    xp_reward_skill_path: _crafting_skill_profile_ref, // Use temporary variable
    xp_reward_amount: 8 // Amount of XP awarded for crafting this item
    // This structure makes it easy to add more recipes and ensures consistency across all crafting data.
};
// ... More recipes

// -----------------------------------------------------------------------------
// Helper Function: GetProfileFromID (Maps ID enum to GameData paths)
// -----------------------------------------------------------------------------
function GetProfileFromID(id_enum) { // Parameter is id_enum
    // Corrected: Changed 'uid_enum' to 'id_enum' to match the function parameter.
    // This ensures the switch statement correctly uses the provided ID.
    switch (id_enum) {
        // Entity Profiles
        case ID.POP_GEN1: return global.GameData.Entity.Pop.GEN1;
        // case ID.POP_ROLE_HUNTER: return global.GameData.Entity.Pop.Role.HUNTER; // Assuming Role path

        case ID.ANIMAL_WOLF: return global.GameData.Entity.Animal.Predator.WOLF;
        // ... many more mappings for all ID members ...

        // Item Profiles
        case ID.ITEM_FLINT: return global.GameData.Items.Resource.FLINT;
        case ID.ITEM_STICK: return global.GameData.Items.Resource.STICK;
        case ID.ITEM_STONE_AXE: return global.GameData.Items.Tool.STONE_AXE;

        // Recipe Profiles
        case ID.RECIPE_STONE_AXE: return global.GameData.Recipes[ID.RECIPE_STONE_AXE]; // Recipes keyed by ID

        // Trait Profiles
        case ID.TRAIT_KEEN_EYES: return global.GameData.Traits.Profiles[ID.TRAIT_KEEN_EYES];

        // Skill Profiles
        case ID.SKILL_FORAGING: return global.GameData.Skills.Profiles[global.GameData.Skills.Type.FORAGING];


        default:
            // Corrected: Changed 'uid_enum' to 'id_enum' for accurate debugging.
            show_debug_message($"ERROR (GetProfileFromID): Unhandled ID enum: {id_enum}");
            return undefined;
    }
}


show_debug_message("global.GameData populated successfully in scr_database. Version with GEN1-4 Pops.");