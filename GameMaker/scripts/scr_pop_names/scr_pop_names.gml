/// scr_pop_names.gml (Previously scr_name_data.gml)
///
/// DEPRECATED: This script and its functions are deprecated as of 2025-05-28.
/// The game now uses a centralized name generation system based on pre-generated names
/// loaded from `datafiles/gamedata/core/name_data.json` via `scr_load_external_data.gml`
/// and accessed through `scr_generate_pop_name.gml`.
///
/// This script provided hardcoded lists of name prefixes and suffixes, which are no longer
/// the primary method for name generation.
///
/// If any functions within this script are called, a debug message will be shown.
/// Consider updating any calling code to use `scr_generate_pop_name` instead.
///
/// Purpose (Legacy):
///    Provides functions to retrieve hardcoded lists of name segments
///    for pop name generation. This centralizes the name data within a script.
///
/// Metadata (Legacy):
///    Summary:         Functions returning arrays of name prefixes and suffixes.
///    Usage:           Call the Get_... functions from anywhere name lists are needed.
///                     e.g., var _prefixes = get_male_name_prefixes();
///    Tags:            [data][names][character][utility][deprecated]
///    Version:         1.2 — 2025-05-28 (Marked as deprecated)

// ============================================================================
// MALE NAME SEGMENTS
// ============================================================================
#region Male Name Segments

/// @function get_male_name_prefixes()
/// @description DEPRECATED. Returns an array of male name prefixes.
/// @returns {array<string>}
function get_male_name_prefixes() {
    show_debug_message("DEPRECATED: get_male_name_prefixes() in scr_pop_names.gml was called. Update to use scr_generate_pop_name.");
    return [
        "Rok", "Mog", "Zul", "Gron", "Bor", "Krag", "Tor", "Ur", "Dak", "Gar",
        "Hok", "Jorn", "Kaz", "Lug", "Nok", "Oog", "Prak", "Ruk", "Skor", "Thok",
        "Varg", "Zog", "Brog", "Durn", "Grak", "Hurn", "Kael", "Lorg", "Morn", "Narg",
        "Orn", "Porg", "Ragn", "Skarn", "Thane", "Vulk", "Zor", "Aga", "Bru", "Crog",
        "Drak", "Gruk", "Hark", "Juk", "Korg", "Lurtz", "Murg", "Norn", "Ork", "Pruk",
        "Rulk", "Skag", "Thul", "Vrak", "Zarg", "Ug", "Grol", "Thrag", "Krom", "Zorv"
        // Total: 55
    ];
}

/// @function get_male_name_suffixes()
/// @description DEPRECATED. Returns an array of male name suffixes.
/// @returns {array<string>}
function get_male_name_suffixes() {
    show_debug_message("DEPRECATED: get_male_name_suffixes() in scr_pop_names.gml was called. Update to use scr_generate_pop_name.");
    return [
        "nar", "tuk", "mak", "gon", "ak", "uk", "gar", "on", "og", "ar",
        "ek", "im", "ok", "ur", "ash", "esh", "ish", "osh", "ush", "th",
        "gath", "noth", "rok", "mok", "zok", "d", "g", "k", "m", "n",
        "r", "t", "ag", "ug", "ork", "und", "mar", "gul", "thak", "grak",
        "nok", "zod", "grom", "skar", "vok", "thag", "dorg", "nuk", "rog", "thul"
        // Total: 50
    ];
}

#endregion

// ============================================================================
// FEMALE NAME SEGMENTS
// ============================================================================
#region Female Name Segments

/// @function get_female_name_prefixes()
/// @description DEPRECATED. Returns an array of female name prefixes.
/// @returns {array<string>}
function get_female_name_prefixes() {
    show_debug_message("DEPRECATED: get_female_name_prefixes() in scr_pop_names.gml was called. Update to use scr_generate_pop_name.");
    return [
        "Ji", "Sha", "Ne", "Lu", "Gra", "Or", "Ka", "Tu", "Aya", "Bree",
        "Cora", "Deya", "Ela", "Fae", "Gia", "Hila", "Ina", "Jena", "Kyla", "Lira",
        "Mina", "Nyla", "Ova", "Pia", "Rina", "Sola", "Tia", "Ula", "Vena", "Wyla",
        "Xyla", "Yara", "Zena", "Asha", "Bora", "Cala", "Dara", "Esha", "Fila", "Gala",
        "Hana", "Isla", "Jola", "Kora", "Lana", "Mara", "Nara", "Osha", "Pola", "Raya",
        "Sena", "Tara", "Una", "Vila", "Wena", "Xara", "Yena", "Zola", "Mira", "Nessa"
        // Total: 57
    ];
}

/// @function get_female_name_suffixes()
/// @description DEPRECATED. Returns an array of female name suffixes.
/// @returns {array<string>}
function get_female_name_suffixes() {
    show_debug_message("DEPRECATED: get_female_name_suffixes() in scr_pop_names.gml was called. Update to use scr_generate_pop_name.");
    return [
        "kota", "shi", "la", "za", "et", "ia", "umi", "at", "a", "e",
        "i", "o", "u", "ana", "ena", "ina", "ona", "una", "ara", "era",
        "ira", "ora", "ura", "aya", "eya", "iya", "oya", "uya", "ka", "ma",
        "na", "ra", "sa", "ta", "va", "ya", "li", "ri", "ki", "si",
        "ni", "mi", "sha", "tha", "nia", "lia", "ria", "via", "zara", "nara"
        // Total: 50
    ];
}

#endregion
