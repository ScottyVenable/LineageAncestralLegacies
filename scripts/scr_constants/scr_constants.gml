/// scr_constants.gml
///
/// Purpose:
///     Defines global enumerations (enums) and potentially other constants
///     used throughout the game. This script should be placed high in the
///     asset tree or ensured to compile early so these definitions are
///     available when other scripts need them.
///
/// Metadata:
///     Summary:        Contains global game enums like PopState, ItemType, PopNeeds, BuildingTypes, etc.
///     Usage:          Exists in the project; its contents are globally accessible once compiled.
///                     Not called as a function.
///     Parameters:     none (This script is not a function and does not accept parameters)
///     Returns:        n/a (This script is not a function and does not return values)
///     Tags:           [global][definitions][enums][constants]
///     Version:        1.3 — 2025-05-19 (Added comprehensive future-proofing enums)
///     Dependencies:   none (Enums defined here are self-contained)

// =========================================================================
// 0. IMPORTS & CACHES
// =========================================================================
#region 0.1 Imports & Cached Locals
// (Not applicable for a script that only defines global enums at the top level)
#endregion

// =========================================================================
// 1. VALIDATION & EARLY RETURNS
// =========================================================================
#region 1.1 Parameter Validation
// (Not applicable for a script that only defines global enums)
#endregion

// =========================================================================
// 2. CONFIGURATION & CONSTANTS (ENUM DEFINITIONS)
// =========================================================================
// This section is used to define the global enums.

#region 2.1 Pop Enums
enum PopState {
    IDLE,
    COMMANDED,
    WANDERING,
    EATING,
    SLEEPING,   // Added
    WORKING,    // Added
    CRAFTING,   // Added
    BUILDING,   // Added
    HAULING,    // Added
    ATTACKING,
    FLEEING,
    SOCIALIZING,// Added
    WAITING,
    FORAGING
    // Add other pop states as needed
}
enum PopSex {
	MALE,
	FEMALE
}
enum PopNeed {
    HUNGER,
    THIRST,
    ENERGY,     // Or Rest/Sleep
    SAFETY,
    SHELTER,    // Related to safety/environment
    SOCIAL,
    RECREATION, // Or Fun/Entertainment
    COMFORT,    // Temperature, clothing etc.
    HEALTH      // General physical well-being
}

enum PopSkill {
    FORAGING,
    FARMING,
    MINING,
    WOODCUTTING,
    CRAFTING_GENERAL,
    CRAFTING_WEAPONS,
    CRAFTING_TOOLS,
    CRAFTING_APPAREL,
    CONSTRUCTION,
    COOKING,
    MEDICINE,
    COMBAT_MELEE,
    COMBAT_RANGED,
    SOCIAL_CHARISMA, // For leadership, trading
    RESEARCHING,
    HAULING // Efficiency in carrying things
}

enum PopRelationship {
    STRANGER,
    ACQUAINTANCE,
    FRIEND,
    GOOD_FRIEND,
    COMPANION, // Close, possibly romantic or deep platonic
    RIVAL,
    ENEMY,
    FAMILY_PARENT,
    FAMILY_SIBLING,
    FAMILY_CHILD,
    FAMILY_SPOUSE
}
#endregion

#region 2.2 Item Enums
enum ItemType {
    CONSUMABLE_FOOD,
    CONSUMABLE_DRINK,
    CONSUMABLE_MEDICINE,
    MATERIAL_STONE,
    MATERIAL_WOOD,
    MATERIAL_METAL,
    MATERIAL_FIBER, // For cloth, rope
    MATERIAL_FUEL,  // For fires, crafting stations
    EQUIPMENT_TOOL,
    EQUIPMENT_WEAPON_MELEE,
    EQUIPMENT_WEAPON_RANGED,
    EQUIPMENT_ARMOR_HEAD,
    EQUIPMENT_ARMOR_TORSO,
    EQUIPMENT_ARMOR_LEGS,
    FURNITURE,      // Placeable items
    BLUEPRINT,      // For learning new crafts/buildings
    QUEST,
    MISC
}

enum ItemQuality { // Could also be ItemTier
    CRUDE,
    POOR,
    COMMON,         // Or Standard, Normal
    GOOD,
    EXCELLENT,
    MASTERWORK,
    LEGENDARY       // Or Artifact
}

enum ItemTag { // For more flexible item categorization beyond ItemType
    EDIBLE,
    DRINKABLE,
    FLAMMABLE,
    CONSTRUCTION_MATERIAL,
    WEAPON_BLUNT,
    WEAPON_SLASHING,
    WEAPON_PIERCING,
    TOOL_GATHERING,
    TOOL_CRAFTING,
    CLOTHING_WARM,
    CLOTHING_COLD_RESISTANT,
    DECORATIVE
}
#endregion

#region 2.3 Building & Structure Enums
enum BuildingCategory {
    HOUSING,
    PRODUCTION_PRIMARY,   // Resource gathering spots like mines, lumber camps
    PRODUCTION_SECONDARY, // Crafting stations like smithy, tailor
    STORAGE,
    DEFENSE,
    INFRASTRUCTURE, // Roads, bridges
    COMMUNITY,      // Meeting spots, recreation
    AGRICULTURE     // Farms, hydroponics
}

enum StructureType { // More specific than category
    // Housing
    HUT_PRIMITIVE,
    HOUSE_SMALL,
    BARRACKS,
    // Production Primary
    FORAGING_POST,
    LUMBER_CAMP,
    MINE_SHAFT,
    QUARRY,
    FISHING_SPOT,
    // Production Secondary
    WORKBENCH_GENERAL,
    CAMPFIRE_COOKING,
    SMELTER,
    SMITHY,
    TAILOR_STATION,
    RESEARCH_BENCH,
    // Storage
    STORAGE_PILE_WOOD,
    STORAGE_PILE_STONE,
    GRANARY,
    WAREHOUSE_SMALL,
    // Defense
    WALL_WOODEN,
    WALL_STONE,
    WATCHTOWER,
    TRAP_SPIKE,
    // Infrastructure
    PATH_DIRT,
    BRIDGE_WOODEN,
    // Community
    FIRE_PIT_COMMUNAL,
    GATHERING_HALL,
    // Agriculture
    FARM_PLOT_SMALL,
    HYDROPONICS_BASIN
}
#endregion

#region 2.4 Environment & Time Enums
enum BiomeType {
    FOREST_TEMPERATE,
    FOREST_BOREAL,
    PLAINS,
    GRASSLAND,
    MOUNTAIN_ROCKY,
    MOUNTAIN_SNOWY,
    SWAMP,
    DESERT_ARID,
    TUNDRA,
    RIVER,
    LAKE,
    OCEAN_COAST
}

enum Season {
    SPRING,
    SUMMER,
    AUTUMN,
    WINTER
}

enum WeatherType {
    CLEAR_SKY,
    PARTLY_CLOUDY,
    OVERCAST,
    LIGHT_RAIN,
    HEAVY_RAIN,
    THUNDERSTORM,
    LIGHT_SNOW,
    HEAVY_SNOW,
    BLIZZARD,
    FOG,
    HAIL,
    DUST_STORM // If applicable
}

enum TimeOfDay { // Could be used for lighting, pop schedules
    DAWN,
    MORNING,
    MIDDAY,
    AFTERNOON,
    DUSK,
    NIGHT,
    MIDNIGHT
}
#endregion

#region 2.5 Task & System Enums
enum TaskPriority {
    NONE,       // Not set or not a task
    VERY_LOW,
    LOW,
    NORMAL,
    HIGH,
    URGENT,
    CRITICAL    // System critical, must be done
}

enum Formation {
    NONE,               // All target the same spot
    LINE_HORIZONTAL,
    LINE_VERTICAL,
    GRID,
    // Future: WEDGE, CIRCLE
}

enum AlertLevel { // For colony/settlement wide alerts
    NONE,       // All clear
    CAUTION,    // Potential threat, be aware
    LOW_THREAT, // Minor threat detected (e.g., small predator)
    MEDIUM_THREAT, // Significant threat (e.g., raiders sighted)
    HIGH_THREAT,  // Imminent danger (e.g., attack underway)
    EVACUATE    // Extreme danger, non-combatants to safety
}

enum FactionStanding { // How other factions view the player's faction
    HOSTILE_AT_WAR,
    HOSTILE_AGGRESSIVE,
    NEUTRAL_WARY,
    NEUTRAL,
    NEUTRAL_FRIENDLY_LEANING,
    FRIENDLY_ALLY,
    FRIENDLY_LOYAL_ALLY
}
#endregion

// Add other global enums or macros here as needed within Section 2.

// =========================================================================
// 3. INITIALIZATION & STATE SETUP
// =========================================================================
#region 3.1 One‐Time Setup
// (Not applicable in the same way as a behavior script; enums are defined at compile time)
// The show_debug_message below acts as a confirmation that the script has been processed.
#endregion

// =========================================================================
// 4. CORE LOGIC
// =========================================================================
#region 4.1 Main Behavior / Utility Logic
// (Not applicable for a script that only defines global enums)
#endregion

// =========================================================================
// 5. CLEANUP & RETURN
// =========================================================================
#region 5.1 Cleanup & Return
// (Not applicable for a script that only defines global enums)
#endregion

// =========================================================================
// 6. DEBUG/PROFILING (Confirmation Log)
// =========================================================================
#region 6.1 Debug & Profile Hooks
show_debug_message("Global Constants & Enums (scr_constants) Initialized/Compiled with expanded list.");
#endregion
