// scr_database.gml (or scr_gamedata_init.gml)
// Purpose: Initializes the global.GameData structure, serving as the central
//          database for all static game definitions in Lineage: Ancestral Legacies.
//          This script should be run once at the very start of the game.

// Ensure prerequisite enums and entity definitions are loaded first.

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

    // Skill Profiles (aligned with EntitySkill enum and global.GameData.Skills.Type)
    SKILL_FORAGING,
    SKILL_FARMING,
    SKILL_MINING,
    SKILL_WOODCUTTING,
    SKILL_CRAFTING_GENERAL,
    SKILL_CRAFTING_WEAPONS,
    SKILL_CRAFTING_TOOLS,
    SKILL_CRAFTING_APPAREL,
    SKILL_CONSTRUCTION,
    SKILL_COOKING,
    SKILL_MEDICINE,
    SKILL_COMBAT_MELEE,
    SKILL_COMBAT_RANGED,
    SKILL_SOCIAL_CHARISMA,
    SKILL_RESEARCHING,
    SKILL_HAULING
}

// -----------------------------------------------------------------------------
// Helper Function: GetProfileFromID (Maps ID enum to GameData paths)
// -----------------------------------------------------------------------------
function GetProfileFromID(id_enum) { // Parameter is id_enum
    // Corrected: Changed 'uid_enum' to 'id_enum' to match the function parameter.
    // This ensures the switch statement correctly uses the provided ID.
    switch (id_enum) {
        // Entity Profiles - Pops
        case ID.POP_GEN1: return global.GameData.Entity.Pop.GEN1;
        // case ID.POP_GEN2: return global.GameData.Entity.Pop.GEN2; // Assuming GEN2 profile exists
        // case ID.POP_GEN3: return global.GameData.Entity.Pop.GEN3; // Assuming GEN3 profile exists
        // case ID.POP_GEN4: return global.GameData.Entity.Pop.GEN4; // Assuming GEN4 profile exists
        // case ID.POP_ROLE_HUNTER: return global.GameData.Entity.Pop.Role.HUNTER; // Assuming Role path, e.g., global.GameData.Entity.Pop.Roles.HUNTER

        // Entity Profiles - Animals
        case ID.ANIMAL_WOLF: return global.GameData.Entity.Animal.Predator.WOLF; // Assuming WOLF profile exists at this path
        // case ID.ANIMAL_DEER: return global.GameData.Entity.Animal.Herbivore.DEER; // Assuming DEER profile exists

        // Entity Profiles - Structures
        // case ID.STRUCTURE_TOOL_HUT_BASIC: return global.GameData.Entity.Structure.Functional.TOOL_HUT_BASIC; // Assuming structure profile exists
        // case ID.STRUCTURE_STORAGE_PIT: return global.GameData.Entity.Structure.Storage.STORAGE_PIT;
        // case ID.STRUCTURE_FIRE_PIT: return global.GameData.Entity.Structure.Functional.FIRE_PIT;

        // Entity Profiles - Resource Nodes
        // case ID.NODE_FLINT_DEPOSIT: return global.GameData.Entity.ResourceNode.FLINT_DEPOSIT; // Assuming node profile exists
        // case ID.NODE_BERRY_BUSH_RED: return global.GameData.Entity.ResourceNode.BERRY_BUSH_RED;

        // Entity Profiles - Hazards
        // case ID.HAZARD_QUICKSAND: return global.GameData.Entity.Hazard.AreaEffect.QUICKSAND; // Assuming hazard profile exists
        // case ID.HAZARD_ROCKSLIDE_TRIGGER: return global.GameData.Entity.Hazard.EventBased.ROCKSLIDE_TRIGGER;

        // Item Profiles
        case ID.ITEM_FLINT: return global.GameData.Items.Resource.FLINT;
        case ID.ITEM_STICK: return global.GameData.Items.Resource.STICK;
        case ID.ITEM_STONE_AXE: return global.GameData.Items.Tool.STONE_AXE;
        case ID.ITEM_RAW_MEAT: return global.GameData.Items.Food.RAW_WOLF_MEAT; // Example, assuming RAW_WOLF_MEAT is the generic raw meat for now
        // case ID.ITEM_COOKED_MEAT: return global.GameData.Items.Food.COOKED_MEAT; // Assuming COOKED_MEAT profile exists
        case ID.ITEM_BERRY_RED: return global.GameData.Items.Resource.BERRY_RED;


        // Recipe Profiles
        case ID.RECIPE_STONE_AXE: return global.GameData.Recipes[ID.RECIPE_STONE_AXE]; // Recipes keyed by ID
        // case ID.RECIPE_COOKED_MEAT: return global.GameData.Recipes[ID.RECIPE_COOKED_MEAT]; // Assuming recipe profile exists

        // Trait Profiles
        case ID.TRAIT_KEEN_EYES: return global.GameData.Traits.Profiles[ID.TRAIT_KEEN_EYES];
        case ID.TRAIT_STRONG_BACK: return global.GameData.Traits.Profiles[ID.TRAIT_STRONG_BACK];
        case ID.TRAIT_PRIMITIVE_CRAFTER: return global.GameData.Traits.Profiles[ID.TRAIT_PRIMITIVE_CRAFTER];
        // case ID.TRAIT_FIRE_KEEPER: return global.GameData.Traits.Profiles[ID.TRAIT_FIRE_KEEPER];
        // case ID.TRAIT_QUICK_LEARNER: return global.GameData.Traits.Profiles[ID.TRAIT_QUICK_LEARNER];

        // Skill Profiles (Aligned with the updated ID enum and global.GameData.Skills.Type)
        case ID.SKILL_FORAGING: return global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.FORAGING];
        case ID.SKILL_FARMING: return global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.FARMING];
        case ID.SKILL_MINING: return global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.MINING];
        case ID.SKILL_WOODCUTTING: return global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.WOODCUTTING];
        case ID.SKILL_CRAFTING_GENERAL: return global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.CRAFTING_GENERAL];
        case ID.SKILL_CRAFTING_WEAPONS: return global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.CRAFTING_WEAPONS];
        case ID.SKILL_CRAFTING_TOOLS: return global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.CRAFTING_TOOLS];
        case ID.SKILL_CRAFTING_APPAREL: return global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.CRAFTING_APPAREL];
        case ID.SKILL_CONSTRUCTION: return global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.CONSTRUCTION];
        case ID.SKILL_COOKING: return global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.COOKING];
        case ID.SKILL_MEDICINE: return global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.MEDICINE];
        case ID.SKILL_COMBAT_MELEE: return global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.COMBAT_MELEE];
        case ID.SKILL_COMBAT_RANGED: return global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.COMBAT_RANGED];
        case ID.SKILL_SOCIAL_CHARISMA: return global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.SOCIAL_CHARISMA];
        case ID.SKILL_RESEARCHING: return global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.RESEARCHING];
        case ID.SKILL_HAULING: return global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.HAULING];

        default:
            // Corrected: Changed 'uid_enum' to 'id_enum' for accurate debugging.
            debug_message($"ERROR (GetProfileFromID): Unhandled ID enum: {id_enum}");
            return undefined;
    }
}


debug_message("global.GameData populated successfully in scr_database. Version with GEN1-4 Pops.");

/// @function scr_database_init()
/// @description Initializes the global.GameData structure and all core game database categories. Call this once at game start.
function scr_database_init() {
    // -----------------------------------------------------------------------------
    // global.GameData Definition
    // -----------------------------------------------------------------------------
    global.GameData = {};

    // Pre-initialize top-level data categories to ensure they always exist as structs.
    // This prevents "variable not set" errors if scr_load_external_data_all fails to populate any of them.
    // The actual data will be loaded into these by scr_load_external_data_all.
    debug_message("scr_database: Pre-initializing global.GameData categories (items, name_data, etc.) as empty structs.");
    global.GameData.items = {};             // For item_data.json
    global.GameData.resource_nodes = {};  // For resource_node_data.json
    global.GameData.structures = {};      // For structure_data.json
    global.GameData.entities = {};        // For entity_data.json
    global.GameData.name_data = {};         // For name_data.json (formerly pop_name_data.json)
    global.GameData.pop_states = {};      // For pop_states.json
    global.GameData.recipes = {};         // For recipes.json

    // =============================================================================
    // SECTION: SPAWN FORMATIONS
    // =============================================================================
    global.GameData.SpawnFormations = {
        Type: { // Define known formation types based on the FormationType enum in scr_constants
            NONE: "none",                       // Added based on enum
            GRID: "grid",                       // Matches enum
            LINE_HORIZONTAL: "line_horizontal", // Added based on enum
            LINE_VERTICAL: "line_vertical",     // Added based on enum
            CIRCLE: "circle",                   // Matches enum
            RANDOM_WITHIN_RADIUS: "random_within_radius", // Added based on enum
            SINGLE_POINT: "single_point",       // Changed from SINGLE to SINGLE_POINT to match enum
            CLUSTERED: "clustered",             // Matches enum
            PACK_SCATTER: "pack_scatter",       // Matches enum
            SCATTER: "scatter"                  // Added based on enum
        }
        // Educational: This mapping allows us to convert enum values to strings for saving/loading data, UI display, or modding support. Always update this if you add new formation types to the enum.
    };

    // =============================================================================
    // SECTION: MOVEMENT EFFECTS (NEW)
    // =============================================================================
    global.GameData.MovementEffects = {
        Type: {
            NONE: 0,
            SLOWED_MILD: 1,
            SLOWED_MODERATE: 2,
            SLOWED_SEVERE: 3,
            IMPASSABLE_TEMPORARY: 4,
            IMPASSABLE_TRAPPED: 5,
            IMPASSABLE_SOLID: 6,
            HASTENED_MILD: 7,
            SLIPPERY: 8
        }
    };

    // =============================================================================
    // SECTION: STATUS EFFECTS (NEW - Placeholder, expand as needed)
    // =============================================================================
    global.GameData.StatusEffects = {
        Type: {
            POISONED: 0,
            BLEEDING: 1,
            STUNNED: 2,
            BURNING: 3,
            FROZEN: 4,
            SINKING: 5
        }
    };

    // =============================================================================
    // SECTION: HAZARD TRIGGER TYPES (NEW - Placeholder, expand as needed)
    // =============================================================================
    global.GameData.Hazards = {
        TriggerType: {
            PROXIMITY_ENTER: 0,
            PROXIMITY_STAY: 1,
            ON_INTERACT: 2,
            TIMED_EVENT: 3,
            DAMAGE_RECEIVED: 4
        }
    };

    // =============================================================================
    // SECTION: SKILLS
    // =============================================================================
    global.GameData.Skills = {
        Type: {
            FORAGING: 0,
            FARMING: 1,
            MINING: 2,
            WOODCUTTING: 3,
            CRAFTING_GENERAL: 4,
            CRAFTING_WEAPONS: 5,
            CRAFTING_TOOLS: 6,
            CRAFTING_APPAREL: 7,
            CONSTRUCTION: 8,
            COOKING: 9,
            MEDICINE: 10,
            COMBAT_MELEE: 11,
            COMBAT_RANGED: 12,
            SOCIAL_CHARISMA: 13,
            RESEARCHING: 14,
            HAULING: 15
        },
        Profiles: {}
    };

    // Helper for skill profile creation
    function CreateSkillProfile(_skill_enum, _name_key, _desc_key, _max_lvl = 100, _xp_curve) {
        return {
            skill_id_enum: _skill_enum,
            display_name_key: _name_key,
            description_key: _desc_key,
            max_level: _max_lvl,
            xp_curve_id: "CURVE_STANDARD", // Default to standard curve, can be overridden
        };
    }

    // Populate Skill Profiles using the helper and EntitySkill enum for consistency
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.FORAGING] = CreateSkillProfile(global.GameData.Skills.Type.FORAGING, "skill_name_foraging", "skill_desc_foraging");
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.FARMING] = CreateSkillProfile(global.GameData.Skills.Type.FARMING, "skill_name_farming", "skill_desc_farming");
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.MINING] = CreateSkillProfile(global.GameData.Skills.Type.MINING, "skill_name_mining", "skill_desc_mining");
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.WOODCUTTING] = CreateSkillProfile(global.GameData.Skills.Type.WOODCUTTING, "skill_name_woodcutting", "skill_desc_woodcutting");
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.CRAFTING_GENERAL] = CreateSkillProfile(global.GameData.Skills.Type.CRAFTING_GENERAL, "skill_name_crafting_general", "skill_desc_crafting_general");
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.CRAFTING_WEAPONS] = CreateSkillProfile(global.GameData.Skills.Type.CRAFTING_WEAPONS, "skill_name_crafting_weapons", "skill_desc_crafting_weapons");
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.CRAFTING_TOOLS] = CreateSkillProfile(global.GameData.Skills.Type.CRAFTING_TOOLS, "skill_name_crafting_tools", "skill_desc_crafting_tools");
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.CRAFTING_APPAREL] = CreateSkillProfile(global.GameData.Skills.Type.CRAFTING_APPAREL, "skill_name_crafting_apparel", "skill_desc_crafting_apparel");
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.CONSTRUCTION] = CreateSkillProfile(global.GameData.Skills.Type.CONSTRUCTION, "skill_name_construction", "skill_desc_construction");
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.COOKING] = CreateSkillProfile(global.GameData.Skills.Type.COOKING, "skill_name_cooking", "skill_desc_cooking");
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.MEDICINE] = CreateSkillProfile(global.GameData.Skills.Type.MEDICINE, "skill_name_medicine", "skill_desc_medicine");
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.COMBAT_MELEE] = CreateSkillProfile(global.GameData.Skills.Type.COMBAT_MELEE, "skill_name_combat_melee", "skill_desc_combat_melee");
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.COMBAT_RANGED] = CreateSkillProfile(global.GameData.Skills.Type.COMBAT_RANGED, "skill_name_combat_ranged", "skill_desc_combat_ranged");
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.SOCIAL_CHARISMA] = CreateSkillProfile(global.GameData.Skills.Type.SOCIAL_CHARISMA, "skill_name_social_charisma", "skill_desc_social_charisma");
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.RESEARCHING] = CreateSkillProfile(global.GameData.Skills.Type.RESEARCHING, "skill_name_researching", "skill_desc_researching");
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.HAULING] = CreateSkillProfile(global.GameData.Skills.Type.HAULING, "skill_name_hauling", "skill_desc_hauling");

    // Note: HUNTING_BASIC and FIRE_MAKING were previously here.
    // If these are distinct skills and not covered by others (e.g., COMBAT_RANGED/MELEE for hunting, or a general "SURVIVAL" skill for fire-making),
    // they should be added to the EntitySkill enum in scr_constants and then defined here.
    // For now, assuming they are implicitly covered or will be added to EntitySkill later if needed.

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
        // Corrected to use the renamed skill enum CRAFTING_GENERAL
        effects: [{ skill_to_modify_enum: global.GameData.Skills.Type.CRAFTING_GENERAL, modifier_type: "BONUS_LEVEL", value: 5 }],
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
        profile_id_string: "POP_GEN1", // Descriptive unique string ID
        type_tag: "Hominid",    // Broad category

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
    // CRAFTING_PRIMITIVE is now CRAFTING_GENERAL or more specific ones.
    // For GEN1, CRAFTING_GENERAL seems appropriate as a starting point.
    global.GameData.Entity.Pop.GEN1.base_skill_aptitudes[$ global.GameData.Skills.Type.CRAFTING_GENERAL] = 3;
    // SOCIAL_COMMUNICATION is now SOCIAL_CHARISMA
    global.GameData.Entity.Pop.GEN1.base_skill_aptitudes[$ global.GameData.Skills.Type.SOCIAL_CHARISMA] = 3;
    // Add other relevant GEN1 aptitudes if necessary, e.g., HAULING, CONSTRUCTION
    global.GameData.Entity.Pop.GEN1.base_skill_aptitudes[$ global.GameData.Skills.Type.HAULING] = 2;
    global.GameData.Entity.Pop.GEN1.base_skill_aptitudes[$ global.GameData.Skills.Type.CONSTRUCTION] = 1;


    // =============================================================================
    // SECTION: RECIPES
    // =============================================================================
    // Assign the frequently accessed skill profile to a temporary variable
    var _general_crafting_skill_profile_ref = undefined;
    // Use CRAFTING_GENERAL as the default for basic recipes
    if (is_struct(global.GameData.Skills.Profiles) && variable_struct_exists(global.GameData.Skills.Profiles, string(global.GameData.Skills.Type.CRAFTING_GENERAL))) {
        _general_crafting_skill_profile_ref = global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.CRAFTING_GENERAL];
    } else {
        debug_message("ERROR (scr_database): Could not assign _general_crafting_skill_profile_ref for recipes. Profile for CRAFTING_GENERAL missing.");
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
            // Assuming Stone Axe uses general crafting. If it needs a specific tool/weapon crafting skill, update this.
            skill_profile_path: _general_crafting_skill_profile_ref, 
            min_level_required: 1 // Minimum skill level required to craft this recipe
        },
        required_crafting_station_tags: ["crafting_surface_basic", "tool_making_spot"], // Tags for stations where this recipe can be crafted (e.g., flat rock, work stump)
        xp_reward_skill_path: _general_crafting_skill_profile_ref, 
        xp_reward_amount: 8 // Amount of XP awarded for crafting this item
        // This structure makes it easy to add more recipes and ensures consistency across all crafting data.
    };
    // ... More recipes

    // =============================================================================
    // SECTION: DEFAULT POP NAMES (for fallback in name generation)
    // =============================================================================
    global.GameData.defaultMaleNames = [
        "Uga", "Groka", "Boro", "Tarn", "Mako", "Rok", "Daru", "Karn", "Zug", "Varn"
    ];
    global.GameData.defaultFemaleNames = [
        "Lira", "Suna", "Mira", "Tara", "Vena", "Rina", "Dara", "Kira", "Zana", "Nira"
    ];

    debug_message("global.GameData populated successfully in scr_database. Version with GEN1-4 Pops.");
}