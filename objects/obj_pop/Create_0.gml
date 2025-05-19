/// obj_pop – Create Event
///
/// Purpose:
///     Initialize pop state variables, wander parameters, foraging settings (including
///     dynamic forage efficiency based on stats/traits), inventory, and detailed
///     character profile information including modular, gender-specific names
///     (sourced from scr_pop_names.gml) and age-reflective traits.
///     Uses manual random array element picking and manual array index finding
///     due to potential issues with built-in array_random() and array_indexOf().
///
/// Metadata:
///     Summary:        Set up initial variables for pop behavior, inventory, character data, and dynamic forage efficiency.
///     Usage:          obj_pop Create Event
///     Parameters:     none
///     Returns:        void
///     Tags:           [behavior][init][data][character][gendered_names][identifier][stats][foraging]
///     Version:        2.1 — 2025-05-18 (Implemented dynamic pop_forage_efficiency based on stats/traits)
///     Dependencies:   scr_pop_names.gml (for get_male_name_prefixes, etc.)

// ============================================================================
// 0. IMPORTS & CACHES
// ============================================================================
#region 0.1 Imports & Cached Locals
// (none)
#endregion

// ============================================================================
// 1. CHARACTER PROFILE & STATS
// ============================================================================
#region 1.1 Demographics & Identity
// --- Sex ---
pop_sex = choose("Male", "Female"); 

// --- Name Generation (Modular & Primitive Style using lists from scr_pop_names.gml) ---
var _name_connectors = ["'", "-", ""]; 
var _prefix = "Pop"; 
var _suffix = "Err"; 

var _male_prefixes = get_male_name_prefixes();
var _male_suffixes = get_male_name_suffixes();
var _female_prefixes = get_female_name_prefixes();
var _female_suffixes = get_female_name_suffixes();

// Helper for manual array random
var _manual_array_random = function(arr) {
    if (!is_array(arr) || array_length(arr) == 0) return undefined;
    return arr[irandom(array_length(arr) - 1)];
}

// Helper for manual array_indexOf
var _manual_array_index_of = function(arr, val_to_find) {
    if (!is_array(arr)) return -1;
    for (var i = 0; i < array_length(arr); i++) {
        if (arr[i] == val_to_find) {
            return i; // Found it, return index
        }
    }
    return -1; // Not found
}

if (pop_sex == "Male") {
    _prefix = array_length(_male_prefixes) > 0 ? _manual_array_random(_male_prefixes) : "Mako";
    _suffix = array_length(_male_suffixes) > 0 ? _manual_array_random(_male_suffixes) : "Nar";
} else { // Female
    _prefix = array_length(_female_prefixes) > 0 ? _manual_array_random(_female_prefixes) : "Fela";
    _suffix = array_length(_female_suffixes) > 0 ? _manual_array_random(_female_suffixes) : "Shi";
}

var _connector = array_length(_name_connectors) > 0 ? _manual_array_random(_name_connectors) : "";


if (random(1) < 0.1 && string_length(_prefix) <= 3) { 
    pop_name = _prefix;
} else if (random(1) < 0.05 && string_length(_suffix) <= 3 && pop_name != _prefix) { 
    pop_name = _suffix;
} else {
    if (_connector == "'" && 
        (string_ends_with(_prefix, "a") || string_ends_with(_prefix, "e") || string_ends_with(_prefix, "i") || string_ends_with(_prefix, "o") || string_ends_with(_prefix, "u")) &&
        (string_starts_with(_suffix, "a") || string_starts_with(_suffix, "e") || string_starts_with(_suffix, "i") || string_starts_with(_suffix, "o") || string_starts_with(_suffix, "u"))) {
        _connector = ""; 
    }
    pop_name = _prefix + _connector + _suffix;
}

if (pop_name != "") {
    pop_name = string_upper(string_char_at(pop_name, 1)) + string_delete(pop_name, 1, 1); 
} else {
    pop_name = (pop_sex == "Male") ? "Unknown Male" : "Unknown Female"; 
}

pop_age = irandom_range(18, 70); 

var _sex_symbol = (pop_sex == "Male") ? "♂" : "♀"; 
pop_identifier_string = $"{pop_name} ({_sex_symbol}{pop_age})"; 
#endregion

#region 1.2 Ability Scores
ability_scores = {
    strength:     irandom_range(8, 15), 
    dexterity:    irandom_range(8, 15),
    constitution: irandom_range(8, 15),
    intelligence: irandom_range(8, 15),
    wisdom:       irandom_range(8, 15),
    charisma:     irandom_range(8, 15)
};
#endregion

#region 1.3 Traits, Likes, & Dislikes
var _all_traits_neutral = [ 
    "Optimistic", "Pessimistic", "Hardworking", "Lazy", "Generous", "Greedy", 
    "Loyal", "Independent", "Artistic", "Practical", "Apathetic", "Quiet"
];
var _all_traits_young = ["Brave", "Curious", "Energetic", "Idealistic", "Impulsive", "Adventurous"];
var _all_traits_middle = ["Responsible", "Balanced", "Resourceful", "Ambitious", "Patient"];
var _all_traits_old = ["Cautious", "Wise", "Calm", "Traditional", "Stoic", "Grumpy", "Reflective"];

pop_traits = [];
var _num_traits_to_pick = irandom_range(1, 3); 

var _age_category = "middle";
if (pop_age <= 29) _age_category = "young";
else if (pop_age >= 50) _age_category = "old";

repeat (_num_traits_to_pick) {
    var _trait_pool = [];
    switch (_age_category) {
        case "young":  _trait_pool = array_concat(_trait_pool, _all_traits_young); break;
        case "middle": _trait_pool = array_concat(_trait_pool, _all_traits_middle); break;
        case "old":    _trait_pool = array_concat(_trait_pool, _all_traits_old); break;
    }
    if (random(1) < 0.7) _trait_pool = array_concat(_trait_pool, _all_traits_neutral);
    // Allow a small chance to pick from any trait list, regardless of age, for variety
    if (random(1) < 0.15) _trait_pool = array_concat(_trait_pool, _all_traits_young, _all_traits_middle, _all_traits_old, _all_traits_neutral);
    
    if (array_length(_trait_pool) > 0) {
        var _new_trait = _manual_array_random(_trait_pool); 
        if (_new_trait != undefined && _manual_array_index_of(pop_traits, _new_trait) == -1) { // Using manual helper
            array_push(pop_traits, _new_trait);
        }
    }
}
if (array_length(pop_traits) == 0 && array_length(_all_traits_neutral) > 0) {
    var _default_trait = _manual_array_random(_all_traits_neutral); 
    if (_default_trait != undefined) array_push(pop_traits, _default_trait);
}

var _all_likes = [
    "Sunlight", "Storytelling", "The Hunt", "Gathering", "Stillness", 
    "The Hearth", "Carving", "Drumming", "Stargazing", "Herbs"
]; 
pop_likes = [];
var _num_likes = irandom_range(1, 2);
repeat (_num_likes) {
    if (array_length(_all_likes) > 0) {
        var _new_like = _manual_array_random(_all_likes); 
        if (_new_like != undefined && _manual_array_index_of(pop_likes, _new_like) == -1) { // Using manual helper
            array_push(pop_likes, _new_like);
        }
    }
}

var _all_dislikes = [
    "Loud Screams", "The Outsiders", "Deep Caves", "Being Watched", "Rotten Food",
    "Bitter Cold", "Wastefulness", "Sudden Changes", "Weakness", "The Dark Unknown"
]; 
pop_dislikes = [];
var _num_dislikes = irandom_range(1, 2);
repeat (_num_dislikes) {
     if (array_length(_all_dislikes) > 0) {
        var _new_dislike = _manual_array_random(_all_dislikes); 
        if (_new_dislike != undefined && _manual_array_index_of(pop_dislikes, _new_dislike) == -1) { // Using manual helper
            array_push(pop_dislikes, _new_dislike);
        }
    }
}
#endregion

// ============================================================================
// 2. INITIAL STATE VARIABLES 
// ============================================================================
#region 2.1 Behavior State
state                   = PopState.IDLE;
position_marker         = noone;
idle_timer              = 0;
idle_min_sec            = 1;
idle_max_sec            = 5;
idle_target_time        = 0;
bob_timer               = 0;
bob_state               = false;
has_arrived             = false;
was_commanded           = false;
after_command_idle_time = 10; 
is_waiting              = false;
#endregion

// ============================================================================
// 3. WANDER SETTINGS 
// ============================================================================
#region 3.1 Wander Counters
wander_pts            = 0;  
target_wander_pts     = 0;  
min_wander_pts        = 1;  
max_wander_pts        = 10; 
#endregion

#region 3.2 Wander Radius
wander_min_dist = 50;
wander_max_dist = 150;
#endregion

// ============================================================================
// 4. FORAGING SETTINGS 
// ============================================================================
#region 4.1 Foraging Parameters
target_bush  = noone;         
forage_timer = 0;             
BASE_SECONDS_PER_FORAGE_ITEM = 5.0; // Base time in seconds to gather one item for an average pop
#endregion

#region 4.2 Foraging Efficiency Calculation
// pop_forage_efficiency: Multiplier for how quickly a pop forages.
// 1.0 = normal speed. >1.0 = faster. <1.0 = slower.
pop_forage_efficiency = 1.0; // Start with base efficiency

// --- Adjust by Ability Scores ---
var _wisdom_score = ability_scores.wisdom;
var _dex_score = ability_scores.dexterity;

// Wisdom: Affects understanding of plants, efficient techniques (e.g., +/- 4% per point from 10)
if (_wisdom_score > 10) {
    pop_forage_efficiency += (_wisdom_score - 10) * 0.04; 
} else if (_wisdom_score < 10) {
    pop_forage_efficiency -= (10 - _wisdom_score) * 0.04;
}

// Dexterity: Affects speed of picking/handling (e.g., +/- 2% per point from 10)
if (_dex_score > 10) {
    pop_forage_efficiency += (_dex_score - 10) * 0.02;
} else if (_dex_score < 10) {
    pop_forage_efficiency -= (10 - _dex_score) * 0.02;
}

// --- Adjust by Traits ---
for (var i = 0; i < array_length(pop_traits); i++) {
    var _trait = pop_traits[i];
    switch (_trait) {
        case "Hardworking": pop_forage_efficiency += 0.25; break; // 25% faster
        case "Lazy":        pop_forage_efficiency -= 0.30; break; // 30% slower
        case "Resourceful": pop_forage_efficiency += 0.15; break; // 15% faster
        case "Energetic":   pop_forage_efficiency += 0.10; break; // 10% faster
        case "Practical":   pop_forage_efficiency += 0.10; break; // 10% faster
        case "Cautious":    pop_forage_efficiency -= 0.05; break; // Slightly slower, more careful
        // Add more traits and their effects here
        // e.g., case "Clumsy": pop_forage_efficiency -= 0.15; break;
    }
}

// --- Clamp efficiency to a minimum (e.g., 10% speed) to prevent division by zero or negative rates ---
pop_forage_efficiency = max(0.1, pop_forage_efficiency); 
#endregion

// ============================================================================
// 5. SELECTION & ORDERING 
// ============================================================================
#region 5.1 Selection & Orders
selected       = false;
order_id       = -1;
travel_point_x = x; 
travel_point_y = y;
#endregion

// ============================================================================
// 6. INVENTORY INITIALIZATION 
// ============================================================================
#region 6.1 Inventory Setup
inventory = {}; 
#endregion

// ============================================================================
// 7. FINAL DEBUG LOG (Optional)
// ============================================================================
#region 7.1 Creation Log
var _traits_string = "";
if (array_length(pop_traits) > 0) {
    _traits_string = pop_traits[0];
    for (var i = 1; i < array_length(pop_traits); i++) {
        _traits_string += ", " + pop_traits[i];
    }
} else {
    _traits_string = "None";
}
var _efficiency_string = string_format(pop_forage_efficiency, 1, 2); // Format to 2 decimal places

show_debug_message($"Pop Created (ID: {id}): {pop_identifier_string}. Traits: [{_traits_string}]. Forage Efficiency: {_efficiency_string}. Inventory: {string(inventory)}");
#endregion
