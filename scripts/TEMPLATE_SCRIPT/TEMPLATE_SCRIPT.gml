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

function scr_template_default(target, amount) {
    // =========================================================================
    // 0. IMPORTS & CACHES
    // =========================================================================
    #region 0.1 Imports & Cached Locals
    var _self        = id;
    var _room_speed  = room_speed;           
    var _ds_map_add  = scr_inventory_add;    
    #endregion


    // =========================================================================
    // 1. VALIDATION & EARLY RETURNS
    // =========================================================================
    #region 1.1 Parameter Validation
    if (!instance_exists(target)) {
        show_debug_message("ERROR: scr_template_default — invalid target");
        return false;
    }
    if (!is_real(amount) || amount <= 0) {
        show_debug_message("ERROR: scr_template_default — invalid amount");
        return false;
    }
    #endregion


    // =========================================================================
    // 2. CONFIGURATION & CONSTANTS
    // =========================================================================
    #region 2.1 Local Constants
    var INTERACT_RADIUS = 16;            
    var MOVE_SPEED      = 1.5;           
    var ACTION_INTERVAL = _room_speed;   
    #endregion


    // =========================================================================
    // 3. INITIALIZATION & STATE SETUP
    // =========================================================================
    #region 3.1 One‐Time Setup
    if (!has_initialized) {
        has_initialized   = true;
        original_depth    = depth;
        interaction_timer = 0;
    }
    #endregion


    // =========================================================================
    // 4. CORE LOGIC
    // =========================================================================
    #region 4.1. Main Behavior / Utility Logic
    
    #region a) Movement (skip for pure utilities)
    var tx = target.x, ty = target.y;
    direction = point_direction(x, y, tx, ty);
    speed     = MOVE_SPEED;
    scr_update_walk_sprite();
    #endregion
    
    #region b) Arrival & Action
    if (point_distance(x, y, tx, ty) < INTERACT_RADIUS) {
        x = tx; y = ty;
        speed = 0;

        interaction_timer += 1;
        if (interaction_timer >= ACTION_INTERVAL) {
            interaction_timer = 0;
            _ds_map_add(obj_berry_icon, amount);

            if (target.berry_count <= 0) {
                depth           = original_depth;
                state           = EntityState.WAITING;
                has_initialized = false;
                return true;
            }
        }
    }
    #endregion


    // =========================================================================
    // 5. CLEANUP & RETURN
    // =========================================================================
    #region 5.1 Cleanup & Return
    if (state == EntityState.WAITING) {
        speed = 0;
    }
    // free any temporary DS here, if used
    return true;
    #endregion


    // =========================================================================
    // 6. DEBUG/PROFILING (Optional)
    // =========================================================================
    #region 6.1 Debug & Profile Hooks
    // // var t0 = current_time;
    // // …heavy code…
    // // show_debug_message("Elapsed: " + (current_time - t0) + "ms");
    #endregion
}
