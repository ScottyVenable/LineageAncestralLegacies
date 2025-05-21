/// scr_generate_pop_details.gml
///
/// Purpose:
///    Generates and assigns initial details for a newly created pop instance.
///    This includes sex, name, age, scale based on age, stats (as ability_scores struct),
///    traits, likes, dislikes, and an empty inventory struct.
///
/// Metadata:
///    Version:       1.4 - 2024-05-19 // Scotty's Current Date - Added missing vars for UI Panel compatibility
///    Dependencies:  scr_pop_names, PopSex enum, PopSkill enum (optional)

function scr_generate_pop_details() {
    // =========================================================================
    // A. DETERMINE SEX
    // =========================================================================
    #region A. Determine Sex
    if (random(1) < 0.5) {
        sex = PopSex.MALE;
    } else {
        sex = PopSex.FEMALE;
    }
    #endregion

    // =========================================================================
    // B. GENERATE NAME BASED ON SEX
    // =========================================================================
    #region B. Generate Name
    var _prefixes_list;
    var _suffixes_list;
    var _name_base = "";

    if (sex == PopSex.MALE) {
        _prefixes_list = get_male_name_prefixes();
        _suffixes_list = get_male_name_suffixes();
        _name_base = "MalePop";
    } else { // FEMALE
        _prefixes_list = get_female_name_prefixes();
        _suffixes_list = get_female_name_suffixes();
        _name_base = "FemalePop";
    }

    var _prefix = (_prefixes_list != undefined && array_length(_prefixes_list) > 0) ? _prefixes_list[irandom(array_length(_prefixes_list) - 1)] : "";
    var _suffix = (_suffixes_list != undefined && array_length(_suffixes_list) > 0) ? _suffixes_list[irandom(array_length(_suffixes_list) - 1)] : "";
    var _generated_name = _prefix + _suffix;

    if (_generated_name == "") {
        _generated_name = _name_base + string(id); // Use instance id for fallback
    }
    
    pop_name = _generated_name;
    pop_identifier_string = pop_name; // UI Panel uses this
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
    inventory = {
        // items : ds_map_create() // Example if your inventory struct uses a ds_map internally
        // For scr_inventory_struct_draw, it might just iterate struct members if items are directly keys
        // e.g., inventory.berry = 5, inventory.stone = 10
        // For now, an empty struct is a safe start.
        // If scr_inventory_struct_draw expects specific fields, add them here.
    }; 
    // Or, if your inventory is a ds_map:
    // inventory = ds_map_create();
    // The UI panel calls scr_inventory_struct_draw, so a struct is more likely.
    #endregion

    show_debug_message($"Pop Details Generated for ID {id}: Name='{pop_name}', Sex={sex}, Age={age}, Scale={image_xscale}. All UI panel vars should be set.");
}