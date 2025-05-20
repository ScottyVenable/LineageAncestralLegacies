/// scr_get_formation_name.gml
///
/// Purpose:
///    Returns a user-friendly string representation of a given Formation enum value.
///    This is used for displaying the current formation type in UI elements like notifications.
///
/// Metadata:
///    Summary:       Converts a Formation enum value to its displayable string name.
///    Usage:         string_name = scr_get_formation_name(Formation.GRID); // Returns "Grid"
///    Parameters:
///      formation_enum  : Formation   — The Formation enum value (e.g., Formation.LINE_HORIZONTAL).
///    Returns:       String        — The human-readable name of the formation, or "Unknown".
///    Tags:          [utility][string][ui][formation][enum_helper]
///    Version:       1.0 - [Current Date]
///    Dependencies:  Formation (enum, expected to be defined in scr_constants.gml)

function scr_get_formation_name(_formation_enum) {
    // =========================================================================
    // 1. CONVERT ENUM TO STRING
    // =========================================================================
    #region 1.1 Convert Enum to String
    switch (_formation_enum) {
        case Formation.NONE:
            return "None";
        case Formation.LINE_HORIZONTAL:
            return "Line Horizontal";
        case Formation.LINE_VERTICAL:
            return "Line Vertical";
        case Formation.GRID:
            return "Grid";
        // Add more cases here if you expand the Formation enum:
        // case Formation.WEDGE: return "Wedge";
        // case Formation.CIRCLE: return "Circle";
        default:
            // show_debug_message("Warning (scr_get_formation_name): Unknown formation enum value: " + string(_formation_enum));
            return "Unknown Formation";
    }
    #endregion
}