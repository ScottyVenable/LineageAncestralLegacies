/// scr_template_default.gml
///
/// Purpose:
///   Universal script template for *all* GML scripts in your project:
///     • Behavior  (state machines, pop actions)
///     • Utility   (math helpers, DS ops)
///     • UI        (panel draws, tooltips)
///     • Data/API  (JSON load/save, config)
///
/// Metadata:
///   Summary:       One‐line “what this script does”  
///   Usage:         Who calls it (e.g. “obj_pop Step Event”)  
///   Parameters:    Name : type — purpose  
///   Returns:       What it returns, or “void”  
///   Tags:          [behavior][utility][ui][data]  
///   Version:       1.0 — 2025-05-18  
///   Dependencies:  scr_inventory_add(), ds_map_exists(), etc.
function scr_template_default() {
    // =========================================================================
    // 0. IMPORTS & CACHES
    // =========================================================================
    #region 0.1 Imports & Cached Locals
 
    #endregion
    // =========================================================================
    // 1. VALIDATION & EARLY RETURNS
    // =========================================================================
    #region 1.1 Parameter Validation
    #endregion
    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS
    // =========================================================================
    #region 2.1 Local Constants
    #endregion
    // =========================================================================
    // 3. INITIALIZATION & STATE SETUP
    // =========================================================================
    #region 3.1 One‐Time Setup
		
    #endregion
    // =========================================================================
    // 4. CORE LOGIC
    // =========================================================================
    #region 4.1. Main Behavior / Utility Logic
    
    #region a) Movement (skip for pure utilities)
    #endregion
    
    #region b) Arrival & Action
    #endregion
    // =========================================================================
    // 5. CLEANUP & RETURN
    // =========================================================================
    #region 5.1 Cleanup & Return
    #endregion
    // =========================================================================
    // 6. DEBUG/PROFILING (Optional)
    // =========================================================================
    #region 6.1 Debug & Profile Hooks
    #endregion
}
function scr_ui_showDropoffText(x, y, amount, sprite) {
    /// scr_ui_showDropoffText(x, y, amount, sprite)
    /**
     * Shows a floating dropoff text popup (e.g., food icon + "+5") above a pop's head.
     *
     * @param {Real}   x      - X position in the room (above the pop)
     * @param {Real}   y      - Y position in the room (above the pop)
     * @param {Real}   amount - Amount deposited (e.g., 5 for +5 food)
     * @param {Sprite} sprite - Sprite index for the icon (e.g., spr_ui_icons_food)
     * @returns {void}
     *
     * Educational Note:
     *  - This function adds a struct to a global list managed by obj_gui_controller.
     *  - The Step and Draw GUI events in obj_gui_controller handle movement, fading, and drawing.
     *  - This is a common UI pattern for feedback in games (sometimes called a "popup" or "floating text").
     */
    // --- Validate global list exists ---
    if (!variable_global_exists("floating_dropoff_texts")) {
        global.floating_dropoff_texts = [];
    }
    // --- Create the popup struct ---
    var popup = {
        x: x, // Start position (room coordinates)
        y: y, // Start position (room coordinates)
        amount: amount, // Amount to display (e.g., 5 for +5)
        sprite: sprite, // Icon sprite index (e.g., spr_ui_icons_food)
        alpha: 1, // Start fully visible
        timer: 120, // Lifetime in steps (2 seconds at 60 FPS)
        float_speed: 0.5, // Pixels to move up per step (controls float distance)
        fade_speed: 1/120 // How fast to fade out (alpha per step)
    };
    // --- Add to the global list ---
    array_push(global.floating_dropoff_texts, popup);
    // --- Educational Note ---
    // This function does not draw or update the popup directly; it just adds it to the list.
    // The obj_gui_controller Step and Draw GUI events handle the rest.
}