/// obj_pop - Create Event
///
/// Purpose:
///    Initializes all instance variables for a new pop.
///
/// Metadata:
///    Summary:         Sets up basic pop structure and generates detailed attributes.
///    Usage:           Automatically called when an obj_pop instance is created.
///    Version:        1.10 - May 22, 2025 (Updated life stage assignment logic and ensured metadata reflects current date)
///    Dependencies:  PopState (enum), scr_generate_pop_details, spr_man_idle.

// =========================================================================
// 1. CORE GAMEPLAY STATE & FLAGS
// =========================================================================
#region 1.1 Basic State & Selection
state = PopState.IDLE;
selected = false;
depth = -y;
image_speed = 1;
sprite_index = spr_pop_man_idle; // Default sprite, can be overridden by entity_data
image_index = 0;
current_sprite = sprite_index;
is_mouse_hovering = false;

// REMOVED: Old hardcoded pop initialization:
// // Updated to use a specific Hominid species from global.EntityCategories
// // as EntityType.POP_HOMINID is obsolete.
// // This provides a default concrete entity type for obj_pop instances.
// // Consider making this configurable if obj_pop needs to represent different entity types at creation.
// pop = get_entity_data(global.EntityCategories.Hominids.Species.HOMO_HABILIS_EARLY);
// if (is_undefined(pop)) {
// 	show_error("Failed to initialize 'pop': Entity data is invalid.", true);
// }
#endregion

// =========================================================================
// 2. MOVEMENT & COMMAND RELATED
// =========================================================================
#region 2.1 Movement & Command Vars
// These will be properly initialized in initialize_from_data() after 'pop' is set.
speed = 1; // Default speed, will be overridden
direction = random(360);
travel_point_x = x;
travel_point_y = y;
has_arrived = true;
was_commanded = false;
order_id = 0;
is_waiting = false;
#endregion

// =========================================================================
// 3. BEHAVIOR TIMERS & VARIABLES
// =========================================================================
#region 3.1 Idle State Variables
idle_timer = 0;
idle_target_time = 0;
idle_min_sec = 2.0;
idle_max_sec = 4.0;
after_command_idle_time = 0.5;
#endregion

#region 3.2 Wander State Variables
wander_pts = 0;
wander_pts_target = 0;
min_wander_pts = 1;
max_wander_pts = 3;
wander_min_dist = 50;
wander_max_dist = 150;
#endregion

#region 3.3 Foraging State Variables
// target_bush = noone; // Commented out: Replaced by last_foraged_target_id for resumption logic
last_foraged_target_id = noone; // Stores the ID of the last bush this pop foraged from
last_foraged_slot_index = -1;   // Stores the slot index on the last_foraged_target_id
last_foraged_type_tag = "";     // Stores the type tag of the slot on the last_foraged_target_id
forage_timer = 0;
forage_rate = global.game_speed;
#endregion

#region 3.4 Interaction Variables
target_interaction_object_id = noone;
target_object_id = noone;
_slot_index = -1; 
_interaction_type_tag = "";
#endregion

// =========================================================================
// 4. GENERATE POP DETAILS (Name, Sex, Age, Stats, Traits etc.)
// =========================================================================
#region 4.1 Generate Details
// This section will be effectively handled within initialize_from_data()
// after 'pop' (entity_data) is properly assigned.
// The call to scr_generate_pop_details will be moved into initialize_from_data().
#endregion

// =========================================================================
// 5. INVENTORY (Initialize after details)
// =========================================================================
#region 5.1 Initialize Inventory
inventory_items = ds_list_create();

// These will be properly initialized in initialize_from_data()
max_inventory_capacity = 10; // Default capacity, will be overridden
hauling_threshold = 10;    // Default threshold, will be overridden

// Initialize variables for resuming tasks, if not already present from a previous version
if (!variable_instance_exists(id, "previous_state")) {
    previous_state = undefined;
}
if (!variable_instance_exists(id, "last_foraged_target_id")) {
    last_foraged_target_id = noone;
}
if (!variable_instance_exists(id, "last_foraged_slot_index")) {
    last_foraged_slot_index = -1;
}
if (!variable_instance_exists(id, "last_foraged_type_tag")) {
    last_foraged_type_tag = "";
}

#endregion

// =========================================================================
// X. INITIALIZE FROM PROFILE METHOD (Called by scr_spawn_system)
// =========================================================================
#region X.1 Initialize From Profile Method
initialize_from_profile = function() {
    // This function is called by scr_spawn_system after the instance is created
    // and self.staticProfileData and self.profileIDStringRef have been assigned.

    var _profile = self.staticProfileData; // Convenience alias for the pop's static data

    // Ensure staticProfileData is valid (it should be, as scr_spawn_system checks)
    if (is_undefined(_profile)) {
        var _msg = $"FATAL (obj_pop.initialize_from_profile): self.staticProfileData is undefined for profile ID '{self.profileIDStringRef}'. This should not happen if spawned via scr_spawn_system.";
        show_error(_msg, true);
        instance_destroy(); // Critical error, remove the pop
        return; // Stop further initialization
    }

    show_debug_message($"INFO (obj_pop.initialize_from_profile): Initializing Pop with Profile ID '{self.profileIDStringRef}', Defined Name: '{_profile.name_display_type}'.");

    // --- Helper function to safely get a sprite asset index ---
    // Defined here to keep it local to this initialization logic.
    var _get_sprite_asset = function(sprite_asset_name_from_profile, fallback_value = undefined) {
        // sprite_asset_name_from_profile is expected to be a string like "spr_pop_man_idle"
        // It can also be undefined or an empty string if the profile doesn't specify it.
        if (is_string(sprite_asset_name_from_profile) && string_length(sprite_asset_name_from_profile) > 0) {
            if (asset_exists(sprite_asset_name_from_profile)) {
                var _asset_index = asset_get_index(sprite_asset_name_from_profile);
                if (asset_get_type(_asset_index) == asset_sprite) {
                    return _asset_index; // Successfully found and it's a sprite
                } else {
                    show_debug_message($"WARNING (obj_pop.initialize_from_profile for {self.profileIDStringRef}): Asset '{sprite_asset_name_from_profile}' found but is NOT a sprite. Using fallback.");
                    return fallback_value;
                }
            } else {
                show_debug_message($"WARNING (obj_pop.initialize_from_profile for {self.profileIDStringRef}): Sprite asset name '{sprite_asset_name_from_profile}' NOT FOUND. Using fallback.");
                return fallback_value;
            }
        }
        // If sprite_asset_name_from_profile was undefined, empty, or not a string, silently use fallback.
        // This allows profiles to intentionally omit sprites.
        return fallback_value;
    };

    // --- 1. Sex Assignment ---
    // Determines the biological sex of the pop, influencing sprites and potentially other attributes.
    self.sex = choose("male", "female"); // Randomly assign sex
    show_debug_message($"INFO (obj_pop.initialize_from_profile): Pop '{_profile.name}' (ID: {self.profileIDStringRef}) assigned sex: {self.sex}.");

    // --- 2. Sprite Initialization (Sex-Specific) ---
    // Sets sprites based on assigned sex and data from _profile.sprite_info.
    // Includes safety checks for missing assets.
    if (struct_exists(_profile, "sprite_info")) {
        var _sprite_info = _profile.sprite_info; // This is the struct like { male_idle: "spr_pop_man_idle", ... }
        var _fallback_sprite_asset = undefined; // Default fallback if a specific placeholder (e.g., spr_pop_undefined) isn't available

        // Idle Sprite
        var _idle_sprite_name_key = (self.sex == "male") ? 
            (struct_exists(_sprite_info, "male_idle") ? _sprite_info.male_idle : undefined) :
            (struct_exists(_sprite_info, "female_idle") ? _sprite_info.female_idle : undefined);
        self.spr_idle = _get_sprite_asset(_idle_sprite_name_key, _fallback_sprite_asset);
        self.sprite_index = self.spr_idle; // Set current sprite to idle
        
        // Walk Sprite Prefix String (e.g., "spr_pop_man_walk")
        // This string is used by movement logic to find specific directional sprites (e.g., spr_pop_man_walk_left)
        self.spr_walk_prefix_string = (self.sex == "male") ? 
            (struct_exists(_sprite_info, "male_walk_prefix") ? _sprite_info.male_walk_prefix : undefined) :
            (struct_exists(_sprite_info, "female_walk_prefix") ? _sprite_info.female_walk_prefix : undefined);
        if (is_undefined(self.spr_walk_prefix_string)) {
             show_debug_message($"WARNING (obj_pop.initialize_from_profile for {_profile.name}): Walk sprite prefix string not found in sprite_info for sex '{self.sex}'. Movement animations may fail.");
        }

        // Portrait Sprite
        var _portrait_sprite_name_key = (self.sex == "male") ? 
            (struct_exists(_sprite_info, "male_portrait") ? _sprite_info.male_portrait : undefined) :
            (struct_exists(_sprite_info, "female_portrait") ? _sprite_info.female_portrait : undefined);
        self.spr_portrait = _get_sprite_asset(_portrait_sprite_name_key, _fallback_sprite_asset);
        
        // Death Sprite
        var _death_sprite_name_key = (self.sex == "male") ? 
            (struct_exists(_sprite_info, "male_death") ? _sprite_info.male_death : undefined) :
            (struct_exists(_sprite_info, "female_death") ? _sprite_info.female_death : undefined);
        self.spr_death = _get_sprite_asset(_death_sprite_name_key, _fallback_sprite_asset);

        // Example for other sprites (e.g., attack, gather - add to sprite_info in database if needed)
        // var _attack_sprite_name_key = (self.sex == "male") ? _sprite_info.male_attack : _sprite_info.female_attack;
        // self.spr_attack = _get_sprite_asset(_attack_sprite_name_key, _fallback_sprite_asset);

    } else {
        show_debug_message($"WARNING (obj_pop.initialize_from_profile for {_profile.name}): 'sprite_info' struct not found in profile. Sprites will use Create event defaults or be undefined.");
        // Instance will use whatever defaults were set in Create event (e.g. self.sprite_index = spr_pop_man_idle was an initial default)
        // Or, explicitly set them to undefined here to ensure no accidental carry-over if profile is truly minimal.
        self.spr_idle = undefined;
        self.sprite_index = undefined; 
        self.spr_walk_prefix_string = undefined;
        self.spr_portrait = undefined;
        self.spr_death = undefined;
    }
    self.current_sprite = self.sprite_index; // Ensure current_sprite reflects the chosen idle sprite
    self.image_index = 0; // Reset animation frame
    // If sprite_index is undefined or noone, image_speed 0 prevents errors. Otherwise, standard speed.
    self.image_speed = (is_undefined(self.sprite_index) || self.sprite_index == noone) ? 0 : 1; 


    // --- 3. Name Generation ---
    // Generates a name for the pop. Assumes scr_generate_pop_name(profile_struct, sex_string) exists.
    if (script_exists(asset_get_index("scr_generate_pop_name"))) {
        // Pass the whole profile and the determined sex to the name generator
        self.pop_name = scr_generate_pop_name(_profile, self.sex); 
    } else {
        self.pop_name = _profile.name + " (Unnamed Pop)"; // Fallback name if script is missing
        show_debug_message("WARNING (obj_pop.initialize_from_profile): scr_generate_pop_name script not found. Using fallback name.");
    }
    // pop_identifier_string is used for more detailed logging/identification
    self.pop_identifier_string = self.pop_name + " [InstanceID:" + string(id) + ", Profile:" + self.profileIDStringRef + "]";

    // --- 4. Core Attributes & Stats (based on profile) ---
    // Initialize base stats, abilities, health, speed, etc.

    // Base Movement Speed (from profile, fallback to a default if not specified)
    if (struct_exists(_profile, "base_speed_units_sec")) {
        self.speed = _profile.base_speed_units_sec;
    } else {
        self.speed = 1.0; // Default speed if not in profile
        show_debug_message($"WARNING (obj_pop.initialize_from_profile for {self.pop_identifier_string}): No 'base_speed_units_sec' in profile. Using fallback speed: {self.speed}.");
    }
    
    // Ability Scores (Example: Direct assignment or roll based on profile)
    self.ability_scores = {}; // Initialize as an empty struct
    if (struct_exists(_profile, "base_ability_scores")) {
        var _base_scores_profile = _profile.base_ability_scores; // e.g., { STRENGTH: 10, DEXTERITY: 12 }
        var _score_names = variable_struct_get_names(_base_scores_profile);
        for (var i = 0; i < array_length(_score_names); i++) {
            var _name = _score_names[i]; // e.g., "STRENGTH"
            // TODO: Implement rolling logic if desired, e.g., _base_scores_profile[$ _name] + irandom_range(-2, 2)
            self.ability_scores[$ _name] = _base_scores_profile[$ _name]; // Direct assignment for now
        }
    } else {
        show_debug_message($"WARNING (obj_pop.initialize_from_profile for {self.pop_identifier_string}): 'base_ability_scores' not in profile. Abilities not initialized from profile.");
        // Optionally, initialize with default scores if profile is missing this
        // self.ability_scores[$ "STRENGTH"] = 8; // etc.
    }

    // Derived Stats (e.g., Health)
    var _base_health_from_profile = struct_exists(_profile, "max_health") ? _profile.max_health : 50; // Default base health if not in profile
    var _constitution_bonus = 0;
    // Example: if (struct_exists(self.ability_scores, "CONSTITUTION")) { _constitution_bonus = (self.ability_scores.CONSTITUTION - 10) * 5; }
    self.max_health_stat = _base_health_from_profile + _constitution_bonus;
    self.current_health_stat = self.max_health_stat; // Start with full health

    // --- 5. Skills Initialization ---
    // Sets initial skill aptitudes based on the pop's profile.
    self.skills = {}; // Initialize as an empty struct for skill data
    if (struct_exists(_profile, "base_skill_aptitudes")) {
        var _aptitudes_profile = _profile.base_skill_aptitudes; // e.g., { FORAGING: 0.3, CRAFTING: 0.1 }
        var _skill_enum_keys = variable_struct_get_names(_aptitudes_profile); // These are strings like "FORAGING"
        for (var i = 0; i < array_length(_skill_enum_keys); i++) {
            var _skill_key_str = _skill_enum_keys[i]; // The string key, e.g., "FORAGING"
            var _aptitude_value = _aptitudes_profile[$ _skill_key_str];
            
            // Store skill data. Using the string key from the profile.
            // This assumes skill keys are consistent (e.g., always "FORAGING").
            self.skills[$ _skill_key_str] = {
                aptitude: _aptitude_value, // Innate learning speed/potential
                level: 1,                  // Starting level
                experience: 0,             // Current XP in this level
                progress_to_next_level: 0  // For UI or calculations, typically (current_xp / xp_for_next_level)
                // xp_for_next_level: calculate_xp_for_level(1) // Could be added
            };
        }
    } else {
        show_debug_message($"WARNING (obj_pop.initialize_from_profile for {self.pop_identifier_string}): 'base_skill_aptitudes' not in profile. Skills not initialized from profile.");
    }

    // --- 6. Traits Initialization ---
    // Assigns innate traits from the profile and applies their initial effects.
    self.traits = ds_list_create(); // Initialize a list to store trait profile structs
    if (struct_exists(_profile, "innate_trait_profile_paths") && ds_exists(_profile.innate_trait_profile_paths, ds_type_list)) {
        var _trait_paths_list = _profile.innate_trait_profile_paths;
        for (var i = 0; i < ds_list_size(_trait_paths_list); i++) {
            var _trait_id_string = _trait_paths_list[| i]; // e.g., "TRAIT_STRONG"
            // Assuming global.GameData.GetProfileFromID(id_string) is available and returns the trait's data profile
            var _trait_profile_data = global.GameData.GetProfileFromID(_trait_id_string); 
            
            if (!is_undefined(_trait_profile_data)) {
                ds_list_add(self.traits, _trait_profile_data); // Store the actual trait profile struct
                
                // TODO: Apply initial effects of the trait here.
                show_debug_message("INFO (obj_pop Create for " + self.pop_identifier_string + "): Added innate trait '" + _trait_profile_data.name + "'.");            } else {
                show_debug_message("WARNING (obj_pop Create for " + self.pop_identifier_string + "): Innate trait profile ID '" + string(_trait_id) + "' not found in GameData. Trait not added.");
            }
        }
    } else {
         // show_debug_message("INFO (obj_pop Create for " + self.pop_identifier_string + "): No 'innate_trait_profile_ids' array in profile or array is empty. No innate traits assigned from profile.");
    }

    // --- 7. Inventory Initialization ---
    // Initializes inventory-related variables and data structures.
    // This is separated from the main initialization to allow for easier overrides or custom logic
    // in the future, such as loading inventory from a save file or applying starting items from the profile.
    self.inventory_items = ds_list_create(); // Create the inventory list
    self.max_inventory_capacity = 10; // Default capacity, can be overridden by profile or other logic
    self.hauling_threshold = 10;    // Default threshold for when to start hauling items
    // Note: Actual items will be added to the inventory in a separate step, typically after this initialization phase.

    // --- 8. Debug/Info Logging ---
    // Initial logging for debugging purposes. Can be expanded or modified based on needs.
    show_debug_message("DEBUG (obj_pop Create for " + self.pop_identifier_string + "): Initialization complete. Current state: " + string(state) + ", Position: (" + string(x) + ", " + string(y) + "), Depth: " + string(depth) + ".");
    // Consider adding more detailed logs for each major step or variable of interest.
    // Example: show_debug_message("DEBUG (obj_pop Create): Assigned sprites - Idle: " + string(self.spr_idle) + ", Walk Prefix: " + self.spr_walk_prefix_string + ", Portrait: " + self.spr_portrait + ", Death: " + self.spr_death + ".");
};
#endregion

// --- 0. Validate Injected Data ---
// Ensure entity_data has been set by the spawner (scr_spawn_entity)
if (!variable_instance_exists(self, "entity_data") || !is_struct(self.entity_data)) {
    var _error_msg = "FATAL (obj_pop Create): self.entity_data was not provided or is not a struct. Entity Type ID: " 
                   + (variable_instance_exists(self, "entity_type_id") ? string(self.entity_type_id) : "UNKNOWN") 
                   + ". Cannot initialize.";
    show_error(_error_msg, true);
    instance_destroy(); // Destroy self if no data
    exit; // Stop further execution of the Create event
}

// Assign self.entity_data to self.pop for compatibility with existing code that uses self.pop
// This ensures that scripts like scr_pop_wandering can access entity properties via self.pop.
self.pop = self.entity_data;

// Convenience alias for the injected data, used throughout this Create event.
var _data = self.entity_data; 

