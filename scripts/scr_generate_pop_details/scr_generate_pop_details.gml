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

function scr_generate_pop_details(life_stage) {
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

    // Check if the pop is in the TRIBAL life stage
    if (life_stage == PopLifeStage.TRIBAL) {
        if (sex == PopSex.MALE) {
            _prefixes_list = scr_load_text_file_lines(working_directory + "\\namedata\\pops\\tribal_stage\\tribal_male_prefixes.txt");
            _suffixes_list = scr_load_text_file_lines(working_directory + "\\namedata\\pops\\tribal_stage\\tribal_male_suffixes.txt");
        } else { // FEMALE
            _prefixes_list = scr_load_text_file_lines(working_directory + "\\namedata\\pops\\tribal_stage\\tribal_female_prefixes.txt");
            _suffixes_list = scr_load_text_file_lines(working_directory + "\\namedata\\pops\\tribal_stage\\tribal_female_suffixes.txt");
        }
    } else {
        // Default to global prefixes and suffixes
        if (sex == PopSex.MALE) {
            _prefixes_list = global.male_prefixes;
            _suffixes_list = global.male_suffixes;
            _name_base = "MalePop";
        } else { // FEMALE
            _prefixes_list = global.female_prefixes;
            _suffixes_list = global.female_suffixes;
            _name_base = "FemalePop";
        }
    }

    // Generate a prefix and suffix for the name
    // Ensure prefix and suffix are concatenated without unintended characters
    var _prefix = (_prefixes_list != undefined && array_length(_prefixes_list) > 0) ? string(_prefixes_list[irandom(array_length(_prefixes_list) - 1)]) : "";
    var _suffix = (_suffixes_list != undefined && array_length(_suffixes_list) > 0) ? string(_suffixes_list[irandom(array_length(_suffixes_list) - 1)]) : "";

    // Combine prefix and suffix into a single name
    var _generated_name = _prefix + _suffix;

    // Assign the combined name to pop_identifier_string
    pop_identifier_string = _generated_name;

    // Ensure a fallback name is used if no prefix or suffix is available
    if (_generated_name == "") {
        _generated_name = _name_base + string(id); // Use instance id for fallback
        show_debug_message("Fallback name used for pop: " + _generated_name);
    }

    // Assign the generated name to the pop
    pop_name = _generated_name;
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