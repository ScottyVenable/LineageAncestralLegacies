/// scr_generate_pop_details.gml
///
/// Purpose:
///    Generates and assigns initial details for a newly created pop instance.
///    This includes sex, name, age, scale based on age, stats (as ability_scores struct),
///    traits, likes, dislikes, and an empty inventory struct.
///
/// Metadata:
///    Version:       1.4 - 2024-05-19 // Scotty's Current Date - Added missing vars for UI Panel compatibility
///    Dependencies:  scr_generate_pop_name, EntitySex enum, PopSkill enum (optional)

function scr_generate_pop_details(life_stage) {
    // =========================================================================
    // A. DETERMINE SEX
    // =========================================================================
    #region A. Determine Sex
    if (random(1) < 0.5) {
        sex = EntitySex.MALE;
    } else {
        sex = EntitySex.FEMALE;
    }
    #endregion

    // =========================================================================
    // B. GENERATE NAME BASED ON SEX
    // =========================================================================
    #region B. Generate Name
    // The name generation logic has been centralized in scr_generate_pop_name.
    // This script (scr_generate_pop_details) will now call scr_generate_pop_name
    // to ensure consistency with the new name_data.json structure and fallback mechanisms.

    // The _profile_struct argument for scr_generate_pop_name would typically be `self` or a specific struct
    // containing entity data. Since this script operates within the context of a pop instance (implied by `id`,
    // `pop_name`, `sex` being directly assigned), we can create a minimal profile struct or pass `self` if appropriate.
    // For now, we'll create a minimal struct. If more pop-specific data (like race, culture)
    // influences name generation in the future, this struct can be expanded or `self` can be passed.
    var _pop_profile_for_name = {
        // type_tag is used by scr_generate_pop_name's fallback if _entity_data.type_tag exists.
        // We can set a default here or leave it to be handled by the fallback in scr_generate_pop_name.
        // For example, if this script is always for a "Pop" type:
        type_tag: "Pop" 
        // Add other relevant properties from the pop instance if scr_generate_pop_name needs them.
    };

    // Call the centralized name generation function.
    // It uses global.GameData.name_data (male_names, female_names) and handles fallbacks.
    var _generated_name = scr_generate_pop_name(_pop_profile_for_name, sex);

    // Assign the generated name to the pop's properties
    pop_name = _generated_name;
    pop_identifier_string = _generated_name; // Assuming pop_identifier_string should also use this name.

    // The fallback logic is now handled within scr_generate_pop_name, so the old fallback here is removed.
    // A debug message can still be useful if the name ends up being a generic fallback.
    if (string_pos("Pop_" + string(id), _generated_name) > 0 || string_pos("Entity_" + string(id), _generated_name) > 0) {
        show_debug_message("Info: A generic fallback name was assigned to pop: " + _generated_name);
    }
    #endregion

    // =========================================================================
    // C. ASSIGN AGE & SCALE
    // =========================================================================
    #region C. Assign Age & Scale
    age = irandom_range(18, 50); // Adults for now
    
    var _target_scale = 3.0; // Default adult scale
    if (age <= 12) { _target_scale = 1.5; }         // Child
    else if (age <= 17) { _target_scale = 2.25; }   // Teen
    // else if (age <= 50) { _target_scale = 3.0; } // Adult (covered by default)
    else if (age > 50) { _target_scale = 2.8; }     // Elder
    image_xscale = _target_scale;
    image_yscale = _target_scale;
    #endregion

    // =========================================================================
    // D. INITIALIZE CORE STATS (Needs, Health, Energy)
    // =========================================================================
    #region D. Core Stats
    // These are individual instance variables
    max_health = irandom_range(80, 120); // Example
    health = max_health;
    max_hunger = 100;
    hunger = irandom_range(20, max_hunger - 20); // Start somewhat full
    max_thirst = 100;
    thirst = irandom_range(20, max_thirst - 20);
    max_energy = 100;
    energy = irandom_range(70, max_energy);
	

	
    // mood, etc. can be added here later
    #endregion
    
    // =========================================================================
    // E. INITIALIZE ABILITY SCORES (as a struct for the UI Panel)
    // =========================================================================
    #region E. Ability Scores Struct
    ability_scores = {
        strength     : irandom_range(3, 8), // Example 1-10 scale or similar
        agility      : irandom_range(3, 8),
        intelligence : irandom_range(3, 8),
        perception   : irandom_range(3, 8),
        charisma     : irandom_range(3, 8),
        constitution : irandom_range(3, 8) 
        // Note: constitution here is an ability score, max_health above might be derived from it later.
    };
    #endregion

    // =========================================================================
    // F. INITIALIZE SKILLS (as a struct)
    // =========================================================================
    #region F. Skills Struct
    // skills = {}; // This is already a struct
    // The UI Panel doesn't directly list 'skills' like 'ability_scores',
    // but good to have it initialized.
    // Your existing PopSkill enum logic is fine here.
    // For example:
    // if (variable_global_exists("PopSkill") && enum_exists(PopSkill)) { // Check if PopSkill enum is defined
    //     skills[$ PopSkill.FORAGING] = irandom_range(1, 10);
    //     skills[$ PopSkill.CRAFTING_GENERAL] = irandom_range(1, 5);
    // } else {
    //     show_debug_message("Warning (scr_generate_pop_details): PopSkill enum not found. Skills not fully initialized.");
    // }
    skills = {}; // Ensure it's an empty struct if PopSkill enum doesn't exist or fails
    #endregion

    // =========================================================================
    // G. INITIALIZE TRAITS, LIKES, DISLIKES (as arrays for UI Panel)
    // =========================================================================
    #region G. Traits, Likes, Dislikes Arrays
    pop_traits = [];    // UI Panel expects "pop_traits"
    pop_likes = [];     // UI Panel expects "pop_likes"
    pop_dislikes = [];  // UI Panel expects "pop_dislikes"
    
    // Example of adding a random trait:
    // var _possible_traits = ["Brave", "Quick Learner", "Strong", "Grumpy", "Optimist"];
    // if (random(1) < 0.3) { // 30% chance to get one trait
    //     array_push(pop_traits, _possible_traits[irandom(array_length(_possible_traits)-1)]);
    // }
    #endregion

    // =========================================================================
    // H. INITIALIZE INVENTORY (as a struct for UI Panel - if scr_inventory_struct_draw expects it)
    // =========================================================================
    #region H. Inventory Struct
	inventory_items = ds_list_create(); // Initialize as an empty ds_list
	inventory_capacity_weight = 10.0; // Example: Max weight pop can carry
	current_inventory_weight = 0.0;   // Current weight of items in inventory
    #endregion

    show_debug_message($"	- Pop Details Generated for ID {id}: Name='{pop_name}', Sex={sex}, Age={age}, Scale={image_xscale}. All UI panel vars should be set.");
	show_debug_message("Working directory: " + working_directory);
}