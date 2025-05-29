/// obj_window_bone - Create Event
///
/// Purpose:
///   Initializes variables for UI window instances.
///
/// Variables:
///   ui_identifier (String): An identifier string used to uniquely name this UI panel instance.
///                           This allows other objects (like obj_controller) to find and manage
///                           specific UI panels. For example, the Inspector Panel might have
///                           its ui_identifier set to "inspector_panel" in the Room Editor.
///
/// How to Use ui_identifier:
///   1. This variable is declared here so it appears in the "Variables" section
///      of an instance of obj_window_bone in the Room Editor.
///   2. Select your specific window instance (e.g., the one acting as your Inspector Panel)
///      in the Room Editor.
///   3. In its Variables panel, you will see "Ui Identifier". Set its value to a unique
///      string (e.g., "inspector_panel").
///   4. Code elsewhere (e.g., in obj_controller) can then loop through all obj_window_bone
///      instances and check this variable to find the specific panel it needs to interact with.
///
/// Learning Point:
///   This method of using instance-specific variables set in the Room Editor is a common
///   and flexible way to link room-placed instances with your game logic, making your
///   UI and game systems more manageable.

// Initialize the ui_identifier variable.
// This will be an empty string by default. You should set a specific value
// for important UI panels (like your inspector) directly in the Room Editor
// for the instance of this object.
ui_identifier = "";

// You can add other common initialization for all window bones here,
// for example, if they all share some default properties.
show_debug_message("obj_window_bone Create Event: Instance " + string(id) + " created. Remember to set 'ui_identifier' in Room Editor if this is a specific panel like the Inspector.");

