/// @description Initializes the global.GameData structure with all static game definitions.
/// This script should be run once at the beginning of the game (e.g., in obj_gameStart).
function gamedata_init() {
    show_debug_message("Initializing global.GameData...");

    // Ensure critical enums and base structures from other scripts are loaded first
    if (script_exists(asset_get_index("scr_database"))) {
        scr_database(); // This script defines the EntityType enum and global.EntityCategories
        show_debug_message("scr_database() executed from gamedata_init.");
    } else {
        show_error("CRITICAL ERROR: scr_database script not found. EntityType enum will be undefined.", true);
        return; // Stop initialization if critical script is missing
    }
    
    // Initialize scr_constants if it defines enums needed by other gamedata parts
    if (script_exists(asset_get_index("scr_constants"))) {
        scr_constants(); // This script defines various enums like PopLifeStage, FormationType etc.
        show_debug_message("scr_constants() executed from gamedata_init.");
    } else {
        show_debug_message("WARNING: scr_constants script not found. Some enums might be undefined.");
    }

    global.GameData = {};

    // --- Top-Level Categories ---
    global.GameData.Entity = {}; // This will be populated by scr_database or similar later
    global.GameData.Items = {};
    global.GameData.Recipes = {};
    global.GameData.SpawnFormations = {};
    global.GameData.Traits = {};
    global.GameData.Skills = {}; // Initialize Skills structure
    global.GameData.WorldConstants = {};
    global.GameData.LootTables = {};

    // --- SpawnFormations ---
    // Ensure FormationType is defined (typically in scr_constants) before accessing it here
    if (variable_global_exists("FormationType")) {
        global.GameData.SpawnFormations.Type = {
            SINGLE_POINT: FormationType.SINGLE_POINT, // Assuming FormationType has these
            CLUSTERED: FormationType.CLUSTERED,
            LINE: FormationType.LINE,
            GRID: FormationType.GRID,
            PACK_SCATTER: FormationType.PACK_SCATTER 
            // Add other formation types if they exist in your FormationType enum
        };
    } else {
        show_debug_message("WARNING (gamedata_init): FormationType enum not found. SpawnFormations.Type may be incomplete.");
        // Fallback or default definition if FormationType is missing
        global.GameData.SpawnFormations.Type = { 
            SINGLE_POINT: 0, CLUSTERED: 1, LINE: 2, GRID: 3, PACK_SCATTER: 4 
        };
    }
    // Example: global.GameData.SpawnFormations.DefaultParams could be defined here if needed

    // --- Skills ---
    // This section defines skill types (used as keys/IDs) and their corresponding profiles.
    global.GameData.Skills.Type = { // Enum-like struct for skill identifiers
        FORAGING: "skill_type_foraging",
        CRAFTING_PRIMITIVE: "skill_type_crafting_primitive",
        SCAVENGING: "skill_type_scavenging"
        // Add other skill types here, e.g., HUNTING, COMBAT_MELEE, SOCIAL, etc.
    };

    // Skill Profiles (actual data for each skill)
    // The key for each profile is the value from GameData.Skills.Type
    // IMPORTANT: Initialize Profiles as a struct first
    global.GameData.Skills.Profiles = {}; 

    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.FORAGING] = {
        profile_id_string: global.GameData.Skills.Type.FORAGING, // Consistent ID
        display_name_key: "skill_name_foraging", // For localization
        description_key: "skill_desc_foraging",
        // Other properties: xp_curve_type, effects_per_level, etc.
    };
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.CRAFTING_PRIMITIVE] = {
        profile_id_string: global.GameData.Skills.Type.CRAFTING_PRIMITIVE,
        display_name_key: "skill_name_crafting_primitive",
        description_key: "skill_desc_crafting_primitive",
    };
    global.GameData.Skills.Profiles[$ global.GameData.Skills.Type.SCAVENGING] = {
        profile_id_string: global.GameData.Skills.Type.SCAVENGING,
        display_name_key: "skill_name_scavenging",
        description_key: "skill_desc_scavenging",
    };

    // --- Traits ---
    // This section defines trait categories and their corresponding profiles.
    global.GameData.Traits = {};
    global.GameData.Traits.Pop = {}; // Traits specific to Pops
    global.GameData.Traits.Generic = {}; // Traits applicable to various entities

    // Trait Profiles (actual data for each trait)
    global.GameData.Traits.Pop.BASIC_TOOL_USE = {
        profile_id_string: "trait_pop_basic_tool_use",
        display_name_key: "trait_name_basic_tool_use",
        description_key: "trait_desc_basic_tool_use",
        effects: { /* e.g., crafting_speed_modifier: 0.1 */ }
    };
    global.GameData.Traits.Generic.CURIOUS_MIND_LOW = {
        profile_id_string: "trait_generic_curious_mind_low",
        display_name_key: "trait_name_curious_mind_low",
        description_key: "trait_desc_curious_mind_low",
        effects: { /* e.g., learning_rate_modifier: 0.05 */ }
    };

    // --- Items ---
    // Placeholder for item definitions.
    global.GameData.Items.Resource = {};
    global.GameData.Items.Tool = {};
    // Example item profile (needed for Berry Bush resource_item_profile_path)
    global.GameData.Items.Resource.BERRIES_RED = {
        item_id_string: "item_resource_berries_red",
        display_name_key: "item_name_berries_red",
        description_key: "item_desc_berries_red",
        sprite_inventory: undefined, // Placeholder for item's inventory sprite
        max_stack_size: 20,
        tags: ["food", "plant_based", "raw"]
    };
    // Example items for recipe (if we were defining Stone Axe recipe now)
     global.GameData.Items.Resource.FLINT = { item_id_string: "ITEM_RESOURCE_FLINT", display_name_key: "item_name_flint" };
     global.GameData.Items.Resource.STICK = { item_id_string: "ITEM_RESOURCE_STICK", display_name_key: "item_name_stick" };
     global.GameData.Items.Tool.STONE_AXE = { item_id_string: "ITEM_TOOL_STONE_AXE", display_name_key: "item_name_stone_axe" };


    // --- LootTables ---
    // Placeholder for loot table definitions.
    global.GameData.LootTables.HOMINID_EARLY = {
        loot_table_id: "loot_table_hominid_early",
        // Example: entries: [ { item_profile_path: global.GameData.Items.Resource.FLINT, quantity_min: 1, quantity_max: 2, chance: 0.5 } ]
        entries: [] // No specific loot defined yet
    };


    // --- Entity Definitions ---
    // Categories for different types of entities
    global.GameData.Entity.Pop = {};
    global.GameData.Entity.ResourceNode = {};
    // global.GameData.Entity.Animal = {};
    // global.GameData.Entity.Structure = {};
    // global.GameData.Entity.Hazard = {};


    // --- Entity.Pop Profiles ---
    // Profile for Homo Habilis (Early)
    global.GameData.Entity.Pop.HOMO_HABILIS_EARLY = {
        // Identity & Display
        profile_id_string: "pop_profile_homo_habilis_early",
        display_name_key: "pop_name_homo_habilis_early", // Was "Homo Habilis (Early)"
        description_key: "pop_desc_homo_habilis_early", // Was "An early hominid, one of the first to use stone tools."

        // Core Spawning & Visual Data
        object_to_spawn: obj_pop,
        sprite_info: {
            idle: spr_habilis_idle,
            walk_prefix: "spr_habilis_walk_",
            portrait: spr_habilis_portrait
        },
        base_scale: 1.0,
        tags: ["hominid", "sentient", "pop", "early_human", "tool_user", "scavenger"],

        // Stats & Attributes (from scr_database.gml)
        base_max_health: 80,
        base_max_stamina: 100,
        base_speed_walk: 1.8,
        base_perception_radius: 140,
        base_carrying_capacity: 7,
        diet_type_tags: ["omnivorous_scavenger", "eats_fruit", "eats_marrow", "plant_based_fallback"],
        base_resistances: { physical: 0, fire: -10, cold: 5 },

        // Skills & Traits (references to profiles in GameData.Skills and GameData.Traits)
        base_skill_aptitudes: { // Keys are skill_type_ids from GameData.Skills.Type
            [global.GameData.Skills.Type.FORAGING]: 1.2,
            [global.GameData.Skills.Type.CRAFTING_PRIMITIVE]: 1.1,
            [global.GameData.Skills.Type.SCAVENGING]: 1.3
        },
        innate_trait_profiles: [ // Array of direct references to trait profile structs
            global.GameData.Traits.Pop.BASIC_TOOL_USE,
            global.GameData.Traits.Generic.CURIOUS_MIND_LOW
        ],

        // AI & Behavior
        default_ai_behavior_package_id: "AI_HOMINID_EARLY_SCAVENGER",
        faction_default_id: "FACTION_PLAYER_TRIBE_EARLY",

        // World Generation & Spawning Defaults
        default_spawn_amount_range: { min: 3, max: 5 },
        default_spawn_formation_type: global.GameData.SpawnFormations.Type.CLUSTERED,
        default_formation_params: {
            radius: 50,
            min_spacing_from_others: 24,
            placement_attempts_per_entity: 10
        },

        // Loot & Resources
        loot_table_profile_path: global.GameData.LootTables.HOMINID_EARLY,

        // Other specific data
        brain_size_cc_approx: 650
    };

    // --- Entity.ResourceNode Profiles ---
    // Profile for Red Berry Bush
    global.GameData.Entity.ResourceNode.BERRY_BUSH_GENERIC_RED = {
        // Identity & Display
        profile_id_string: "rn_profile_berry_bush_generic_red",
        display_name_key: "rn_name_berry_bush_red", // Was "Red Berry Bush"
        description_key: "rn_desc_berry_bush_red", // Was "A bush bearing edible red berries..."

        // Core Spawning & Visual Data
        object_to_spawn: obj_resource_node_controller,
        sprite_info: {
            main: spr_berry_bush_red_full,
            depleted: spr_berry_bush_red_empty
        },
        base_scale: 1.0,
        tags: ["plant", "food_source", "forageable", "wild_growing"],

        // Resource Node Specific Data
        resource_item_profile_path: global.GameData.Items.Resource.BERRIES_RED, // Path to item profile
        resource_yield_range: { min: 3, max: 6 },
        resource_regen_time_seconds: 120,
        harvest_interaction_type: "forage",
        required_tool_tags: [], // No tools required
        // Reference the actual skill profile struct for 'skill_used_for_harvest'
        skill_used_for_harvest_profile_path: global.GameData.Skills[global.GameData.Skills.Type.FORAGING],
        xp_gained_on_harvest: 2,

        // World Generation & Spawning Defaults
        default_spawn_amount_range: { min: 5, max: 10 },
        default_spawn_formation_type: global.GameData.SpawnFormations.Type.CLUSTERED,
        default_formation_params: {
            radius: 70, // Slightly larger radius for bushes
            min_spacing_from_others: 32,
            placement_attempts_per_entity: 8
        }
    };

    show_debug_message("global.GameData initialized successfully with initial profiles.");
}
