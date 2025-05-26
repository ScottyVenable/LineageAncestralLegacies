/// obj_structure_controller - Create Event
///
/// Purpose:
///    Initializes a generic structure controller based on entity_data
///    provided during its creation by scr_spawn_entity.
///
/// Metadata:
///    Summary:         Sets up structure properties from data.
///    Usage:           Called when a structure controller is spawned.
///    Tags:            [controller][structure][init][data_driven]
///    Version:         1.0 - 2025-05-25 // Initial version
///    Dependencies:    scr_spawn_entity, scr_database (get_entity_data)
///    Author:          GitHub Copilot

// This controller instance expects entity_type and entity_data to be injected by scr_spawn_entity
// entity_type = undefined; // Example: EntityType.STRUCTURE_HUT_SIMPLE
// entity_data = undefined; // Struct containing all data from get_entity_data()
// self.staticProfileData = undefined; // Injected by spawn_single_instance
// self.profileIDStringRef = undefined; // Injected by spawn_single_instance

// --- Method to initialize the instance based on the provided entity_data ---
/// @function initialize_from_profile()
/// @description Initializes the structure's properties using the self.staticProfileData struct.
///              This method is called by scr_spawn_system.spawn_single_instance after the instance is created
///              and self.staticProfileData / self.profileIDStringRef are injected.
initialize_from_profile = function() {
    // Ensure staticProfileData has been set by the spawner
    if (!is_struct(self.staticProfileData)) {
        var _error_msg = $"ERROR (obj_structure_controller): self.staticProfileData was not provided or is not a struct. Profile ID: '{self.profileIDStringRef}'. Cannot initialize.";
        show_error(_error_msg, true);
        show_debug_message(_error_msg); // Using show_debug_message for broader compatibility
        instance_destroy(); // Destroy self if no data
        return;
    }

    var _profile = self.staticProfileData;
    var _profile_id = self.profileIDStringRef; // For logging and debugging

    show_debug_message($"Initializing Structure from Profile: '{_profile_id}' (Object: {_profile.object_to_spawn})");

    // --- Core Visual & Identifier Properties ---
    // Name and Description from the profile
    self.display_name = variable_struct_exists(_profile, "display_name") ? _profile.display_name : "Unknown Structure";
    self.description = variable_struct_exists(_profile, "description") ? _profile.description : "A structure.";

    // Visuals: sprite_index from sprite_info
    if (variable_struct_exists(_profile, "sprite_info") && is_struct(_profile.sprite_info) && variable_struct_exists(_profile.sprite_info, "default")) {
        sprite_index = _profile.sprite_info.default;
    } else {
        sprite_index = spr_placeholder_structure; // Ensure spr_placeholder_structure exists
        show_debug_message($"Warning (obj_structure_controller): Profile '{_profile_id}' has no sprite_info.default. Using placeholder.");
    }
    // Image speed from sprite_info or general animation property
    if (variable_struct_exists(_profile, "sprite_info") && is_struct(_profile.sprite_info) && variable_struct_exists(_profile.sprite_info, "image_speed")) {
        image_speed = _profile.sprite_info.image_speed;
    } else {
        image_speed = (sprite_index == spr_placeholder_structure) ? 0 : 1; // Default to static for structures, 0 for static placeholders
    }

    // --- Health & Durability (from StatsBase or similar in profile) ---
    self.is_destructible = variable_struct_exists(_profile, "is_destructible") ? _profile.is_destructible : true;
    self.max_health = variable_struct_exists(_profile, "StatsBase") && variable_struct_exists(_profile.StatsBase, "MaxHealth") ? _profile.StatsBase.MaxHealth : 100;
    self.current_health = self.max_health; // Structures usually start at full health
    self.is_repairable = variable_struct_exists(_profile, "is_repairable") ? _profile.is_repairable : true;
    self.decay_rate_per_day = variable_struct_exists(_profile, "decay_rate_per_day") ? _profile.decay_rate_per_day : 0; // 0 means no decay

    // --- Construction (from construction_info struct or similar) ---
    // build_materials_cost: An array of { item_profile_path: "UniqueID.Item_Stone", quantity: 10 } structs.
    self.build_materials_cost_paths = (variable_struct_exists(_profile, "construction_info") && is_struct(_profile.construction_info) && variable_struct_exists(_profile.construction_info, "build_materials_cost_paths")) 
                                      ? array_clone(_profile.construction_info.build_materials_cost_paths) 
                                      : [];
    self.build_time_seconds = (variable_struct_exists(_profile, "construction_info") && is_struct(_profile.construction_info) && variable_struct_exists(_profile.construction_info, "build_time_seconds")) 
                              ? _profile.construction_info.build_time_seconds 
                              : 10;
    self.required_tech_profile_path = (variable_struct_exists(_profile, "construction_info") && is_struct(_profile.construction_info) && variable_struct_exists(_profile.construction_info, "required_tech_profile_path")) 
                                     ? _profile.construction_info.required_tech_profile_path 
                                     : undefined;

    // --- Functionality & Interaction ---
    self.worker_slots_max = variable_struct_exists(_profile, "worker_slots_max") ? _profile.worker_slots_max : 0;
    self.current_workers = []; // Array to store instance IDs of pops working here

    // Inventory (if it has one, using inventory_template_profile_path)
    self.inventory_instance_id = undefined;
    if (variable_struct_exists(_profile, "inventory_template_profile_path")) {
        // self.inventory_instance_id = scr_inventory_create(self, _profile.inventory_template_profile_path);
        show_debug_message($"Note (obj_structure_controller): Profile '{_profile_id}' has inventory. Inventory creation logic placeholder.");
    }

    // Buffs it provides (array of buff profile paths)
    self.provided_buff_profile_paths = variable_struct_exists(_profile, "provided_buff_profile_paths") && is_array(_profile.provided_buff_profile_paths) 
                                       ? array_clone(_profile.provided_buff_profile_paths) 
                                       : [];
    self.aura_effect_radius_pixels = variable_struct_exists(_profile, "aura_effect_radius_pixels") ? _profile.aura_effect_radius_pixels : 0;

    // Shelter Quality
    self.shelter_quality_rating = variable_struct_exists(_profile, "shelter_quality_rating") ? _profile.shelter_quality_rating : "none"; // e.g., "none", "poor", "adequate"

    // --- Classification & Progression ---
    // Structure Category (e.g., from a classification struct or direct property)
    self.structure_category_profile_path = variable_struct_exists(_profile, "structure_category_profile_path") ? _profile.structure_category_profile_path : undefined;
    
    // Tags: Keywords for easy searching/categorization
    self.tags = variable_struct_exists(_profile, "tags") && is_array(_profile.tags) ? array_clone(_profile.tags) : [];

    // Upgrade Path (profile path for the upgraded structure)
    self.upgrade_to_profile_path = variable_struct_exists(_profile, "upgrade_to_profile_path") ? _profile.upgrade_to_profile_path : undefined;

    // --- State Variables (examples) ---
    self.is_under_construction = false; // Could be true initially if spawned via a "place blueprint" action
    self.construction_progress = 0;     // Current progress towards build_time_seconds
    self.is_operational = true;         // Default to operational unless specific conditions (e.g. needs power, workers)
    
    // TODO: Apply effects of any inherent traits or buffs if structures can have them.
    // Similar to how pops/creatures might apply innate traits.

    show_debug_message($"Structure '{_profile_id}' initialized successfully.");

}; // End of initialize_from_profile

// --- Call the initialization method ---
// Old call, remove or comment out.
// The new system expects spawn_single_instance to call initialize_from_profile()

// Example of how it was previously:
// if (instance_exists(self)) { // Check if not destroyed by init
//     if (is_method(self, initialize_from_data)) {
//         initialize_from_data();
//     } else {
//         show_error("obj_structure_controller: initialize_from_data method not found!", true);
//     }
// }

// The above block should be removed.
