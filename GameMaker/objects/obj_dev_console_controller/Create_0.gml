// --- Singleton Check ---
// Ensure only one instance of this controller exists.
// If another instance is already present, this new one will destroy itself.
if (instance_number(object_index) > 1) {
    show_debug_message("Duplicate obj_dev_console_controller (id: " + string(id) + ") found. Destroying self.");
    instance_destroy(); // Destroy this duplicate instance.
    exit; // Stop executing the rest of the Create event for this duplicate.
}
show_debug_message("obj_dev_console_controller instance CREATED with id: " + string(id) + " (Singleton check passed).");

// --- Initialize Debug Console Global Variables ---
// This ensures the debug console starts in a known state.
// It's done here in the controller to centralize console-specific setup.
if (!variable_global_exists("Debug")) {
    global.Debug = {}; // Create the Debug struct if it doesn't exist
}
if (!is_struct(global.Debug)) { // Ensure Debug is a struct
    global.Debug = {};
    show_warning("global.Debug was not a struct, re-initialized by obj_dev_console_controller.", true);
}

if (!variable_struct_exists(global.Debug, "Console")) {
    global.Debug.Console = {}; // Create the Console struct if it doesn't exist
}
if (!is_struct(global.Debug.Console)) { // Ensure Console is a struct
    global.Debug.Console = {};
    show_warning("global.Debug.Console was not a struct, re-initialized by obj_dev_console_controller.", true);
}

// Set the initial visibility state for the console.
// This will be the default when the game starts.
global.Debug.Console.Visible = false; // Start with the console hidden.
show_debug_message("obj_dev_console_controller (id: " + string(id) + "): Initialized global.Debug.Console.Visible to false.");
// --- End Debug Console Initialization ---

// --- Instance Discovery on 'UI' Layer ---
// The controller will find existing instances of its UI elements on the "UI" layer.
// IMPORTANT: Ensure obj_dev_console, obj_console_input, and obj_debug_input_box
// are already placed on the layer named "UI" in your room.
var _ui_layer_name = "UI"; // Target layer name
var _ui_layer_id = layer_get_id(_ui_layer_name);

// Initialize variables to store found instance IDs
self.console_main_inst = noone;
self.console_input_inst = noone;
self.debug_input_box_inst = noone;

if (_ui_layer_id != -1) {
    show_debug_message("Searching for UI elements on layer: '" + _ui_layer_name + "' (ID: " + string(_ui_layer_id) + ")");
    var _elements_on_layer = layer_get_all_elements(_ui_layer_id);
    var _num_elements = array_length(_elements_on_layer);
    for (var i = 0; i < _num_elements; i++) {
        var _element_id = _elements_on_layer[i];
        if (instance_exists(_element_id)) {
            var _obj_index = instance_get_object(_element_id); // GMS 2.3+ function

            if (_obj_index == obj_dev_console && self.console_main_inst == noone) {
                self.console_main_inst = _element_id;
                show_debug_message("Found obj_dev_console instance (id: " + string(_element_id) + ")");
            } else if (_obj_index == obj_console_input && self.console_input_inst == noone) {
                self.console_input_inst = _element_id;
                show_debug_message("Found obj_console_input instance (id: " + string(_element_id) + ")");
            } else if (_obj_index == obj_debug_input_box && self.debug_input_box_inst == noone) {
                self.debug_input_box_inst = _element_id;
                show_debug_message("Found obj_debug_input_box instance (id: " + string(_element_id) + ")");
            }
        }
        // Optimization: Stop searching if all are found
        if (self.console_main_inst != noone && self.console_input_inst != noone && self.debug_input_box_inst != noone) {
            break;
        }
    }
} else {
    show_debug_message("ERROR in obj_dev_console_controller: Specified UI Layer '" + _ui_layer_name + "' not found!");
}

// Log warnings if essential instances were not found
if (self.console_main_inst == noone) show_debug_message("WARNING: obj_dev_console instance NOT FOUND on layer '" + _ui_layer_name + "'.");
if (self.console_input_inst == noone) show_debug_message("WARNING: obj_console_input instance NOT FOUND on layer '" + _ui_layer_name + "'.");
if (self.debug_input_box_inst == noone) show_debug_message("WARNING: obj_debug_input_box instance NOT FOUND on layer '" + _ui_layer_name + "'.");

// Initialize a list to store references to these debug console UI element instances.
self.debug_console_items = ds_list_create();

/**
 * @function self.debug_console_UIelements_add
 * @description Adds a UI element *instance ID* to the debug console's managed list, if not already present.
 *              This is an instance method of obj_dev_console_controller.
 * @param {Id.Instance} item The instance ID to add to the list.
 */
self.debug_console_UIelements_add = function(item) {
    if (instance_exists(item)) { // Only add valid instances
        if (ds_list_find_index(self.debug_console_items, item) == -1) {
            ds_list_add(self.debug_console_items, item);
        }
    } else {
        if (item != noone) { // Don't warn if 'noone' was passed intentionally
            show_debug_message("Warning: Attempted to add invalid/non-existent instance (" + string(item) + ") to debug_console_items.");
        }
    }
};

// Add the found instances to the managed list.
self.debug_console_UIelements_add(self.console_main_inst);
self.debug_console_UIelements_add(self.console_input_inst);
self.debug_console_UIelements_add(self.debug_input_box_inst);

// Assign the command submission logic for the found debug_input_box instance
if (instance_exists(self.debug_input_box_inst)) {
    self.debug_input_box_inst.on_submit_command = function(command_text) {
        var _controller_id = id; // obj_dev_console_controller's id
        show_debug_message("Controller (id: " + string(_controller_id) + ") received command: '" + command_text + "' from input box (id: " + string(self.id) + ")");
        // TODO: Implement actual command parsing and execution logic here using _controller_id if needed.
        // e.g., with(_controller_id) { self.parse_command(command_text); }
    }
    show_debug_message("Assigned on_submit_command to debug_input_box_inst (id: " + string(self.debug_input_box_inst.id) + ")");
} else {
    show_debug_message("Could not assign on_submit_command: obj_debug_input_box_inst was not found.");
}

/// @function global.set_debug_elements_visibility(show_elements)
/// @description Sets the visibility of all managed debug console UI elements.
///              This is a GLOBAL function. It finds the obj_dev_console_controller instance
///              to access its list of debug items.
/// @param {boolean} show_elements True to make elements visible, false to hide them.
global.set_debug_elements_visibility = function(show_elements) {
    // Find the obj_dev_console_controller instance.
    // This assumes obj_dev_console_controller is a singleton or you want to affect the first one found.
    var _controller_inst = instance_find(obj_dev_console_controller, 0);

    if (!instance_exists(_controller_inst)) {
        show_debug_message("ERROR in global.set_debug_elements_visibility: obj_dev_console_controller instance not found.");
        exit; // Exit the function if the controller instance isn't found.
    }

    // Access the list of debug items from the found controller instance.
    var _items_list = _controller_inst.debug_console_items;
    if (!ds_exists(_items_list, ds_type_list)) {
        show_debug_message("ERROR in global.set_debug_elements_visibility: debug_console_items list not found or invalid in controller instance (id: " + string(_controller_inst.id) + ").");
        exit;
    }

    // show_debug_message("global.set_debug_elements_visibility called with: " + string(show_elements) + " for controller id: " + string(_controller_inst.id));
    var list_size = ds_list_size(_items_list);
    var i = 0;
    repeat (list_size) {
        var _element_instance_id = ds_list_find_value(_items_list, i);
        if (instance_exists(_element_instance_id)) {
            // Ensure the instance has a 'visible' variable before trying to set it.
            // This is a good practice, though most displayable objects will have it.
            if (variable_instance_exists(_element_instance_id, "visible")) {
                _element_instance_id.visible = show_elements;
            } else {
                // Log if an item in the list doesn't have a 'visible' property for some reason.
                show_debug_message("Warning: Instance " + string(_element_instance_id) + " in debug_console_items does not have a 'visible' property.");
            }
        }
        i++;
    }
};
// This message confirms when the global function is defined by an instance of the controller.
show_debug_message("Global function global.set_debug_elements_visibility defined by obj_dev_console_controller (id: " + string(id) + ").");

// Initially set the visibility of console elements based on the just-initialized global.Debug.Console.Visible.
// Since global.Debug.Console.Visible is set to false above, this will hide them.
global.set_debug_elements_visibility(global.Debug.Console.Visible);
show_debug_message("obj_dev_console_controller (id: " + string(id) + "): Initial visibility set based on global.Debug.Console.Visible.");

show_debug_message("obj_dev_console_controller Create Event END for instance: " + string(id));