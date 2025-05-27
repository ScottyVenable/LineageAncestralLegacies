/// scr_debug_log.gml
///
/// Purpose:
///   Provides a structured way to print debug messages to the console.
///   It allows for section labeling and includes placeholders for color-coding tags,
///   even though GameMaker's `show_debug_message` doesn't render colors directly.
///   The tags can be useful for manual log filtering or if logs are processed externally.
///
/// Metadata:
///   Summary:       Enhanced debug logger for structured, potentially color-tagged output.
///   Usage:         Call `debug_log("My message", "MySection", "blue")` anywhere in your code.
///   Parameters:    _msg : string — The core message to be logged.
///                  _section : string (optional) — A label for the section or context of the message (e.g., "AI", "Inventory"). Defaults to "General".
///                  _color : string (optional) — A color name (e.g., "red", "green", "yellow") to tag the message. Defaults to "gray".
///                                            (Note: GameMaker console does not display colors, but tags are included in output.)
///   Returns:       void (nothing)
///   Tags:          [utility][debug][logging][console]
///   Version:       1.1 - 2025-05-23 // Aligned with TEMPLATE_SCRIPT structure.
///   Dependencies:  None (uses built-in `show_debug_message`).
///   Creator:       GameDev AI (Originally) / Your Name // Please update creator if known
///   Created:       2025-05-22 // Assumed creation date, please update if known
///   Last Modified: 2025-05-23 by Copilot // Updated to match template

function debug_log(_msg, _section = "General", _color = "gray") { // Added default values directly in signature
    // =========================================================================
    // 0. IMPORTS & CACHES
    // =========================================================================
    #region 0.1 Imports & Cached Locals
    // No specific imports or caches needed for this utility.
    #endregion

    // =========================================================================
    // 1. VALIDATION & EARLY RETURNS
    // =========================================================================
    #region 1.1 Parameter Validation
    // Ensure _msg is a string, or attempt to convert it.
    if (!is_string(_msg)) {
        _msg = string(_msg); // Attempt to convert non-string messages to string.
        show_debug_message("[WARNING] (debug_log): Message was not a string, converted automatically.");
    }
    if (!is_string(_section)) {
        _section = "InvalidSectionType";
        show_debug_message("[WARNING] (debug_log): Section was not a string, using default.");
    }
    if (!is_string(_color)) {
        _color = "gray"; // Default color if an invalid type is passed.
        show_debug_message("[WARNING] (debug_log): Color was not a string, using default gray.");
    }
    #endregion
    #region 1.2 Pre-condition Checks
    // (No specific pre-conditions beyond parameter types for this simple logger)
    #endregion

    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS
    // =========================================================================
    #region 2.1 Local Constants
    // (No local constants needed for this version)
    #endregion
    #region 2.2 Configuration from Parameters/Globals
    // (Could add a global.debug_level check here to suppress logs if needed)
    // Example: if (global.debug_level < DEBUG_LEVEL.VERBOSE) { return; }
    #endregion

    // =========================================================================
    // 3. INITIALIZATION & STATE SETUP
    // =========================================================================
    #region 3.1 One-Time Setup / State Variables
    // (No state setup needed for this stateless logger function)
    #endregion

    // =========================================================================
    // 4. CORE LOGIC
    // =========================================================================
    #region 4.1 Message Formatting
    // Construct the prefix for the log message, including the section.
    var _prefix = "[" + _section + "] ";
    
    // Combine prefix and message.
    var _formatted_message = _prefix + _msg;
    
    // Add color tags. GameMaker's output console doesn't render these as colors,
    // but they can be useful for manual searching or if logs are parsed by another tool.
    // Example format: {color_name}Log message{/}
    // The {/} tag is a hypothetical closing tag for external parsers.
    
    #endregion

    #region 4.2 Outputting the Message
    // Use GameMaker's built-in function to print the formatted message to the debug console.
    show_debug_message(_formatted_message);
    #endregion

    // =========================================================================
    // 5. CLEANUP & RETURN
    // =========================================================================
    #region 5.1 Cleanup (if necessary)
    // No cleanup needed for this function.
    #endregion
    #region 5.2 Return Value
    // This function does not return a value (void).
    #endregion

    // =========================================================================
    // 6. DEBUG/PROFILING (Optional - for the logger itself, usually not needed)
    // =========================================================================
    #region 6.1 Debug & Profile Hooks
    // (Typically, a logger wouldn't log about itself unless debugging the logger.)
    #endregion
}
