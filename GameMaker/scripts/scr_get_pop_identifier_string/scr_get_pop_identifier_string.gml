/// scr_get_pop_identifier_string.gml
/// Returns a debug-friendly identifier string for a pop instance.
/// @param {id} _pop_id - The instance id of the pop.
/// @returns {string} A string with the pop's name and instance/profile info for debugging.
function scr_get_pop_identifier_string(_pop_id) {
    // Educational: This function is a safe, robust way to get a pop's debug string.
    if (!instance_exists(_pop_id)) return "[Invalid Pop Instance]";
    var _name = variable_instance_exists(_pop_id, "pop_name") ? _pop_id.pop_name : "Pop";
    var _profile_id = variable_instance_exists(_pop_id, "entity_type_id") ? string(_pop_id.entity_type_id) : "?";
    return _name + " [InstanceID:" + string(_pop_id) + ", ProfileID:" + _profile_id + "]";
}
