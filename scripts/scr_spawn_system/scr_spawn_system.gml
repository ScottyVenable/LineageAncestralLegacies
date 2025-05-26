/// @description Game entity spawning system using data-driven profiles.
/// This script provides functions to create and manage game entities based on
/// definitions stored in global.GameData.

/// @function spawn_single_instance(entity_profile_struct, x, y, [optional_initial_state_overrides])
/// @description Spawns a single game entity instance based on a provided data profile.
/// It creates the instance, injects a copy of its static profile data, 
/// calls its 'initialize_from_profile' method (if it exists), and applies any overrides.
/// @param {struct} entity_profile_struct A direct reference to an entity profile from global.GameData.Entity.
///                                      Example: global.GameData.Entity.Pop.HOMO_HABILIS_EARLY
/// @param {real} x The x-coordinate to spawn the instance at.
/// @param {real} y The y-coordinate to spawn the instance at.
/// @param {struct} [optional_initial_state_overrides] An optional struct containing key-value pairs 
///                                                  to override or add to the instance's variables 
///                                                  after creation and profile injection. Defaults to an empty struct.
/// @returns {Id.Instance} The ID of the newly created instance, or noone if creation failed.
function spawn_single_instance(entity_profile_struct, x, y, optional_initial_state_overrides = {}) {
    // --- Input Validation ---
    // Ensure the provided profile is a struct and contains the necessary 'object_to_spawn'
    if (!is_struct(entity_profile_struct)) {
        show_debug_message("ERROR: spawn_single_instance - entity_profile_struct is not a struct. Cannot spawn entity.");
        return noone;
    }
    if (!variable_struct_exists(entity_profile_struct, "object_to_spawn")) {
        var _profile_id_str = variable_struct_exists(entity_profile_struct, "profile_id_string") ? entity_profile_struct.profile_id_string : "PROFILE_ID_UNKNOWN";
        show_debug_message("ERROR: spawn_single_instance - entity_profile_struct missing 'object_to_spawn'. Profile ID: " + _profile_id_str);
        return noone;
    }
    if (!asset_exists(entity_profile_struct.object_to_spawn, asset_object)) {
         var _profile_id_str = variable_struct_exists(entity_profile_struct, "profile_id_string") ? entity_profile_struct.profile_id_string : "PROFILE_ID_UNKNOWN";
         show_debug_message("ERROR: spawn_single_instance - 'object_to_spawn' (" + string(entity_profile_struct.object_to_spawn) + ") is not a valid object asset. Profile ID: " + _profile_id_str);
        return noone;
    }

    // --- Instance Creation ---
    var _object_to_spawn = entity_profile_struct.object_to_spawn;
    // Assuming a common layer "Instances". This layer must exist in the room where entities are spawned.
    // TODO: Consider making the layer an argument or configurable if necessary.
    var _instance_id = instance_create_layer(x, y, "Instances", _object_to_spawn);

    if (!instance_exists(_instance_id)) {
        var _profile_id_str = variable_struct_exists(entity_profile_struct, "profile_id_string") ? entity_profile_struct.profile_id_string : "PROFILE_ID_UNKNOWN";
        show_debug_message("ERROR: spawn_single_instance - Failed to create instance of " + object_get_name(_object_to_spawn) + ". Profile ID: " + _profile_id_str);
        return noone;
    }

    // --- Data Injection ---
    // Inject a *clone* of the static profile data into the instance.
    // This is crucial to prevent instances from accidentally modifying the global GameData.
    // struct_clone performs a deep copy by default, which is what we want here to ensure
    // the instance has its own unique copy of any nested structs/arrays within the profile.
    if (script_exists(scr_struct_clone)) { // Assuming you have a robust struct_clone script
        _instance_id.staticProfileData = scr_struct_clone(entity_profile_struct);
    } else {
        // Fallback to GameMaker's struct_copy if scr_struct_clone is not available.
        // Be aware that struct_copy is a shallow copy. If your profiles contain nested mutable
        // structs or arrays that need to be unique per instance (e.g., a list of active effects),
        // you will need a proper deep cloning function (like scr_struct_clone).
        // For now, we proceed with struct_copy and log a warning.
        _instance_id.staticProfileData = struct_copy(entity_profile_struct);
        show_debug_message("WARNING: spawn_single_instance - scr_struct_clone not found. Using shallow struct_copy. Nested mutable data in profiles might be shared across instances.");
    }

    // Store the profile ID string directly on the instance for easy identification/debugging.
    // As per your document, this should be profileIDStringRef.
    if (variable_struct_exists(entity_profile_struct, "profile_id_string")) {
        _instance_id.profileIDStringRef = entity_profile_struct.profile_id_string;
    } else {
        _instance_id.profileIDStringRef = "PROFILE_ID_MISSING"; // Fallback
    }

    // --- Instance Initialization ---
    // Call an initialization method within the instance, if it exists.
    // This allows the instance to perform its own setup using the staticProfileData.
    // This is the new standard initialization pattern for objects spawned by this system.
    // Generic controller objects should implement 'initialize_from_profile()'.
    if (method_exists(_instance_id, "initialize_from_profile")) {
        // The initialize_from_profile method is responsible for reading from _instance_id.staticProfileData
        // and setting up the instance's specific variables (health, sprite, stats, etc.).
        _instance_id.initialize_from_profile();
    } else {
        show_debug_message("WARNING: spawn_single_instance - Instance " + string(_instance_id) + 
                           " of object " + object_get_name(_object_to_spawn) + 
                           " (Profile: " + _instance_id.profileIDStringRef + ")" +
                           " does not have an 'initialize_from_profile()' method. Full initialization may not occur.");
    }

    // --- Apply Overrides ---
    // Apply any optional initial state overrides after the profile data has been injected
    // and the instance's own initialization method has been called.
    // This allows for specific modifications to the instance's state at spawn time
    // (e.g., setting current health, assigning a specific faction, or giving an initial command).
    if (is_struct(optional_initial_state_overrides) && variable_struct_names_count(optional_initial_state_overrides) > 0) {
        var _override_keys = variable_struct_get_names(optional_initial_state_overrides);
        for (var i = 0; i < array_length(_override_keys); i++) {
            var _key = _override_keys[i];
            var _value = variable_struct_get(optional_initial_state_overrides, _key);
            
            // It's generally safer to use variable_instance_set for broad compatibility,
            // though direct assignment (_instance_id.[_key] = _value) can also work if the variable is already declared.
            variable_instance_set(_instance_id, _key, _value);
            
            // For debugging overrides:
            // show_debug_message("Applied override: " + _key + " = " + string(_value) + " to instance " + string(_instance_id) + " (Profile: " + _instance_id.profileIDStringRef + ")");
        }
    }

    show_debug_message("SUCCESS: Spawned instance " + string(_instance_id) + 
                       " of object " + object_get_name(_object_to_spawn) + 
                       " using profile: " + _instance_id.profileIDStringRef + 
                       " at (" + string(x) + "," + string(y) + ")");

    return _instance_id;
}

// TODO: Implement higher-level spawning functions as per "Unified GameData System.md"
// - spawn_formation_at_point(formation_profile_struct, center_x, center_y, optional_entity_overrides = {})
// - world_gen_spawn_entities_in_region(region_definition, entity_spawn_list_struct)

/// @function world_gen_spawn(subject_identifier_string, amount_to_spawn, formation_enum, area_params_struct, [optional_initial_state_overrides])
/// @description Spawns a number of entities of a specific type, potentially in a formation, within a given area.
///              This is intended for world generation or scenario setups.
/// @param {string} subject_identifier_string The UniqueID string of the entity profile to spawn (e.g., "UniqueID.Entity.Pop.HOMO_SAPIENS_ARCHAIC").
/// @param {real} amount_to_spawn The number of entities to attempt to spawn.
/// @param {enum.FormationType} formation_enum An enum value specifying the formation type (e.g., FormationType.SCATTER, FormationType.LINE_HORIZONTAL). (Requires FormationType enum to be defined)
/// @param {struct} area_params_struct A struct defining the spawning area.
///                                    Expected fields depend on formation_enum:
///                                    - For SCATTER: { x_center, y_center, radius }
///                                    - For LINE_HORIZONTAL: { start_x, start_y, spacing }
///                                    - For LINE_VERTICAL: { start_x, start_y, spacing }
///                                    - For GRID: { start_x, start_y, spacing_x, spacing_y, columns }
/// @param {struct} [optional_initial_state_overrides] Optional struct with overrides for each spawned instance. Defaults to {}.
/// @returns {array<Id.Instance>} An array containing the instance IDs of all successfully spawned entities.
function world_gen_spawn(subject_identifier_string, amount_to_spawn, formation_enum, area_params_struct, optional_initial_state_overrides = {}) {
    var _spawned_instances = [];

    // --- 1. Resolve Entity Profile ---
    if (!variable_global_exists("GameData") || !is_struct(global.GameData)) {
        show_debug_message("ERROR: world_gen_spawn - global.GameData is not initialized. Cannot resolve entity profile.");
        return _spawned_instances;
    }
    if (!is_method(global, "GetProfileFromUniqueID")) {
        show_debug_message("ERROR: world_gen_spawn - global.GetProfileFromUniqueID method not found. Cannot resolve entity profile.");
        return _spawned_instances;
    }

    var _entity_profile = global.GetProfileFromUniqueID(subject_identifier_string);

    if (!is_struct(_entity_profile)) {
        show_debug_message("ERROR: world_gen_spawn - Could not resolve entity profile for identifier: " + subject_identifier_string);
        return _spawned_instances;
    }
    if (!variable_struct_exists(_entity_profile, "object_to_spawn")) {
        show_debug_message("ERROR: world_gen_spawn - Resolved entity profile for '" + subject_identifier_string + "' is missing 'object_to_spawn'.");
        return _spawned_instances;
    }

    show_debug_message("INFO: world_gen_spawn - Attempting to spawn " + string(amount_to_spawn) + " of '" + subject_identifier_string + "'");

    // --- 2. Determine Spawn Coordinates based on Formation & Area ---
    // This section will need to be more robust and utilize the scr_formations script/enums.
    // For now, a simplified implementation.
    // Ensure FormationType enum exists (e.g., in scr_constants or scr_formations)
    // enum FormationType { SCATTER, LINE_HORIZONTAL, LINE_VERTICAL, GRID, SINGLE_POINT }

    var _spawn_x = variable_struct_exists(area_params_struct, "x_center") ? area_params_struct.x_center : (variable_struct_exists(area_params_struct, "start_x") ? area_params_struct.start_x : room_width / 2);
    var _spawn_y = variable_struct_exists(area_params_struct, "y_center") ? area_params_struct.y_center : (variable_struct_exists(area_params_struct, "start_y") ? area_params_struct.start_y : room_height / 2);
    var _radius = variable_struct_exists(area_params_struct, "radius") ? area_params_struct.radius : 50;
    var _spacing = variable_struct_exists(area_params_struct, "spacing") ? area_params_struct.spacing : 32; // Default spacing for lines/grids
    var _spacing_x = variable_struct_exists(area_params_struct, "spacing_x") ? area_params_struct.spacing_x : _spacing;
    var _spacing_y = variable_struct_exists(area_params_struct, "spacing_y") ? area_params_struct.spacing_y : _spacing;
    var _columns = variable_struct_exists(area_params_struct, "columns") ? area_params_struct.columns : max(1, floor(sqrt(amount_to_spawn)));


    // --- 3. Spawn Loop ---
    for (var i = 0; i < amount_to_spawn; i++) {
        var _current_x = _spawn_x;
        var _current_y = _spawn_y;

        // Placeholder formation logic - replace with calls to scr_formations if available
        // or more detailed logic here.
        switch (formation_enum) {
            case FormationType.SCATTER: // Assuming FormationType enum exists
                _current_x = _spawn_x + irandom_range(-_radius, _radius);
                _current_y = _spawn_y + irandom_range(-_radius, _radius);
                break;
            case FormationType.LINE_HORIZONTAL:
                _current_x = _spawn_x + (i * _spacing);
                _current_y = _spawn_y;
                break;
            case FormationType.LINE_VERTICAL:
                _current_x = _spawn_x;
                _current_y = _spawn_y + (i * _spacing);
                break;
            case FormationType.GRID:
                var _col = i % _columns;
                var _row = floor(i / _columns);
                _current_x = _spawn_x + (_col * _spacing_x);
                _current_y = _spawn_y + (_row * _spacing_y);
                break;
            case FormationType.SINGLE_POINT: // Fallthrough to default if not specifically handled
            default: // Default to spawning at the base point or center
                _current_x = _spawn_x;
                _current_y = _spawn_y;
                // If amount_to_spawn > 1 for SINGLE_POINT, they will stack. Add minor random offset.
                if (amount_to_spawn > 1) {
                    _current_x += irandom_range(-5,5);
                    _current_y += irandom_range(-5,5);
                }
                break;
        }
        
        // Ensure spawn is within room boundaries (optional, but good for safety)
        // _current_x = clamp(_current_x, 0, room_width);
        // _current_y = clamp(_current_y, 0, room_height);

        var _instance = spawn_single_instance(_entity_profile, _current_x, _current_y, optional_initial_state_overrides);
        if (instance_exists(_instance)) {
            array_push(_spawned_instances, _instance);
        } else {
            show_debug_message("WARNING: world_gen_spawn - Failed to spawn instance " + string(i+1) + "/" + string(amount_to_spawn) + " of '" + subject_identifier_string + "'");
            // Optionally, decide if you want to break or continue if one fails
        }
    }

    if (array_length(_spawned_instances) == amount_to_spawn) {
        show_debug_message("SUCCESS: world_gen_spawn - Successfully spawned " + string(amount_to_spawn) + " instances of '" + subject_identifier_string + "'.");
    } else {
        show_debug_message("INFO: world_gen_spawn - Spawned " + string(array_length(_spawned_instances)) + "/" + string(amount_to_spawn) + " instances of '" + subject_identifier_string + "'.");
    }

    return _spawned_instances;
}

/// @function scr_struct_clone(struct_to_clone)
/// @description Performs a deep clone of a struct, including nested structs and arrays.
///              This is a placeholder and needs a robust implementation.
/// @param {struct} struct_to_clone The struct to clone.
/// @returns {struct} A deep copy of the input struct.
function scr_struct_clone(struct_to_clone) {
    // --- Basic Type Handling & Input Validation ---
    if (!is_struct(struct_to_clone)) {
        // If it's not a struct, it might be an array or a primitive.
        // For arrays, we need to iterate and clone elements.
        // For primitives, just return the value.
        if (is_array(struct_to_clone)) {
            var _cloned_array = array_create(array_length(struct_to_clone));
            for (var i = 0; i < array_length(struct_to_clone); i++) {
                _cloned_array[i] = scr_struct_clone(struct_to_clone[i]); // Recursive call for array elements
            }
            return _cloned_array;
        }
        // For primitives (real, string, bool, undefined, pointer, int64, etc.)
        return struct_to_clone; 
    }

    // --- Struct Cloning ---
    var _cloned_struct = {}; // Initialize an empty struct for the clone

    var _keys = variable_struct_get_names(struct_to_clone);
    for (var i = 0; i < array_length(_keys); i++) {
        var _key = _keys[i];
        var _value = variable_struct_get(struct_to_clone, _key);

        // Recursively clone the value if it's a struct or array
        if (is_struct(_value)) {
            _cloned_struct[$ _key] = scr_struct_clone(_value);
        } else if (is_array(_value)) {
            // Handle arrays: create a new array and clone each element
            var _cloned_array = array_create(array_length(_value));
            for (var j = 0; j < array_length(_value); j++) {
                _cloned_array[j] = scr_struct_clone(_value[j]); // Recursive call for array elements
            }
            _cloned_struct[$ _key] = _cloned_array;
        } else {
            // For primitive types, directly assign the value
            _cloned_struct[$ _key] = _value;
        }
    }
    return _cloned_struct;
}


/*
TEMPLATE_SCRIPT.gml content (for reference, if available, to ensure adherence):
/// @description {{Description}}
/// @function {{FunctionName}}
/// @param {{param1_name}} {{param1_description}}
/// @param {{param2_name}} {{param2_description}}
/// @returns {{return_type_and_description}}
function {{FunctionName}}({{param1_name}}, {{param2_name}}) {
    // Function code here
}
*/
