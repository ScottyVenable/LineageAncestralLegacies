/// scr_traits.gml
///
/// Purpose:
///    Defines the Trait enum and provides the function get_trait_data()
///    to retrieve descriptions, effects, and other properties of traits.
///
/// Metadata:
///   Summary:       Trait enumerations and data definitions.
///   Usage:         Enum Trait is global. Call get_trait_data(Trait.ENUM_VALUE) anywhere.
///   Tags:          [data][traits][database][definitions][enums][pop_evolution]
///   Version:       1.0 - [Current Date]
///   Dependencies:  None directly, but effects might reference other game systems/stats.

// ============================================================================
// 1. TRAIT ENUMERATION
// ============================================================================
#region 1.1 Trait Enum Definition
enum Trait {
    NONE,

    // Physical
    STRONG_BACK,    // Increased carrying capacity
    QUICK_FEET,     // Increased movement speed
    ROBUST_HEALTH,  // Increased max health or faster healing
    KEEN_EYESIGHT,  // Increased perception range or accuracy

    // Mental
    QUICK_LEARNER,  // Faster skill gain
    INVENTIVE,      // Chance to discover new recipes/ideas
    GOOD_MEMORY,    // Retains skills longer, or other benefits

    // Social/Emotional
    BRAVE,          // Less likely to flee, better in combat
    EMPATHETIC,     // Forms positive relationships faster
    STUBBORN,       // Resistant to mood swings, but maybe slower to adopt new ideas
    NATURAL_LEADER, // Influences others more easily

    // Negative (Examples)
    CLUMSY,         // Chance to fail crafting, slower movement
    SLOW_LEARNER,
    TIMID,
}

enum TraitCategory {
	NONE,
	PHYSICAL,
	MENTAL,
	SPIRITUAL,
	EMOTIONAL
}

show_debug_message("Enum 'Trait' (scr_traits) Initialized.");
#endregion

// ============================================================================
// 2. TRAIT DATA ACCESS FUNCTION & DATABASE
// ============================================================================
#region 2.1 get_trait_data() Function

/// @function get_trait_data(trait_enum_id)
/// @description Returns a struct containing the properties for the given trait enum.
/// @param {enum.Trait} trait_enum_id The enum ID of the trait.
/// @returns {Struct|undefined}
function get_trait_data(trait_enum_id) {
    static trait_database = __internal_init_trait_database(); 
    
    if (struct_exists(trait_database, trait_enum_id)) {
        return trait_database[$ trait_enum_id];
    }
    show_debug_message($"Warning (get_trait_data): No data found for trait enum: {trait_enum_id}.");
    return undefined; 
}
#endregion

#region 2.2 __internal_init_trait_database() Helper Function

function __internal_init_trait_database() {
    show_debug_message("Initializing Trait Database (scr_traits)...");
    var _db = {}; 

    // --- STRONG_BACK ---
    _db[$ Trait.STRONG_BACK] = {
        name: "Strong Back",
        description: "Can carry more without being encumbered.",
        type: TraitCategory.PHYSICAL,
        icon_sprite: spr_trait_strong_back, // Example sprite
        effects: { // Struct defining direct stat modifiers or flags
            carry_capacity_modifier_add: 20 // Adds 20 to base carry capacity
        },
        conflicts_with: [Trait.CLUMSY] // Example: Cannot have Strong Back and Clumsy
    };

    // --- QUICK_LEARNER ---
    _db[$ Trait.QUICK_LEARNER] = {
        name: "Quick Learner",
        description: "Picks up new skills with surprising speed.",
        type: "Mental",
        icon_sprite: spr_trait_quick_learner,
        effects: {
            skill_gain_multiplier: 1.25 // 25% faster skill gain
        },
        conflicts_with: [Trait.SLOW_LEARNER]
    };
    
    // --- BRAVE ---
    _db[$ Trait.BRAVE] = {
        name: "Brave",
        description: "Faces danger head-on rather than fleeing.",
        type: "Social/Emotional",
        icon_sprite: spr_trait_brave,
        effects: {
            morale_loss_in_danger_multiplier: 0.5, // Takes less morale damage from being in danger
            flee_threshold_modifier_add: -0.2 // Less likely to reach flee threshold
        },
        conflicts_with: [Trait.TIMID]
    };
    
    // --- CLUMSY (Negative Example) ---
    _db[$ Trait.CLUMSY] = {
        name: "Clumsy",
        description: "Often fumbles and makes mistakes.",
        type: "Physical",
        icon_sprite: spr_trait_clumsy,
        effects: {
            crafting_success_chance_modifier_add: -0.10, // 10% less chance of successful craft
            movement_speed_multiplier: 0.90 // 10% slower
        },
        conflicts_with: [Trait.STRONG_BACK, Trait.QUICK_FEET] // Example
    };

    // ... ADD OTHER TRAIT DEFINITIONS ...

    show_debug_message($"Trait Database Initialized. {struct_names_count(_db)} traits defined.");
    return _db;
}
#endregion