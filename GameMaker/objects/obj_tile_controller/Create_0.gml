/// @description Initialize Tile Manager for procedural generation

// --- Core Tile Properties ---
TILE_WIDTH = 16; // The width of your tiles in pixels
TILE_HEIGHT = 16; // The height of your tiles in pixels
GRASS_TILESET = ts_grass; // The tileset asset for your grass tiles. Make sure this exists!

// --- Chunk Properties ---
CHUNK_WIDTH_TILES = 32; // How many tiles wide a chunk is
CHUNK_HEIGHT_TILES = 32; // How many tiles high a chunk is
CHUNK_WIDTH_PIXELS = CHUNK_WIDTH_TILES * TILE_WIDTH;
CHUNK_HEIGHT_PIXELS = CHUNK_HEIGHT_TILES * TILE_HEIGHT;

// --- Tilemap Layer ---
// The depth of this layer should be behind other game objects but visible.
// Adjust depth as needed (e.g., a high positive number to be far back).
TILEMAP_LAYER_DEPTH = 10000; 
TILEMAP_LAYER_NAME = "tileset_grass"; // Name for the tilemap layer
tilemap_id = layer_tilemap_get_id(layer_get_id(TILEMAP_LAYER_NAME));

if (tilemap_id == -1) { // Layer or tilemap doesn't exist, so create it
    var _layer_id = layer_create(TILEMAP_LAYER_DEPTH, TILEMAP_LAYER_NAME);
    tilemap_id = layer_tilemap_create(_layer_id, 0, 0, GRASS_TILESET, room_width, room_height); 
    // Note: room_width/height for tilemap size is a default; it will effectively be infinite.
}

// --- Tracking Generated Chunks ---
// We use a ds_map where keys are strings like "chunkX_chunkY" and values are true if generated.
// This is more flexible for sparse worlds than a massive ds_grid.
generated_chunks_map = ds_map_create();

// --- Camera & View ---
// Get the primary camera (usually view_camera[0])
view_camera_main = view_camera[0];

// --- Tileset Information ---
// Get the number of tiles in the grass tileset. 
// This assumes your tileset is simple and all tiles are usable grass variants.
// For more complex tilesets (e.g., with non-grass tiles or auto-tiling rules), 
// you'd need a more sophisticated way to select valid grass tile indices.
var _ts_info = tileset_get_info(GRASS_TILESET);
if (is_struct(_ts_info)) {
    grass_tile_count = _ts_info.tile_count;
} else {
    show_error("ERROR (obj_tile_manager): Could not get info for tileset: " + string(GRASS_TILESET) + ". Ensure it exists and is a valid tileset.", true);
    grass_tile_count = 1; // Fallback to prevent crashes, but indicates an issue.
}


// Initial generation around the starting camera view
// You might want to call a function here to pre-generate the initial screen + a buffer
// For simplicity, the Step event will handle the first generation pass.
show_debug_message("obj_tile_manager initialized. Tilemap ID: " + string(tilemap_id) + ", Grass Tiles: " + string(grass_tile_count));
