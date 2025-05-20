/// scr_generate_pop_details.gml
///
/// Purpose:
///    Generates and assigns initial details for a newly created pop instance.
///    This includes sex, name, age, scale based on age, and placeholders for
///    stats, abilities, and traits.
///
/// Metadata:
///    Version:       1.3 - [Current Date] (Added age-based scaling)
///    Dependencies:  scr_pop_names, PopSex enum, PopSkill enum

function scr_generate_pop_details() {
    // ... (A. Determine Sex, B. Generate Name - no changes here) ...

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

    var _prefix = "";
    var _suffix = "";

    if (array_length(_prefixes_list) > 0) {
        _prefix = _prefixes_list[irandom(array_length(_prefixes_list) - 1)];
    }
    if (array_length(_suffixes_list) > 0) {
        _suffix = _suffixes_list[irandom(array_length(_suffixes_list) - 1)];
    }

    var _generated_name = _prefix + _suffix;

    if (_generated_name == "") {
        _generated_name = _name_base + string(id);
    }
    
    pop_name = _generated_name;
    pop_identifier_string = pop_name;
    #endregion

    // =========================================================================
    // C. ASSIGN AGE
    // =========================================================================
    #region C. Assign Age
    age = irandom_range(18, 64); // For starting adult pops
    // Later, for newborn pops, age would start at 0
    #endregion

    // =========================================================================
    // C.2. SET SCALE BASED ON AGE <<<<< NEW SECTION >>>>>
    // =========================================================================
    #region C.2 Set Scale Based on Age
    var _target_scale = 3.0; // Default to adult scale

    if (age <= 12) { // Child
        _target_scale = 1.5;
    } else if (age <= 17) { // Teenager
        _target_scale = 2.25;
    } else if (age <= 64) { // Adult
        _target_scale = 3.0;
    } else { // Elder (65+)
        _target_scale = 2.8;
    }

    // 'image_xscale' and 'image_yscale' are instance variables of the calling obj_pop
    image_xscale = _target_scale;
    image_yscale = _target_scale;
    #endregion

    // =========================================================================
    // D. INITIALIZE STATS & ABILITIES (Placeholders)
    // =========================================================================
    #region D. Stats & Abilities
    strength = irandom_range(30, 70);
    agility = irandom_range(30, 70);
    intelligence = irandom_range(30, 70);
    perception = irandom_range(30, 70);
    charisma = irandom_range(30, 70);
    constitution = irandom_range(40, 80);

    health = constitution;
    max_health = constitution;
    hunger = irandom_range(0, 40);
    max_hunger = 100;
    thirst = irandom_range(0, 30);
    max_thirst = 100;
    energy = irandom_range(60, 100);
    max_energy = 100;
    
    skills = {};
    if (variable_global_exists("PopSkill")) {
        skills[PopSkill.FORAGING] = irandom_range(1, 10);
        skills[PopSkill.CRAFTING_GENERAL] = irandom_range(1, 5);
        skills[PopSkill.CONSTRUCTION] = irandom_range(1, 5);
        skills[PopSkill.HAULING] = irandom_range(5, 15);
    } else {
        show_debug_message("WARNING (scr_generate_pop_details): PopSkill enum not found globally. Skills not initialized by type.");
    }
    #endregion

    // =========================================================================
    // E. ASSIGN TRAITS (Placeholder)
    // =========================================================================
    #region E. Traits
    traits = [];
    #endregion

    show_debug_message($"Pop Details Generated for {id}: Name='{pop_name}', Sex={sex}, Age={age}, Scale={image_xscale}");
}