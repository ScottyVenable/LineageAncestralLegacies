/// scr_formation_get_name.gml
/// Returns a user-friendly string name for a given FormationType enum value.
/// @param {FormationType} formation_type - The enum value for the formation.
/// @returns {string} The display name for the formation type.
function scr_formation_get_name(formation_type) {
    // Educational: This function provides readable names for formation enums for UI/debug.
    switch (formation_type) {
        case FormationType.NONE: return "None";
        case FormationType.GRID: return "Grid";
        case FormationType.LINE_HORIZONTAL: return "Line (Horizontal)";
        case FormationType.LINE_VERTICAL: return "Line (Vertical)";
        case FormationType.CIRCLE: return "Circle";
        case FormationType.RANDOM_WITHIN_RADIUS: return "Random (Radius)";
        case FormationType.SINGLE_POINT: return "Single Point";
        case FormationType.CLUSTERED: return "Clustered";
        case FormationType.PACK_SCATTER: return "Pack Scatter";
        case FormationType.SCATTER: return "Scatter";
        case FormationType.STAGGERED_LINE_HORIZONTAL: return "Staggered Line (Horizontal)";
        // Add more cases as you add new formation types.
        default: return "Unknown Formation";
    }
}
