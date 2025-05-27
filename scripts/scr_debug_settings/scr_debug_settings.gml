/// scr_debug_settings.gml
///
/// Purpose:
///   Provides functions to control global debug message visibility
///   and a wrapper for conditional debug output.
///
/// Usage:
///   In game start (e.g., obj_gameStart Create Event):
///     debug_message_init(true); // enable or false to disable
///   Thereafter, replace show_debug_message() calls with debug_message().

/// @function debug_message_init(_enabled_by_default)
/// @description Initializes the global debug flag at runtime.
/// @param {bool} _enabled_by_default True to enable messages, false to disable.
function debug_message_init(_enabled_by_default) {
    global.DebugMessagesEnabled = _enabled_by_default;
    show_debug_message("[Debug] Messages initialized: " + string(global.DebugMessagesEnabled));
}

/// @function debug_messages_enable()
/// @description Enables debug messages globally.
function debug_messages_enable() {
    global.DebugMessagesEnabled = true;
    show_debug_message("[Debug] Messages ENABLED");
}

/// @function debug_messages_disable()
/// @description Disables debug messages globally.
function debug_messages_disable() {
    show_debug_message("[Debug] Messages DISABLED");
    global.DebugMessagesEnabled = false;
}

/// @function debug_messages_toggle()
/// @description Toggles debug message state.
/// @returns {bool} New debug state.
function debug_messages_toggle() {
    global.DebugMessagesEnabled = !global.DebugMessagesEnabled;
    show_debug_message("[Debug] Messages TOGGLED: " + string(global.DebugMessagesEnabled));
    return global.DebugMessagesEnabled;
}

/// @function are_debug_messages_enabled()
/// @description Checks if debug messages are enabled.
/// @returns {bool}
function are_debug_messages_enabled() {
    return global.DebugMessagesEnabled;
}

/// @function debug_message(...)
/// @description Shows a debug message if enabled.
function debug_message() {
    if (!variable_global_exists("DebugMessagesEnabled")) {
        global.DebugMessagesEnabled = false;
    }
    if (global.DebugMessagesEnabled) {
        var _msg = "";
        for (var i = 0; i < argument_count; i++) {
            _msg += string(argument[i]);
        }
        show_debug_message(_msg);
    }
}
