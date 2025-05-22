/// debug_log.gml
///
/// Purpose:
///   Prints a debug message with section labeling and optional color coding (if supported by IDE/console).
///   Makes debug output organized and easy to filter by section or severity.
///
/// Metadata:
///   Summary:       Enhanced debug logger for structured, color-tagged output
///   Usage:         Call debug_log("Message", "Section", "color") anywhere
///   Parameters:    _msg : string — The message to print
///                  _section : string — Section or context label
///                  _color : string — Color tag (e.g. "red", "green", "yellow")
///   Returns:       void
///   Tags:          [utility][debug][logging]
///   Version:       1.0 — 2025-05-22
///   Dependencies:  None (uses show_debug_message)
///
/// Color options: "red", "green", "yellow", "blue", "magenta", "cyan", "white", "gray" (fallback: no color)
function debug_log(_msg, _section, _color) {
    // =========================================================================
    // 0. PARAMETER VALIDATION & DEFAULTS
    // =========================================================================
    #region 0.1 Parameter Defaults
    if (is_undefined(_section)) _section = "General";
    if (is_undefined(_color)) _color = "gray";
    #endregion

    // =========================================================================
    // 1. FORMAT MESSAGE
    // =========================================================================
    #region 1.1 Format
    var prefix = "[" + string(_section) + "] ";
    var colorized = prefix + string(_msg);
    // GameMaker's output console does not support color, but tags help searching
    if (is_string(_color)) {
        colorized = "{" + string(_color) + "}" + colorized + "{/}";
    }
    #endregion

    // =========================================================================
    // 2. OUTPUT
    // =========================================================================
    #region 2.1 Print to Console
    show_debug_message(colorized);
    #endregion

    // =========================================================================
    // 3. (Optional) EXTEND: Write to file, network, etc.
    // =========================================================================
    #region 3.1 Future Extensions
    // (Add file logging or remote debug hooks here if needed)
    #endregion
}
