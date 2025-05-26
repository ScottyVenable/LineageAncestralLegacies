/// obj_creature_ai_controller - Create Event
///
/// Purpose:
///    Initializes a generic creature AI controller based on entity_data
///    provided during its creation by scr_spawn_entity.
///
/// Metadata:
///    Summary:         Sets up creature properties from data.
///    Usage:           Called when a creature AI controller is spawned.
///    Tags:            [controller][creature][ai][init][data_driven]
///    Version:         1.0 - 2025-05-25 // Initial version
///    Dependencies:    scr_spawn_entity, scr_database (get_entity_data)
///    Author:          GitHub Copilot

// This controller instance expects entity_type and entity_data to be injected by scr_spawn_entity
// entity_type = undefined; // Example: EntityType.CREATURE_WOLF
// entity_data = undefined; // Struct containing all data from get_entity_data()
// self.staticProfileData = undefined; // Injected by spawn_single_instance
// self.profileIDStringRef = undefined; // Injected by spawn_single_instance

// --- Core State & AI Variables ---
target_entity = noone;      // Current target for AI behaviors (e.g., enemy, resource)
current_behavior_state = undefined; // Stores the current AI state (e.g., PopState.IDLE, PopState.WANDERING)
path = undefined;           // Path for mp_grid_path
path_position = 0;          // Current position along the path
move_target_x = x;          // Target x for movement
move_target_y = y;          // Target y for movement

// --- Method to initialize the instance based on the provided entity_data ---
/// @function initialize_from_profile()
/// @description Initializes the creature's properties using the self.staticProfileData struct.
///              This method is called by scr_spawn_system.spawn_single_instance after the instance is created
///              and self.staticProfileData / self.profileIDStringRef are injected.
initialize_from_profile = function() {
    // Ensure staticProfileData has been set by the spawner
    if (!is_struct(self.staticProfileData)) {
        var _error_msg = $"ERROR (obj_creature_ai_controller): self.staticProfileData was not provided or is not a struct. Profile ID: '{self.profileIDStringRef}'. Cannot initialize.";
        show_error(_error_msg, true);
        // It's crucial to use a logging function that's available globally or defined early.
        // Assuming debug_log is available. If not, replace with show_debug_message or similar.
        show_debug_message(_error_msg); // Using show_debug_message for broader compatibility
        instance_destroy(); // Destroy self if no data
        return;
    }

    var _profile = self.staticProfileData;
    var _profile_id = self.profileIDStringRef; // For logging and debugging

    // It's good practice to log which profile is being used for initialization.
    show_debug_message($"Initializing Creature AI from Profile: '{_profile_id}' (Object: {_profile.object_to_spawn})");

    // --- Core Visual & Identifier Properties ---
    // Access sprite information from the profile's sprite_info struct
    if (variable_struct_exists(_profile, "sprite_info") && is_struct(_profile.sprite_info) && variable_struct_exists(_profile.sprite_info, "default")) {
        sprite_index = _profile.sprite_info.default;
    } else {
        sprite_index = spr_placeholder_creature; // Ensure spr_placeholder_creature exists
        show_debug_message($"Warning (obj_creature_ai_controller): Profile '{_profile_id}' has no sprite_info.default. Using placeholder.");
    }
    
    // Image speed can also be part of sprite_info or a general animation property
    if (variable_struct_exists(_profile, "sprite_info") && is_struct(_profile.sprite_info) && variable_struct_exists(_profile.sprite_info, "image_speed")) {
        image_speed = _profile.sprite_info.image_speed;
    } else {
        image_speed = (sprite_index == spr_placeholder_creature) ? 0 : 1; // Default: 0 for static placeholders, 1 for animated
    }

    // --- Health & Combat ---
    // These should now come from StatsBase or similar in the profile
    self.max_health = variable_struct_exists(_profile, "StatsBase") && variable_struct_exists(_profile.StatsBase, "MaxHealth") ? _profile.StatsBase.MaxHealth : 10;
    self.current_health = self.max_health; // Creatures usually start at full health
    
    // Damage might be part of a "CombatStats" substruct or directly in StatsBase
    self.damage_min = variable_struct_exists(_profile, "StatsBase") && variable_struct_exists(_profile.StatsBase, "DamageMin") ? _profile.StatsBase.DamageMin : 1;
    self.damage_max = variable_struct_exists(_profile, "StatsBase") && variable_struct_exists(_profile.StatsBase, "DamageMax") ? _profile.StatsBase.DamageMax : 1;
    
    if (self.damage_min > self.damage_max) {
        show_debug_message($"Warning (obj_creature_ai_controller): Profile '{_profile_id}' has damage_min ({self.damage_min}) > damage_max ({self.damage_max}). Clamping damage_min.");
        self.damage_min = self.damage_max;
    }
    // Damage modifier could be part of advanced stats or directly in StatsBase
    self.damage_modifier = variable_struct_exists(_profile, "StatsBase") && variable_struct_exists(_profile.StatsBase, "DamageModifier") ? _profile.StatsBase.DamageModifier : 0;
    self.attack_range = variable_struct_exists(_profile, "StatsBase") && variable_struct_exists(_profile.StatsBase, "AttackRange") ? _profile.StatsBase.AttackRange : 32; // Range in pixels

    // --- Movement & Perception ---
    // Speed and perception are also likely in StatsBase or a dedicated movement struct
    self.base_speed_unit_secs = variable_struct_exists(_profile, "StatsBase") && variable_struct_exists(_profile.StatsBase, "MovementSpeed") ? _profile.StatsBase.MovementSpeed : 1.0; // e.g., pixels per second
    self.perception_radius = variable_struct_exists(_profile, "StatsBase") && variable_struct_exists(_profile.StatsBase, "PerceptionRadius") ? _profile.StatsBase.PerceptionRadius : 100; // Radius in pixels

    // --- Behavior & Classification ---
    // Aggression level, AI package, faction should be directly in the profile
    self.aggression_level = variable_struct_exists(_profile, "aggression_level") ? _profile.aggression_level : "passive"; 
    self.ai_package_profile_path = variable_struct_exists(_profile, "ai_package_profile_path") ? _profile.ai_package_profile_path : undefined;
    self.faction_profile_path = variable_struct_exists(_profile, "faction_profile_path") ? _profile.faction_profile_path : undefined;
        
    // Traits: an array of trait profile paths (strings)
    // These would be resolved to actual trait data if needed, or effects applied directly
    self.innate_trait_profile_paths = variable_struct_exists(_profile, "innate_trait_profile_paths") && is_array(_profile.innate_trait_profile_paths) ? array_clone(_profile.innate_trait_profile_paths) : [];
    
    // Tags: an array of string tags for miscellaneous classification
    self.tags = variable_struct_exists(_profile, "tags") && is_array(_profile.tags) ? array_clone(_profile.tags) : [];

    // --- Skills & Abilities ---
    // Base skill aptitudes (e.g., for learning or base effectiveness)
    self.base_skill_aptitudes = variable_struct_exists(_profile, "base_skill_aptitudes") && is_struct(_profile.base_skill_aptitudes) ? scr_struct_clone(_profile.base_skill_aptitudes) : {}; // Use deep clone
    
    // Ability Scores: Ranges for rolling, or fixed scores
    // For creatures, we might directly use base scores or have a simpler system than Pops.
    // Assuming AbilityScoreRanges might exist, similar to Pops, for potential rolling.
    // If not, direct base scores from StatsBase or a dedicated ability score struct.
    if (variable_struct_exists(_profile, "AbilityScoreRanges")) {
        // Placeholder: Implement rolling if creatures need dynamic scores
        // For now, let's assume creatures might have fixed scores or use a simpler model.
        // This section would mirror obj_pop's ability score rolling if needed.
        show_debug_message($"Note (obj_creature_ai_controller): Profile '{_profile_id}' has AbilityScoreRanges. Rolling logic not yet implemented for creatures, using defaults if any or base stats.");
        self.ability_scores_rolled = { STR: 10, DEX: 10, CON: 10, INT: 10, WIS: 10, CHA: 10 }; // Default placeholder
    } else if (variable_struct_exists(_profile, "StatsBase") && variable_struct_exists(_profile.StatsBase, "AbilityScores")) {
        // If fixed ability scores are provided directly
        self.ability_scores_rolled = scr_struct_clone(_profile.StatsBase.AbilityScores);
    } else {
        // Default fallback if no ability score data is found
        self.ability_scores_rolled = { STR: 10, DEX: 10, CON: 10, INT: 10, WIS: 10, CHA: 10 };
        show_debug_message($"Warning (obj_creature_ai_controller): Profile '{_profile_id}' has no specific ability score data. Using default scores.");
    }
    
    // --- Runtime Stats Calculation (if necessary) ---
    // Creatures might have simpler stat calculations than Pops.
    // For example, health is already set. Other stats might be derived or directly used.
    // This section can be expanded if creatures have complex derived stats.
    // self.stats_runtime = {}; // Initialize if needed
    // self.stats_runtime.Health = self.current_health; // Already handled by max_health

    // --- Inventory (if applicable) ---
    // Creatures might have loot tables or simple inventories.
    // Placeholder for inventory initialization if creatures can carry items.
    // self.inventory_instance_id = undefined;
    // if (variable_struct_exists(_profile, "inventory_template_profile_path")) {
    //     // self.inventory_instance_id = scr_inventory_create(self, _profile.inventory_template_profile_path);
    //     show_debug_message($"Note (obj_creature_ai_controller): Profile '{_profile_id}' has inventory. Inventory creation logic placeholder.");
    // }

    // --- Final Setup & Logging ---
    show_debug_message($"Creature AI '{_profile_id}' initialized successfully.");
    
    // Example: Set an initial behavior state if defined in the profile or based on aggression
    if (self.aggression_level == "passive") {
        current_behavior_state = PopState.IDLE; // Assuming PopState enum is accessible or use string/constant
    } else if (self.aggression_level == "aggressive") {
        current_behavior_state = PopState.ROAM_AGGRESSIVELY; // Example state
    } else {
        current_behavior_state = PopState.IDLE; // Default
    }
    
    // TODO: Apply effects of innate traits
    // foreach (var _trait_path in self.innate_trait_profile_paths) {
    //     var _trait_profile = global.GetProfileFromUniqueID(_trait_path);
    //     if (is_struct(_trait_profile)) {
    //         // scr_apply_trait_effects(self, _trait_profile); // Needs implementation
    //     }
    // }

}; // End of initialize_from_profile

// --- Call the initialization method ---
// This is crucial. After defining the function, it must be called.
// initialize_from_data(); // Old call, remove or comment out
// The new system expects spawn_single_instance to call initialize_from_profile()

// --- Other Event-Specific Logic (if any) ---
// (This would be any logic that runs *after* initialization, specific to the Create event)
// For example, immediately starting a behavior if not handled by initialize_from_profile.

// Make sure to remove or comment out old initialization logic that relied on
// entity_type and entity_data being directly set and then calling initialize_from_data().
// The new pattern is that spawn_single_instance injects staticProfileData and profileIDStringRef,
// then calls instance.initialize_from_profile().
// So, the direct call to initialize_from_data() here should be removed.

// Example of how it was previously:
// if (instance_exists(self)) { // Check if not destroyed by init
//     if (is_method(self, initialize_from_data)) {
//         initialize_from_data();
//     } else {
//         show_error("obj_creature_ai_controller: initialize_from_data method not found!", true);
//     }
// }

// The above block should be removed as initialization is now handled by the spawner
// calling the instance's initialize_from_profile method.
