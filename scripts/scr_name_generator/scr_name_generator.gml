/// scr_name_generator.gml
/// Provides a generic name generation interface.
/// If given an entity profile and sex, routes to the appropriate name function.
function scr_name_generator(_profile_struct, _sex) {
    // For pops, generate a pop name
    return scr_name_for_pop(_profile_struct, _sex);
}

/// scr_name_for_pop: Generates a pop name based on profile and sex
function scr_name_for_pop(_profile_struct, _sex) {
    // Select global lists by sex
    var _prefix_list = (_sex == EntitySex.MALE) ? global.male_prefixes : global.female_prefixes;
    var _suffix_list = (_sex == EntitySex.MALE) ? global.male_suffixes : global.female_suffixes;
    // Pick random prefix/suffix safely
    var _prefix = (is_array(_prefix_list) && array_length(_prefix_list) > 0) ? string(_prefix_list[irandom(array_length(_prefix_list)-1)]) : "";
    var _suffix = (is_array(_suffix_list) && array_length(_suffix_list) > 0) ? string(_suffix_list[irandom(array_length(_suffix_list)-1)]) : "";
    var _name = _prefix + _suffix;
    // Fallback if empty
    if (_name == "") {
        var _base = variable_struct_exists(_profile_struct, "name_display_type") ? _profile_struct.name_display_type : "Pop";
        _name = _base + string(id);
    }
    return _name;
}