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
///   Version:       1.1 - 2025-05-28 // Updated to use JSON data source
///   Dependencies:  EntitySex enum, global.GameData.name_data (from name_data.json)

function scr_generate_pop_name(_entity_data, _sex) {
    // Access the name data from the global GameData struct
    // This data is loaded from name_data.json at game start
    var _name_data = global.GameData.name_data;

    // Determine which name lists to use based on sex
    var _prefix_list;
    var _suffix_list;

    // Check if name_data and the relevant sex-specific data exist
    if (variable_struct_exists(_name_data, "names")) {
        if (_sex == EntitySex.MALE && variable_struct_exists(_name_data.names, "male")) {
            _prefix_list = _name_data.names.male.prefixes;
            _suffix_list = _name_data.names.male.suffixes;
        } else if (_sex == EntitySex.FEMALE && variable_struct_exists(_name_data.names, "female")) {
            _prefix_list = _name_data.names.female.prefixes;
            _suffix_list = _name_data.names.female.suffixes;
        } else {
            // Fallback if sex-specific data is missing, though this shouldn't happen with valid JSON
            _prefix_list = [];
            _suffix_list = [];
            show_debug_message("Warning: Name data for sex " + string(_sex) + " not found in global.GameData.name_data.names");
        }
    } else {
        // Fallback if the entire "names" structure is missing
        _prefix_list = [];
        _suffix_list = [];
        show_debug_message("Warning: global.GameData.name_data.names not found.");
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

    // Fallback: if both lists were empty or produced blank, use a random fallback name from database
    if (_name == "") {
        // Educational: This fallback ensures pops always get a name, even if name data fails to load.
        if (_sex == EntitySex.MALE && is_array(global.GameData.defaultMaleNames) && array_length(global.GameData.defaultMaleNames) > 0) {
            _name = global.GameData.defaultMaleNames[irandom(array_length(global.GameData.defaultMaleNames)-1)];
        } else if (_sex == EntitySex.FEMALE && is_array(global.GameData.defaultFemaleNames) && array_length(global.GameData.defaultFemaleNames) > 0) {
            _name = global.GameData.defaultFemaleNames[irandom(array_length(global.GameData.defaultFemaleNames)-1)];
        } else {
            // Final fallback: use a generic name with instance id
            var _base = variable_struct_exists(_entity_data, "type_tag")
                        ? _entity_data.type_tag
                        : "Pop";
            _name = _base + string(id);
        }
    }

    return _name;
}
