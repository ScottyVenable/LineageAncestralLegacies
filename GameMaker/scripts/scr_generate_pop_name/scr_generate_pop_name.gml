/// scr_generate_pop_name.gml
///
/// Purpose:
///   Generates a display name for a pop based on its entity profile and biological sex.
///   Uses global name lists loaded at game start (via scr_load_name_data) to pick a name.
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
///   Returns:       string — The selected name, or a fallback if lists are empty.
///   Tags:          [pop][name][generator]
///   Version:       1.2 - 2025-05-29 // Updated to use pre-generated name lists from JSON
///   Dependencies:  EntitySex enum, global.GameData.name_data (from name_data.json)

function scr_generate_pop_name(_entity_data, _sex) {
    // Access the name data from the global GameData struct
    // This data is loaded from name_data.json at game start
    var _name_data = global.GameData.name_data;
    var _name_list;
    var _name = ""; // Initialize name to an empty string

    // Determine which name list to use based on sex
    // and check if the corresponding data exists in _name_data
    if (_sex == EntitySex.MALE && variable_struct_exists(_name_data, "male_names")) {
        _name_list = _name_data.male_names;
    } else if (_sex == EntitySex.FEMALE && variable_struct_exists(_name_data, "female_names")) {
        _name_list = _name_data.female_names;
    } else {
        // Fallback if sex-specific name list is missing
        _name_list = [];
        show_debug_message("Warning: Name list for sex " + string(_sex) + " not found in global.GameData.name_data.");
    }

    // Safely pick a random name from the selected list
    if (is_array(_name_list) && array_length(_name_list) > 0) {
        var _i = irandom(array_length(_name_list) - 1);
        _name = string(_name_list[_i]);
    } else {
        show_debug_message("Warning: Selected name list for sex " + string(_sex) + " is empty or not an array.");
    }

    // Fallback: if the list was empty or produced a blank name, use a random fallback name
    if (_name == "") {
        // Educational: This fallback ensures pops always get a name, even if name data fails to load or is empty.
        // It first tries to use default names if available.
        if (_sex == EntitySex.MALE && variable_struct_exists(global.GameData, "defaultMaleNames") && is_array(global.GameData.defaultMaleNames) && array_length(global.GameData.defaultMaleNames) > 0) {
            _name = global.GameData.defaultMaleNames[irandom(array_length(global.GameData.defaultMaleNames)-1)];
        } else if (_sex == EntitySex.FEMALE && variable_struct_exists(global.GameData, "defaultFemaleNames") && is_array(global.GameData.defaultFemaleNames) && array_length(global.GameData.defaultFemaleNames) > 0) {
            _name = global.GameData.defaultFemaleNames[irandom(array_length(global.GameData.defaultFemaleNames)-1)];
        } else {
            // Final fallback: use a generic name with instance id if default names are also unavailable
            // This ensures the pop gets *some* unique identifier.
            var _base = variable_struct_exists(_entity_data, "type_tag")
                        ? _entity_data.type_tag
                        : "Pop"; // Default to "Pop" if type_tag is missing
            _name = _base + "_" + string(id); // Appending instance id for uniqueness
            show_debug_message("Critical Fallback: Used generic name for pop " + _name + " as all name sources failed.");
        }
    }

    return _name;
}
