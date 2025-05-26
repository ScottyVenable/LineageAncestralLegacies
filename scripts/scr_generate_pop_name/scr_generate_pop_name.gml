/// scr_generate_pop_name.gml
///
/// Purpose:
///   Generates a display name for a pop based on its entity profile and biological sex.
///   Uses global name lists loaded at game start (via scr_load_name_data) to pick a prefix and suffix.
///
/// Metadata:
///   Summary:       Create a human-readable name for a pop instance.
///   Usage:         Called in obj_pop Create Event as:
///                    pop_name = scr_generate_pop_name(_entity_data, sex);
///   Parameters:
///     @param _entity_data (struct)
///       The pop's profile data struct (may include race or cultural details).
///     @param _sex (enum EntitySex)
///       The pop's biological sex, used to select appropriate name lists.
///   Returns:       string — The combined prefix+suffix name, or a fallback if lists are empty.
///   Tags:          [pop][name][generator]
///   Version:       1.0 - 2025-05-26
///   Dependencies:  EntitySex enum, global.male_prefixes, global.female_prefixes,
///                  global.male_suffixes, global.female_suffixes

function scr_generate_pop_name(_entity_data, _sex) {
    // Determine which global lists to use based on sex
    var _prefix_list;
    var _suffix_list;
    if (_sex == EntitySex.MALE) {
        _prefix_list = global.male_prefixes;
        _suffix_list = global.male_suffixes;
    } else {
        _prefix_list = global.female_prefixes;
        _suffix_list = global.female_suffixes;
    }

    // Safely pick a random prefix
    var _prefix = "";
    if (is_array(_prefix_list) && array_length(_prefix_list) > 0) {
        var _i = irandom(array_length(_prefix_list) - 1);
        _prefix = string(_prefix_list[_i]);
    }

    // Safely pick a random suffix
    var _suffix = "";
    if (is_array(_suffix_list) && array_length(_suffix_list) > 0) {
        var _j = irandom(array_length(_suffix_list) - 1);
        _suffix = string(_suffix_list[_j]);
    }

    // Combine prefix and suffix to form the name
    var _name = (_prefix + _suffix);

    // Fallback: if both lists were empty or produced blank, use a generic placeholder
    if (_name == "") {
        // Use type key from profile if available, else use "Pop"
        var _base = (variable_struct_exists(_entity_data, "name_display_type"))
                    ? _entity_data.name_display_type
                    : "Pop";
        // Append instance id to ensure uniqueness
        _name = _base + string(id);
    }

    return _name;
}
