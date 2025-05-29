/// scr_load_external_data.gml
///
/// Purpose:
///   Centralized script to load all external data files (JSON) for the game.
///   This includes item data, resource nodes, structures, entities, and more.
///   Designed to be called once at the beginning of the game (e.g., in a controller object's Create Event).
///
/// Metadata:
///   Summary:       Loads various game data from JSON files into global structures.
///   Usage:         Call `scr_load_external_data_all()` once at the beginning of the game.
///   Parameters:    None
///   Returns:       void (This function modifies global variables directly: `global.GameData.items`, `global.GameData.resource_nodes`, etc.)
///   Tags:          [data][utility][initialization][file_io][json]
///   Version:       1.2 - 2025-05-23 // Updated to use game_save_id + "/gamedata/core/" as target directory for runtime JSON files
///   Dependencies:  None explicitly, but relies on JSON structure consistency and file availability.
///   Creator:       GameDev AI (Originally) / Your Name // Please update creator if known
///   Created:       2025-05-22 // Assumed creation date, please update if known
///   Last Modified: 2025-05-23 by Copilot // Initial creation

// =========================================================================
// 0. IMPORTS & CACHES (Script-level)
// =========================================================================
#region 0.1 Global Scope Dependencies
// This script relies on various global variables and functions being available,
// particularly those related to GameData structure and JSON handling.
// No direct script-level imports here, but function dependencies are noted in metadata.
#endregion

// =========================================================================
// (Sections 1-3 are not directly applicable for a script file that only defines functions)
// (unless there was script-level execution code outside functions)
// =========================================================================

// =========================================================================
// 4. CORE LOGIC (Function Definitions)
// =========================================================================

#region Helper Function: load_json_file
/// @function load_json_file(_filepath)
/// @description Reads a file and parses its content as JSON.
/// @param {string} _filepath The path to the JSON file.
/// @return {Struct|Array|undefined} Parsed JSON data, or undefined on error.
function load_json_file(_filepath) {
    if (!file_exists(_filepath)) {
        show_debug_message("ERROR (load_json_file): File not found at path: " + _filepath);
        return undefined;
    }

    var _buffer = buffer_load(_filepath);
    if (!buffer_exists(_buffer)) {
        show_debug_message("ERROR (load_json_file): Could not load file into buffer: " + _filepath);
        return undefined;
    }

    var _json_string = buffer_read(_buffer, buffer_string);
    buffer_delete(_buffer); // Clean up buffer

    if (_json_string == "" || _json_string == undefined) {
        show_debug_message("ERROR (load_json_file): File was empty or could not be read as string: " + _filepath);
        return undefined;
    }

    var _parsed_data = json_parse(_json_string);

    // json_parse returns the input string if it fails to parse, which is not what we want.
    // We should check if the result is a struct or array, as valid JSON should parse to one of these.
    if (!is_struct(_parsed_data) && !is_array(_parsed_data)) {
        show_debug_message("ERROR (load_json_file): Failed to parse JSON string from file: " + _filepath + ". Content might not be valid JSON.");
        // show_debug_message("Content: " + _json_string); // Uncomment for debugging, but can be very verbose.
        return undefined; // Indicate failure
    }
    
    // Successfully parsed
    return _parsed_data;
}
#endregion

#region 4.1 Main Data Loading Function: scr_load_external_data_all()
/// @function scr_load_external_data_all(_base_path_from_included_files)
/// @description Loads all external JSON data files.
///              For now, it loads from the project's Included Files.
///              Later, this can be adapted to check the player's game directory.
/// @param {string} _base_path_from_included_files The subfolder within Included Files (e.g., "gamedata/core") containing the default game data.
function scr_load_external_data_all(_base_path_from_included_files) {
    // =========================================================================
    // 1. Define Paths
    // =========================================================================
    // Ensure _base_path_from_included_files uses backslashes internally for consistency
    var _sanitized_base_path = string_replace_all(_base_path_from_included_files, "/", "\\");
    var _default_data_path_prefix = (_sanitized_base_path == "" || _sanitized_base_path == undefined) ? "" : _sanitized_base_path + "\\";
    
    var _save_data_main_dir = game_save_id; // Base save directory
    
    // Define the target subdirectory structure within game_save_id
    var _save_gamedata_sub_dir_name = "gamedata";
    var _save_core_sub_dir_name = "core";
    
    // Construct paths using backslashes
    var _path_to_gamedata_in_save_dir = _save_data_main_dir + _save_gamedata_sub_dir_name + "\\";
    var _path_to_core_in_save_dir = _path_to_gamedata_in_save_dir + _save_core_sub_dir_name + "\\"; // This is where files like item_data.json will go

    show_debug_message("scr_load_external_data_all: Default data prefix (Included Files): '" + _default_data_path_prefix + "'");
    show_debug_message("scr_load_external_data_all: Target save data path (Runtime): '" + _path_to_core_in_save_dir + "'");

    // =========================================================================
    // 2. Ensure Save Data Directory Exists
    // =========================================================================
    if (!directory_exists(_save_data_main_dir)) {
        show_debug_message("scr_load_external_data_all: Main save directory '" + _save_data_main_dir + "' not found. Attempting to create.");
        directory_create(_save_data_main_dir); 
    }
    if (!directory_exists(_path_to_gamedata_in_save_dir)) {
        show_debug_message("scr_load_external_data_all: Subdirectory '" + _path_to_gamedata_in_save_dir + "' not found. Attempting to create.");
        directory_create(_path_to_gamedata_in_save_dir); 
    }
    if (!directory_exists(_path_to_core_in_save_dir)) {
        show_debug_message("scr_load_external_data_all: Subdirectory '" + _path_to_core_in_save_dir + "' not found. Attempting to create.");
        directory_create(_path_to_core_in_save_dir); 
    }

    // =========================================================================
    // 3. Define Helper to Manage and Load Files
    //    This helper will:
    //    - Check if the file exists in the target save directory (_path_to_core_in_save_dir).
    //    - If not, copy it from Included Files (defaults at _default_data_path_prefix).
    //    - Attempt to load from the target save directory.
    //    - If that fails, attempt to load from Included Files (defaults) as a fallback.
    // =========================================================================
    function _get_data_file_path_and_load(_filename, _current_path_to_core_in_save_dir, _current_default_data_path_prefix) {
        // Files will be directly inside _path_to_core_in_save_dir
        // Ensure filenames are appended with backslashes
        var _path_in_save_dir = _current_path_to_core_in_save_dir + _filename;
        var _path_in_defaults = _current_default_data_path_prefix + _filename; // Path to the default file in Included Files

        // Check if the file exists in the save directory.
        // If not, copy the default version from Included Files.
        if (!file_exists(_path_in_save_dir)) {
            show_debug_message("INFO (" + _filename + "): Not found in save directory ('" + _path_in_save_dir + "'). Checking for default in Included Files: '" + _path_in_defaults + "'.");
            
            if (file_exists(_path_in_defaults)) { // Check if the default file exists in "Included Files"
                show_debug_message("INFO (" + _filename + "): Default found at '" + _path_in_defaults + "'. Attempting to copy to '" + _path_in_save_dir + "'.");
                var _copy_success = file_copy(_path_in_defaults, _path_in_save_dir);
                if (_copy_success) {
                    show_debug_message("SUCCESS (" + _filename + "): Copied default to save directory.");
                } else {
                    show_debug_message("ERROR (" + _filename + "): FAILED to copy default '" + _path_in_defaults + "' to '" + _path_in_save_dir + "'. This can happen if the source doesn't exist in Included Files or due to permissions.");
                }
            } else {
                show_debug_message("CRITICAL WARNING (" + _filename + "): Default file '" + _path_in_defaults + "' not found in Included Files. Cannot populate save directory or use as fallback.");
            }
        }

        // Now, attempt to load from the save directory first.
        if (file_exists(_path_in_save_dir)) {
            var _loaded_data = load_json_file(_path_in_save_dir);
            if (is_struct(_loaded_data) || is_array(_loaded_data)) { // Check if JSON parsing was successful
                show_debug_message("SUCCESS (" + _filename + "): Loaded from save directory: '" + _path_in_save_dir + "'.");
                return _loaded_data;
            } else {
                show_debug_message("WARNING (" + _filename + "): Failed to load or parse from save directory '" + _path_in_save_dir + "' (file might be corrupted or not valid JSON). Attempting to load from default in Included Files.");
            }
        } else {
             show_debug_message("WARNING (" + _filename + "): File still not found in save directory '" + _path_in_save_dir + "' after copy attempt (or no default to copy). Attempting to load directly from default in Included Files.");
        }

        // Fallback: Try to load from the default Included Files location.
        if (file_exists(_path_in_defaults)) {
            var _loaded_data_fallback = load_json_file(_path_in_defaults);
            if (is_struct(_loaded_data_fallback) || is_array(_loaded_data_fallback)) {
                show_debug_message("SUCCESS (" + _filename + "): Loaded from DEFAULTS (Included Files): '" + _path_in_defaults + "'.");
                return _loaded_data_fallback;
            } else {
                show_debug_message("ERROR (" + _filename + "): Failed to load or parse from DEFAULTS '" + _path_in_defaults + "' as well.");
            }
        }
        
        return undefined; // Return undefined if all attempts fail.
    }

    // =========================================================================
    // 4. Load Each Data File using the Helper
    // =========================================================================
    
    // --- Items ---
    var _item_data_filename = "item_data.json";
    var _items = _get_data_file_path_and_load(_item_data_filename, _path_to_core_in_save_dir, _default_data_path_prefix);
    if (is_struct(_items)) {
        global.GameData.items = _items;
        // Path shown in previous messages is now more complex, so a generic success message here.
        show_debug_message("Item data processed into global.GameData.items.");
    } else {
        show_debug_message("ERROR: Failed to process item data. global.GameData.items may be incomplete or default.");
    }
    
    // --- Resource Nodes ---
    var _resource_node_data_filename = "resource_node_data.json";
    var _res = _get_data_file_path_and_load(_resource_node_data_filename, _path_to_core_in_save_dir, _default_data_path_prefix);
    if (is_struct(_res)) {
        global.GameData.resource_nodes = _res;
        show_debug_message("Resource node data processed into global.GameData.resource_nodes.");
    } else {
        show_debug_message("ERROR: Failed to process resource node data.");
    }

    // --- Structures ---
    var _structure_data_filename = "structure_data.json";
    var _struct_data = _get_data_file_path_and_load(_structure_data_filename, _path_to_core_in_save_dir, _default_data_path_prefix); // Renamed var to avoid conflict
    if (is_struct(_struct_data)) {
        global.GameData.structures = _struct_data;
        show_debug_message("Structure data processed into global.GameData.structures.");
    } else {
        show_debug_message("ERROR: Failed to process structure data.");
    }

    // --- Entities ---
    var _entity_data_filename = "entity_data.json";
    var _ent = _get_data_file_path_and_load(_entity_data_filename, _path_to_core_in_save_dir, _default_data_path_prefix);
    if (is_struct(_ent)) {
        global.GameData.entities = _ent;
        show_debug_message("Entity data processed into global.GameData.entities.");
    } else {
        show_debug_message("ERROR: Failed to process entity data.");
    }
    
    // --- Pop Name Data (JSON version) ---
    // If name_data.json is in a subfolder of _base_path_from_included_files (e.g., "datafiles/namedata/name_data.json")
    // then _name_data_json_filename should be "namedata/name_data.json"
    var _name_data_json_filename = "name_data.json"; 
    // For example, if it's in a "namedata" subfolder of your "datafiles" Included Files folder:
    // var _name_data_json_filename = "namedata/name_data.json"; 
    var _names_json = _get_data_file_path_and_load(_name_data_json_filename, _path_to_core_in_save_dir, _default_data_path_prefix);
    if (is_struct(_names_json)) {
        global.GameData.name_data = _names_json; 
        show_debug_message("JSON name data processed into global.GameData.name_data.");
    } else {
        show_debug_message("WARNING: Failed to process JSON name data.");
    }

    // --- Pop States Data ---
    var _pop_states_filename = "pop_states.json";
    var _pop_states_data = _get_data_file_path_and_load(_pop_states_filename, _path_to_core_in_save_dir, _default_data_path_prefix);
    if (is_struct(_pop_states_data)) {
        global.GameData.pop_states = _pop_states_data;
        show_debug_message("Pop states data processed into global.GameData.pop_states.");
    } else {
        show_debug_message("ERROR: Failed to process pop states data.");
    }

    // --- Recipes Data ---
    var _recipes_filename = "recipes.json"; 
    var _recipes_data = _get_data_file_path_and_load(_recipes_filename, _path_to_core_in_save_dir, _default_data_path_prefix);
    if (is_struct(_recipes_data)) {
        global.GameData.recipes = _recipes_data; 
        show_debug_message("Recipes data processed into global.GameData.recipes.");
    } else {
        show_debug_message("WARNING: Failed to process recipes data.");
    }

    show_debug_message("scr_load_external_data_all: Finished attempting to load all external JSON data.");
    
    // =========================================================================
    // 5. Linking/Resolution (Second Pass) - IMPORTANT
    // =========================================================================
    // This section should come AFTER all primary data has been loaded,
    // as it relies on different parts of global.GameData being populated.
    // Example: Resolve string IDs in resource nodes to item profile references
    if (is_struct(global.GameData.resource_nodes)) {
        var _res_keys = variable_struct_get_names(global.GameData.resource_nodes);
        for (var i = 0; i < array_length(_res_keys); i++) {
            var _key = _res_keys[i];
            // Use the $ accessor to get the struct member using a string variable for the key
            var _node = global.GameData.resource_nodes[$ _key]; 
            
            // Check if _node is actually a struct before trying to access its members
            if (!is_struct(_node)) {
                show_debug_message("Warning: Expected a struct for resource node key '" + _key + "', but found: " + typeof(_node));
                continue; // Skip to the next key
            }
            
            // Check if gather_properties exists and is a struct
            if (!variable_struct_exists(_node, "gather_properties") || !is_struct(_node.gather_properties)) {
                show_debug_message("Warning: Missing or invalid 'gather_properties' for resource node '" + _key + "'.");
                continue; // Skip to the next key
            }
            
            // Check if resource_item_id exists in gather_properties
            if (!variable_struct_exists(_node.gather_properties, "resource_item_id")) {
                show_debug_message("Warning: Missing 'resource_item_id' in 'gather_properties' for resource node '" + _key + "'.");
                continue; // Skip to the next key
            }
            
            var _item_id_str = _node.gather_properties.resource_item_id;
            // Corrected function name from find_item_profile_by_id to get_item_profile_by_id
            var _profile = get_item_profile_by_id(_item_id_str);
            if (is_struct(_profile)) {
                _node.gather_properties.resource_item_profile = _profile;
            } else {
                show_debug_message("Warning: Could not resolve item profile for resource node '" + _key + "'. ID: " + _item_id_str);
            }
        }
    }

    show_debug_message("External data load complete with linking.");
}
#endregion