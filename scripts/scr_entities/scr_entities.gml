/// scr_entities.gml
///
/// Purpose:
///    Defines the EntityType enum, provides the function get_entity_data()
///    to retrieve base data, and global.EntityCategories for organized enum access.
///    This script is the central data repository for all interactive entities in "Lineage: Ancestral Legacies".
///
/// Metadata:
///   Summary:       EntityType enums, data, and categorized access for a prehistoric/evolutionary survival game.
///   Usage:         Enums are global. Call get_entity_data(EntityType.ENUM_VALUE) or use global.EntityCategories.Category.SUBCATEGORY.ENUM.
///   Tags:          [data][entities][database][definitions][enums][ai][core_game_data][survival][prehistoric][evolution][gdd_aligned][research_informed]
///   Version:       1.3 - [Current Date] - Hominid research integration, refined species data.
///   Dependencies:  GML Objects (e.g., obj_pop, obj_redBerryBush from GDD), Item Enum Placeholders, AI State Placeholders. Research Doc: "Hominid Game Development Research"

// ============================================================================
// 1. ENTITY TYPE ENUMERATION (Refined based on GDD & Hominid Research)
// ============================================================================
#region 1.1 EntityType Enum Definition
enum EntityType {
    NONE,

    // --- HOMINID SPECIES & SPECIALIZED ROLES ---
    #region 1. Populations & Hominids
    // Reflecting evolutionary stages from research doc and roles from GDD
    POP_HOMO_HABILIS_EARLY,     // "Handy Man" [cite: 63]
    POP_HOMO_ERECTUS_EARLY,     // Efficient biped, fire user, migrator [cite: 82]
    POP_HOMO_SAPIENS_ARCHAIC,   // Early forms of H. sapiens [cite: 113]
    POP_HOMO_SAPIENS_MODERN,    // Anatomically and cognitively modern [cite: 113]

    // Roles/Specializations (can apply to later Hominid types)
    HOMINID_ROLE_HUNTER,
    HOMINID_ROLE_GATHERER,
    HOMINID_ROLE_CRAFTER,
    HOMINID_ROLE_BUILDER,
    HOMINID_ROLE_THINKER,       // DP/EP generation, language, innovation [cite: 139]
    HOMINID_ROLE_ELDER,         // Wisdom, teaching, tradition [cite: 129, 381]
    HOMINID_ROLE_CHILD,         // Learning, vulnerable
    HOMINID_ROLE_GUARD,
    HOMINID_ROLE_SHAMAN,        // Rituals, beliefs [cite: 130, 371]

    // Other Hominid Groups/States
    HOMINID_NOMAD_GROUP,        // Neutral wandering group
    HOMINID_RIVAL_TRIBE_MEMBER, // Generic rival
    HOMINID_RIVAL_TRIBE_SCOUT,
    HOMINID_RIVAL_TRIBE_WARRIOR,
    HOMINID_RIVAL_TRIBE_CHIEFTAIN,
    HOMINID_CANNIBAL_DEGENERATE,
    HOMINID_HERMIT_ISOLATED,
    HOMINID_TRADER_ITINERANT,
    // Sickness/Injury are states, not distinct entity types usually
    // POP_HOMINID_SPIRIT, // Kept for potential special/late game entities
    // POP_HOMINID_REFUGEE,
    #endregion

    // --- DOMESTICATED & TAMABLE ANIMALS ---
    #region 1.2 Domesticated & Tamable Animals
    DOG_COMPANION,
    DOG_HUNTING,
    DOG_GUARD,
    AUROCH_CALF_TAMABLE,        // Renamed for clarity
    AUROCH_BULL_DOMESTIC,
    AUROCH_COW_DOMESTIC,
    MOUFLON_LAMB_TAMABLE,
    MOUFLON_RAM_DOMESTIC,
    MOUFLON_EWE_DOMESTIC,
    BOAR_PIGLET_TAMABLE,        // Renamed
    BOAR_SOW_DOMESTIC,
    BOAR_MALE_DOMESTIC,
    JUNGLEFOWL_CHICK_TAMABLE,
    JUNGLEFOWL_ROOSTER_DOMESTIC,
    JUNGLEFOWL_HEN_DOMESTIC,
    DONKEY_WILD_TAMABLE,        // Renamed
    DONKEY_PACK_DOMESTIC,
    WOLF_PUP_TAMABLE,           // Renamed
    HYENA_CUB_TAMABLE,          // Renamed
    FALCON_CHICK_TAMABLE,
    GIANT_BEETLE_LARVA_TAMABLE,
    CAT_KITTEN_TAMABLE,         // Renamed
    HORSE_FOAL_TAMABLE,
    HORSE_DOMESTIC,
    REINDEER_CALF_TAMABLE,
    REINDEER_DOMESTIC,
    #endregion

    // --- CULTIVATED PLANTS (FARMABLE) ---
    #region 1.3 Cultivated Plants
    WHEAT_CROP,                 // Simplified, details in data. GDD: FARM_WILD_WHEAT_EARLY
    BARLEY_CROP,
    LENTILS_CROP,
    PEAS_CROP,
    GOURD_CROP,
    FLAX_CROP,
    HEMP_CROP,
    TARO_CROP,
    YAM_CROP,
    MINT_HERB_CROP,
    BASIL_HERB_CROP,
    POPPY_MEDICINAL_CROP,
    ALOE_VERA_MEDICINAL_CROP,
    MUSHROOM_OYSTER_LOG_CULT,   // More specific
    MUSHROOM_SHIITAKE_LOG_CULT,
    BERRY_STRAWBERRY_CULT,
    FRUIT_FIG_TREE_CULT,        // Trees are distinct
    SPICE_GINGER_CROP,
    SPICE_TURMERIC_CROP,
    DYE_MADDER_PLANT_CROP,
    DYE_WOAD_PLANT_CROP,
    COTTON_PLANT_CROP,
    RICE_PADDY_CROP,
    #endregion

    // --- WILDLIFE - HERBIVORES ---
    #region 1.4 Wildlife - Herbivores (Fauna mentioned in research [cite: 345, 348, 350])
    DEER_RED,                   // Data can specify stag, doe, fawn variants
    HORSE_WILD_PRZEWALSKI,      // Research: H. erectus diet
    AUROCH_WILD,                // Research: H. erectus diet [cite: 153]
    MOUFLON_WILD,
    BOAR_WILD,                  // Research: H. erectus diet [cite: 348]
    RABBIT_EUROPEAN,
    HARE_MOUNTAIN,
    MAMMOTH_WOOLLY,             // Research: H. sapiens diet [cite: 351]
    GIANT_SLOTH_GROUND,
    IRISH_ELK_MEGALOCEROS,      // Scientific name for clarity
    WOOLLY_RHINOCEROS,          // Research: H. erectus diet [cite: 153]
    GAZELLE_DORCAS,             // Example species
    IBEX_ALPINE,                // Example species
    BEAVER_EURASIAN,
    MUSK_OX,
    SAIGA_ANTELOPE,
    GIANT_TORTOISE_MEGALOCHELYS, // Research: H. erectus interaction [cite: 349]
    GIRAFFE_PREHISTORIC,        // Research: Australopithecus env [cite: 345]
    ZEBRA_PREHISTORIC,          // Research: Australopithecus env [cite: 345]
    WILDEBEEST_PREHISTORIC,
    HIPPOPOTAMUS_PREHISTORIC,   // Research: H. erectus diet [cite: 348]
    #endregion

    // --- WILDLIFE - PREDATORS & OMNIVORES ---
    #region 1.5 Wildlife - Predators & Omnivores (Fauna mentioned in research [cite: 194, 196, 345, 347])
    WOLF_GREY,
    WOLF_DIRE,
    SABERTOOTH_CAT_SMILODON,    // Research: Predator to H. habilis [cite: 196]
    SABERTOOTH_CAT_HOMOTHERIUM,
    LION_CAVE,                  // Research: Predator to Australopithecus [cite: 345]
    BEAR_CAVE_OMNIVORE,         // Changed for clarity
    BEAR_BROWN_OMNIVORE,
    BEAR_SHORT_FACED_PREDATOR,
    HYENA_CAVE_SPOTTED,         // Research: Predator to H. habilis [cite: 196] (bear-sized hyenas for Australopithecus [cite: 194])
    TERROR_BIRD_PHORUSRHACID,
    WEASEL_GIANT_MUSTELID,
    WOLVERINE_GLUTTON,
    CROCODILE_NILE_RIVER,       // Research: Predator to H. habilis [cite: 196]
    SNAKE_GIANT_PYTHON,
    EAGLE_LARGE_PREDATOR,       // Research: Taung child killer [cite: 195]
    VULTURE_CARRION,
    FOX_RED_OMNIVORE,
    BADGER_EURASIAN_OMNIVORE,
    JACKAL_GOLDEN_SCAVENGER,
    BAT_GIANT_CAVE_PREDATOR,
    PIRANHA_AGGRESSIVE_SCHOOL,
    LEOPARD_PREDATOR,           // Research: Predator to H. habilis [cite: 347]
    #endregion

    // --- FORAGEABLE WILD PLANTS ---
    #region 1.6 Forageable Wild Plants (Diet sources from research [cite: 45, 46, 69, 94, 124, 157])
    BERRY_BUSH_GENERIC_RED,     // Simplified, type in data
    BERRY_BUSH_GENERIC_BLUE,
    BERRY_BUSH_GENERIC_BLACK,
    ROOT_TUBER_WILD_GENERIC,    // Research: H. erectus & H. sapiens diet [cite: 94, 157]
    ROOT_WILD_EDIBLE_GENERIC,
    ONION_GARLIC_WILD_GENERIC,
    GREENS_LEAFY_WILD_GENERIC,  // Research: Australopithecus & H. habilis diet [cite: 45, 69]
    GREENS_NETTLES_FORAGEABLE,
    MUSHROOM_MOREL_EDIBLE,
    MUSHROOM_CHANTERELLE_EDIBLE,
    MUSHROOM_AMANITA_RED_POISON,
    MUSHROOM_AMANITA_PALE_POISON,
    MUSHROOM_PSILOCYBE_MAGIC,   // Simplified
    HERB_YARROW_HEALING,
    HERB_WILLOW_BARK_PAINRELIEF,
    HERB_CHAMOMILE_SOOTHING,
    FIBER_PLANT_REED_FORAGE,
    FIBER_PLANT_JUTE_FORAGE,
    SAP_BIRCH_TREE_FORAGE,
    RESIN_PINE_TREE_FORAGE,
    NUTS_HAZELNUT_FORAGEABLE_BUSH,
    NUTS_ACORN_OAK_FORAGEABLE,  // Research: H. sapiens diet [cite: 158] (Neanderthal example relevant)
    SEAWEED_KELP_FORAGEABLE,    // Research: H. erectus & H. sapiens diet [cite: 94, 125]
    CATTAIL_FORAGEABLE_PLANT,
    FERN_FIDDLEHEADS_FORAGEABLE,
    MUSHROOM_LUMINESCENT_FORAGEABLE,
    SEEDS_WILD_GRASS_FORAGEABLE, // Research: H. sapiens diet (Neanderthal) [cite: 158] Australopithecus C4/CAM [cite: 46]
    SUCCULENTS_WILD_FORAGEABLE, // Research: Australopithecus C4/CAM [cite: 46]
    FRUITS_WILD_TREE_FORAGEABLE,// Research: Australopithecus & H. habilis diet [cite: 45, 69]
    #endregion

    // --- BASIC GATHERABLE RESOURCES (NON-PLANT/ANIMAL SPECIFIC NODES) ---
    #region 1.7 Basic Gatherable Resource Nodes
    NODE_FLINT,                 // Research: Key tool material [cite: 285]
    NODE_WOOD_BRANCHES_DRY,
    NODE_WOOD_LOG_SOFT,
    NODE_WOOD_LOG_HARD,
    NODE_STONE_RIVER_PEBBLES,
    NODE_STONE_SLATE_DEPOSIT,
    NODE_CLAY_PIT,
    NODE_SAND_PIT,
    NODE_GRASS_DRY_PATCH,
    NODE_PLANT_FIBER_PATCH,
    NODE_ANIMAL_DUNG_DRY,
    NODE_SEASHELL_BED,
    NODE_BEESWAX_WILD_HIVE_PART, // Part of a wild hive structure
    NODE_HONEY_WILD_HIVE_PART,
    NODE_BIRCH_BARK_TREE_HARVEST, // Harvest point on birch trees
    NODE_PEAT_BOG_SURFACE,
    NODE_OCHRE_DEPOSIT_PIGMENT, // Research: H. erectus & H. sapiens use [cite: 98, 131, 361, 364]
    #endregion

    // --- MISCELLANEOUS ENVIRONMENTAL OBJECTS ---
    #region 1.8 Miscellaneous Environmental Objects
    ENV_BOULDER_LARGE_OBSTRUCTION, // Research: Environmental hazard [cite: 197]
    ENV_ROCK_OUTCROP_GENERAL,
    ENV_TREE_DEAD_FALLEN,
    ENV_TREE_STUMP_OLD,
    ENV_CAVE_ENTRANCE_NATURAL,   // Research: Shelter for Australopithecus [cite: 50, 177]
    ENV_WATER_SPRING_FRESH,
    ENV_PUDDLE_MUDDY,
    ENV_THORN_BUSH_IMPASSABLE,
    ENV_VINES_THICK_CLIMBABLE,
    ENV_SPIDER_WEB_OBSTRUCTION,
    ENV_ANT_HILL_TERRAIN,
    ENV_BIRD_NEST_EMPTY,        // Lootable variant for eggs/feathers handled by loot system
    ENV_CAMPFIRE_REMAINS_COLD,
    ENV_SKELETON_ANIMAL_DECAYED,
    ENV_SKELETON_HOMINID_ANCIENT, // Research: Purposeful burials for H. sapiens [cite: 130, 373]
    ENV_CRYSTAL_FORMATION_INERT,
    ENV_FUNGUS_LUMINESCENT_STATIC_PATCH,
    ENV_RIVER_RAPIDS_STATIC_FEATURE,
    ENV_ICE_PATCH_GROUND_SLICK,
    ENV_SHELL_MIDDEN_ANCIENT,   // Pile of discarded shells, sign of past activity
    #endregion

    // --- PLAYER/NPC BUILT STRUCTURES - FUNCTIONAL ---
    #region 1.9 Structures - Functional (Shelter evolution from research)
    STRUCTURE_SHELTER_LEAN_TO,
    STRUCTURE_SHELTER_HUT_RUDIMENTARY, // Research: H. habilis stone hut foundations [cite: 72, 179]
    STRUCTURE_SHELTER_HUT_ADVANCED,    // Research: H. erectus branch huts[cite: 181], H. sapiens mammoth bone huts [cite: 184]
    STRUCTURE_FIRE_PIT_HEARTH,         // Research: Controlled fire, hearths (H. erectus/H. heidelbergensis) [cite: 90, 312]
    STRUCTURE_WORKBENCH_STONE_TOOL,    // For Oldowan/Acheulean tools
    STRUCTURE_DRYING_RACK,
    STRUCTURE_STORAGE_PIT_SIMPLE,
    STRUCTURE_STORAGE_BASKET_WOVEN,    // Research: H. sapiens weaving [cite: 293]
    STRUCTURE_SMOKER_FOOD_CLAY,
    STRUCTURE_TANNING_RACK_PRIMITIVE,
    STRUCTURE_FISHING_WEIR_RIVER,
    STRUCTURE_SNARE_TRAP_GAME,
    STRUCTURE_GRINDING_SLAB_STONE,
    STRUCTURE_WATER_WELL_SIMPLE,       // Research: Early water control [cite: 171]
    STRUCTURE_DEFENSE_SPIKE_PIT,
    STRUCTURE_DEFENSE_PALISADE_WOOD,
    STRUCTURE_BEEHIVE_FRAME_DOMESTIC,
    STRUCTURE_HERBALIST_TABLE_PREP,
    STRUCTURE_TOOL_SHARPENER_GRINDSTONE,
    STRUCTURE_BRIDGE_LOG_BASIC,
    STRUCTURE_ANIMAL_PEN_FENCED,
    STRUCTURE_COMPOST_HEAP_ORGANIC,
    STRUCTURE_OBSERVATION_POST_BASIC,
    STRUCTURE_KILN_POTTERY_PIT,        // Research: H. sapiens pottery [cite: 293]
    STRUCTURE_WORK_STUMP_BASIC,
    STRUCTURE_LOOM_HAND_PRIMITIVE,
    STRUCTURE_FORGE_BLOOMERY_EARLY_METAL, // For potential later game copper/bronze
    STRUCTURE_BOAT_DUGOUT_CANOE_RIVER, // Research: H. erectus boats implied [cite: 269]
    #endregion

    // --- PLAYER/NPC BUILT STRUCTURES - RITUAL/DECORATIVE ---
    #region 1.10 Structures - Ritual/Decorative (Symbolism/Art from research)
    STRUCTURE_TOTEM_TRIBAL_SPIRIT,
    STRUCTURE_BURIAL_SITE_MARKED,      // Research: H. sapiens burials [cite: 130, 373]
    STRUCTURE_CAVE_ART_WALL_DESIGNATED, // Player designates a wall for art
    STRUCTURE_BONE_WINDCHIME,
    STRUCTURE_OFFERING_ALTAR_STONE,
    STRUCTURE_PATH_MARKER_CARVED,
    STRUCTURE_EFFIGY_TERRITORIAL,
    STRUCTURE_DRUM_CEREMONIAL_HIDE,    // Research: H. sapiens musical instruments [cite: 130]
    STRUCTURE_RITUAL_CIRCLE_STONES,    // Research: Deep cave collective rituals [cite: 376]
    STRUCTURE_OBSERVATORY_ALIGNMENT_STONES,
    STRUCTURE_ANCESTOR_SHRINE_RELICS,
    STRUCTURE_FEASTING_AREA_COMMUNAL,
    STRUCTURE_STORYTELLING_FIRE_MAIN,
    STRUCTURE_GARDEN_ORNAMENTAL_WILDPLANTS,
    STRUCTURE_BANNER_TRIBAL_PAINTED_HIDE,
    STRUCTURE_MEMORIAL_CARVED_POST,
    STRUCTURE_FOUNTAIN_DECORATIVE_SPRING,
    STRUCTURE_STATUE_CLAY_SYMBOLIC,
    STRUCTURE_SUN_DIAL_PRIMITIVE,
    STRUCTURE_SACRED_GROVE_ENCLOSURE,
    STRUCTURE_LANGUAGE_TEACHING_AREA, // GDD Language system: School/Scribe's hut
    STRUCTURE_LOREKEEPERS_HUT_STORIES, // GDD Language system
    STRUCTURE_ENGRAVED_STONE_MONUMENT, // Research: H. erectus engravings [cite: 98, 359]
    #endregion

    // --- ADVANCED/RARE MINERAL RESOURCES (NODES) ---
    #region 1.11 Resources - Mineral Advanced Nodes
    NODE_ORE_COPPER,
    NODE_ORE_TIN,
    NODE_ORE_IRON_HEMATITE,
    NODE_ORE_GOLD_VEIN,
    NODE_ORE_SILVER_VEIN,
    NODE_GEM_QUARTZ_CLUSTER,
    NODE_GEM_AMETHYST_GEODE,
    NODE_GEM_TURQUOISE_VEIN,
    NODE_OBSIDIAN_VOLCANIC_DEPOSIT,
    // Pigment deposits are covered by NODE_OCHRE_DEPOSIT_PIGMENT in basic resources
    NODE_SALT_ROCK_MINEABLE,    // Renamed for clarity
    NODE_SULFUR_VENT_CRYSTALS,
    NODE_COAL_SEAM_EXPOSED,
    NODE_PUMICE_STONE_QUARRY,
    NODE_LIMESTONE_DEPOSIT_QUARRYABLE,
    NODE_MARBLE_DEPOSIT_QUARRYABLE,
    NODE_FLINT_HIGH_GRADE_NODULES,
    NODE_NATIVE_COPPER_DEPOSIT,
    NODE_METEORITE_IMPACT_REMAINS,
    #endregion

    // --- SPECIALTY FLORA & TREES (SPECIFIC INTERACTABLE TYPES) ---
    #region 1.12 Flora - Trees & Specialty Plants
    TREE_TYPE_OAK,              // Generic type, specific instance data defines age/size
    TREE_TYPE_PINE,
    TREE_TYPE_BIRCH,
    TREE_TYPE_WILLOW,
    TREE_TYPE_MAPLE_SAP,
    TREE_TYPE_FRUIT_APPLE_WILD,
    TREE_TYPE_NUT_WALNUT_WILD,
    PLANT_BAMBOO_LARGE_GROVE_HARVESTABLE, // Represents a harvestable patch
    PLANT_VINE_THICK_ROPELIKE,
    PLANT_NETTLE_FIBER_PATCH,
    PLANT_INDIGO_DYE_SOURCE_PATCH,
    PLANT_GINSENG_MEDICINAL_ROOT_PATCH,
    PLANT_HEMLOCK_POISONOUS_PATCH,
    TREE_HOLLOW_USABLE,         // Empty hollow, can be used/interacted with
    PLANT_SPICE_PEPPER_WILD_GROWTH,
    TREE_TYPE_ELDER_BERRY_FLOWER,
    TREE_TYPE_SEQUOIA_GIANT,
    PLANT_COTTON_WILD_FIBER_SOURCE,
    TREE_TYPE_RUBBER_LATEX_YIELDING,
    PLANT_TOBACCO_WILD_LEAF_SOURCE,
    FLOWER_ORCHID_RARE_COLLECTIBLE,
    #endregion

    // --- MYTHICAL, LEGENDARY, & BOSS FAUNA ---
    #region 1.13 Fauna - Mythical & Bosses
    BOSS_MAMMOTH_SPIRIT,
    BOSS_SABERTOOTH_PHANTOM,
    BOSS_SPIDER_QUEEN_CAVE,
    BOSS_ELEMENTAL_EARTH_GUARDIAN,
    BOSS_THUNDERBIRD_YOUNG_STORM,
    BOSS_WYRM_PRIMAL_FOREST,
    BOSS_SHADOW_BEAST_NIGHTMARE,
    BOSS_CROCODILE_TITAN_ANCIENT,
    BOSS_SALAMANDER_VOLCANIC_FIRE,
    BOSS_ICE_WORM_GLACIAL_DEEP,
    BOSS_GRIFFIN_STONECLAW_PEAK,
    BOSS_CHIMERA_UNNATURAL_HYBRID,
    BOSS_CYCLOPS_ANCIENT_FORGEMASTER,
    BOSS_TROLL_CAVE_STONEGUARD,
    BOSS_NAGA_SERPENT_SWAMPWITCH,
    BOSS_BEHEMOTH_TITANIC_LANDWALKER,
    BOSS_KRAKEN_ABYSSAL_LAKEFIEND,
    BOSS_PHOENIX_REBORN_EMBERLING,
    BOSS_UNICORN_ELUSIVE_FORESTHEALER,
    BOSS_DRAGON_SKELETAL_WYRMLING,
    BOSS_MANTICORE_DESERT_RIDDLER,
    BOSS_BAT_ALPHA_ECHOING_CAVES,
    #endregion

    // --- ENVIRONMENTAL HAZARDS & COMPLEX INTERACTABLES ---
    #region 1.14 Environmental Hazards & Interactables
    HAZARD_AREA_QUICKSAND,
    HAZARD_EVENT_ROCKSLIDE_TRIGGER_ZONE,
    HAZARD_AREA_GEYSER_STEAM_VENT_PERIODIC,
    HAZARD_TERRAIN_ICE_SHEET_SLIPPERY,
    HAZARD_AREA_SWAMP_GAS_POCKET_FLAMMABLE,
    HAZARD_FLOW_LAVA_SURFACE_HOT,
    HAZARD_VENT_POISON_GAS_CAVE,
    HAZARD_TRAP_FALLING_TREE_NATURAL,
    HAZARD_CURRENT_WHIRLPOOL_WATER_STRONG,
    HAZARD_TERRAIN_EARTHQUAKE_FISSURE_TEMPORARY,
    HAZARD_EFFECT_BLIZZARD_ZONE_COLD,
    HAZARD_EFFECT_SANDSTORM_ZONE_ABRASIVE,
    HAZARD_POOL_ACID_CORROSIVE,
    HAZARD_TERRAIN_CRYSTAL_SHARD_FIELD_SHARP,
    HAZARD_EFFECT_FOG_BANK_OBSCURING,
    HAZARD_EVENT_LIGHTNING_STRIKE_POINT,
    HAZARD_TRAP_RUIN_PRESSURE_MECHANISM,
    HAZARD_TERRAIN_ILLUSIONARY_DECEPTIVE,
    HAZARD_AREA_RADIATED_MUTAGENIC,
    HAZARD_CLOUD_SPORE_FUNGAL_INFECTIOUS,
    HAZARD_ANOMALY_TEMPORAL_DISTORTION,
    HAZARD_EVENT_FOREST_FIRE_SPREADING,
    HAZARD_EVENT_FLOOD_WATER_RISING,
    HAZARD_CLOUD_DISEASE_STAGNANT_AIR,
    #endregion
}
show_debug_message("Enum 'EntityType' (scr_entities) Initialized with " + string(enum_size(EntityType)) + " entries. (v3 Research Integrated)");
#endregion

// ============================================================================
// 2. GLOBAL ENTITY CATEGORIES STRUCT (for organized enum access)
// ============================================================================
#region 2.1 global.EntityCategories Definition
global.EntityCategories = {
    Hominids: { // Changed from Populations for clarity with research
        Species: {
            AUSTRALOPITHECUS: EntityType.POP_AUSTRALOPITHECUS_EARLY,
            HOMO_HABILIS: EntityType.POP_HOMO_HABILIS_EARLY,
            HOMO_ERECTUS: EntityType.POP_HOMO_ERECTUS_EARLY,
            HOMO_SAPIENS_ARCHAIC: EntityType.POP_HOMO_SAPIENS_ARCHAIC,
            HOMO_SAPIENS_MODERN: EntityType.POP_HOMO_SAPIENS_MODERN,
        },
        Roles: { // These can be applied to H. sapiens or later H. erectus
            HUNTER: EntityType.HOMINID_ROLE_HUNTER,
            GATHERER: EntityType.HOMINID_ROLE_GATHERER,
            CRAFTER: EntityType.HOMINID_ROLE_CRAFTER,
            BUILDER: EntityType.HOMINID_ROLE_BUILDER,
            THINKER: EntityType.HOMINID_ROLE_THINKER,
            ELDER: EntityType.HOMINID_ROLE_ELDER,
            CHILD: EntityType.HOMINID_ROLE_CHILD, // Child state/type common to species
            GUARD: EntityType.HOMINID_ROLE_GUARD,
            SHAMAN: EntityType.HOMINID_ROLE_SHAMAN,
        },
        OtherGroupsStates: {
            NOMAD_GROUP: EntityType.HOMINID_NOMAD_GROUP,
            RIVAL_MEMBER: EntityType.HOMINID_RIVAL_TRIBE_MEMBER,
            // ... (add other RIVAL enums here if needed)
            CANNIBAL: EntityType.HOMINID_CANNIBAL_DEGENERATE,
            HERMIT: EntityType.HOMINID_HERMIT_ISOLATED,
            TRADER: EntityType.HOMINID_TRADER_ITINERANT,
        }
    },
    Fauna: {
        Domesticated: {
            DOG_COMPANION: EntityType.DOG_COMPANION,
            AUROCH_COW: EntityType.AUROCH_COW_DOMESTIC,
            // ... (full list of domesticated)
        },
        Tamable_Wild: {
            AUROCH_CALF: EntityType.AUROCH_CALF_TAMABLE,
            WOLF_PUP: EntityType.WOLF_PUP_TAMABLE,
            // ... (full list of tamable young)
        },
        Wildlife_Herbivores: {
            DEER: EntityType.DEER_RED, // Main type, data handles variants
            MAMMOTH: EntityType.MAMMOTH_WOOLLY,
            // ... (full list of herbivores)
        },
        Wildlife_Predators_Omnivores: {
            WOLF: EntityType.WOLF_GREY,
            SABERTOOTH_SMILODON: EntityType.SABERTOOTH_CAT_SMILODON, // Main type
            CAVE_BEAR: EntityType.BEAR_CAVE_OMNIVORE,
            // ... (full list of predators)
        },
        Mythical_Bosses: {
            MAMMOTH_SPIRIT: EntityType.BOSS_MAMMOTH_SPIRIT,
            SPIDER_QUEEN: EntityType.BOSS_SPIDER_QUEEN_CAVE,
            // ... (full list of bosses)
        }
    },
    Flora: {
        Cultivated_Crops: {
            WHEAT: EntityType.WHEAT_CROP,
            FLAX: EntityType.FLAX_CROP,
            // ... (full list of crops)
        },
        Forageable_Wild: {
            BERRY_BUSH_RED: EntityType.BERRY_BUSH_GENERIC_RED,
            MUSHROOM_MOREL: EntityType.MUSHROOM_MOREL_EDIBLE,
            // ... (full list of forageables)
        },
        Trees_Specialty_Interactable: { // Interactable tree types (not just resource nodes)
            OAK_TREE: EntityType.TREE_TYPE_OAK,
            PINE_TREE: EntityType.TREE_TYPE_PINE,
            BAMBOO_PATCH: EntityType.PLANT_BAMBOO_LARGE_GROVE_HARVESTABLE, // Represent a patch
            // ... (full list of specialty trees/plants)
        }
    },
    Resources_Nodes: {
        Basic_Nodes: { // Renamed for clarity
            FLINT: EntityType.NODE_FLINT,
            CLAY: EntityType.NODE_CLAY_PIT,
            OCHRE_PIGMENT: EntityType.NODE_OCHRE_DEPOSIT_PIGMENT,
            // ... (full list of basic resource nodes)
        },
        Mineral_Advanced_Nodes: {
            COPPER_ORE: EntityType.NODE_ORE_COPPER,
            IRON_ORE: EntityType.NODE_ORE_IRON_HEMATITE,
            // ... (full list of advanced mineral nodes)
        }
    },
    Structures: {
        Functional: {
            SHELTER_LEAN_TO: EntityType.STRUCTURE_SHELTER_LEAN_TO,
            FIRE_PIT_HEARTH: EntityType.STRUCTURE_FIRE_PIT_HEARTH,
            WORKBENCH_STONE_TOOL: EntityType.STRUCTURE_WORKBENCH_STONE_TOOL,
            // ... (full list of functional structures)
        },
        Ritual_Decorative: {
            TOTEM_TRIBAL: EntityType.STRUCTURE_TOTEM_TRIBAL_SPIRIT,
            BURIAL_SITE: EntityType.STRUCTURE_BURIAL_SITE_MARKED,
            // ... (full list of ritual/decorative structures)
        }
    },
    Environment: { // Renamed from Misc for clarity
        Static_Objects: { // Renamed
            BOULDER: EntityType.ENV_BOULDER_LARGE_OBSTRUCTION,
            CAVE_ENTRANCE: EntityType.ENV_CAVE_ENTRANCE_NATURAL,
            // ... (full list of static env objects)
        },
        Hazards_Complex_Interactables: { // Renamed
            QUICKSAND: EntityType.HAZARD_AREA_QUICKSAND,
            ROCKSLIDE_ZONE: EntityType.HAZARD_EVENT_ROCKSLIDE_TRIGGER_ZONE, // Renamed
            FOREST_FIRE: EntityType.HAZARD_EVENT_FOREST_FIRE_SPREADING,
            // ... (full list of hazards)
        }
    }
};
show_debug_message("Global 'EntityCategories' struct initialized. (v3 Research Integrated)");
#endregion

// ============================================================================
// 3. ENTITY DATA ACCESS FUNCTION & DATABASE
// ============================================================================
#region 3.1 get_entity_data() Function

/// @function get_entity_data(entity_enum_id)
/// @description Returns a struct containing the base properties for the given entity type.
/// @param {enum.EntityType} entity_enum_id The enum ID of the entity.
/// @returns {Struct|undefined} A new copy of the entity data struct, or undefined if not found.
function get_entity_data(entity_enum_id) {
    static entity_database = __internal_init_entity_database();

    if (struct_exists(entity_database, entity_enum_id)) {
        return struct_clone(entity_database[$ entity_enum_id]);
    }
    show_debug_message($"Warning (get_entity_data): No data found for entity enum: {entity_enum_id}.");
    return undefined;
}
#endregion

#region 3.2 __internal_init_entity_database() Helper Function

/// @function __internal_init_entity_database()
/// @description Initializes and returns the master database of entity properties.
/// @returns {Struct} The master entity database.
function __internal_init_entity_database() {
    show_debug_message("Initializing Entity Database (scr_entities)... (v3 Hominid Research Integrated)");
    var _db = {};

    // --- SECTION: Hominids (Refined based on Research Doc) ---
    #region Hominids Data (GDD: obj_pop, Research: Species Profiles)
    _db[$ EntityType.POP_AUSTRALOPITHECUS_EARLY] = {
        name: "Early Australopithecine", // Research: Australopithecus [cite: 39]
        description: "An early bipedal hominin, adapted to both woodlands and emerging savannas. Vulnerable but resourceful.",
        object_index: obj_pop, // GDD: obj_pop
        default_sprite: undefined, // TODO: Sprite for Australopithecus. GDD: Visual distinction for age/traits.
        tags: ["hominid", "australopithecus", "early_ancestor", "bipedal_early_inefficient", "tree_climber_retained", "sentient_basic", "social_small_kin_groups", "needs_food_plant_based_scavenged_meat", "needs_shelter_natural", "vulnerable_to_predators", "uses_simple_found_tools_opportunistic"], // Research: [cite: 41, 43, 26, 45, 48, 50, 51]
        faction: "PlayerTribe_AncestralDawn", // Represents the earliest playable stage
        is_interactive: true,
        is_destructible: true,
        max_health: 70, // Less robust than later hominids
        loot_table_placeholders: undefined,
        // Species specific data based on research
        base_speed_units_sec: 1.7, // Less efficient bipedalism [cite: 43, 53]
        perception_radius_pixels: 130, // Good for predator detection [cite: 42]
        default_ai_state_placeholder: "PopState.IDLE_FORAGING_CAUTIOUS",
        ai_behavior_archetype: "Forager_Scavenger_CautiousSurvivor",
        base_attack_damage: 3, // Primarily defensive, using found objects
        attack_range_pixels: 12,
        attack_cooldown_seconds: 2.0,
        diet_type_tags: ["primarily_herbivorous_fruits_leaves", "eats_c4_cam_fallback_foods_grasses_sedges", "scavenges_meat_opportunistic"], // Research: [cite: 45, 46, 47, 48]
        carrying_capacity_units: 5, // Hands freed by bipedalism [cite: 42]
        skill_aptitude_foraging: 1.2, // Key survival skill
        skill_aptitude_tree_climbing: 1.5, // Retained ability [cite: 43, 54]
        skill_aptitude_tool_use_basic: 0.8, // Simple tools [cite: 26]
        brain_size_cc_approx: 450, // Research: 375-612cc [cite: 22, 44]
        shelter_preference_tags: ["natural_cave", "dense_bush", "large_tree_canopy"], // Research: [cite: 50, 177]
        communication_tags: ["gestural", "simple_vocalizations_ape_like"], // Research: [cite: 236]
        social_structure_tags: ["small_kin_groups", "multi_male_multi_female_inferred"], // Research: [cite: 27, 250, 251]
        fire_use_level_tag: "fire_none_opportunistic_fearful", // Research: No fire use [cite: 27]
        tool_industry_level_tag: "tool_opportunistic_unmodified_stone_wood_A_garhi_simple_stone", // Research: [cite: 26]
        flavor_text_lore_snippet: "Taking its first upright steps into a world of giants and uncertainty.",
        // IDEA: GDD - "Efficient Bipedalism I" & "Tree Climbing Proficiency" as early traits[cite: 57].
        // IDEA: Research - Vulnerability to specific predators like eagles, large hyenas, sabertooths[cite: 194, 195].
        // TODO: Implement specific AI for tree climbing escape.
    };

    _db[$ EntityType.POP_HOMO_HABILIS_EARLY] = {
        name: "Early Homo habilis ('Handy Man')", // Research: Homo habilis [cite: 63]
        description: "A transitional hominin with increased brain size, known for consistent Oldowan tool use and scavenging.",
        object_index: obj_pop,
        default_sprite: undefined, // TODO: Sprite for H. habilis
        tags: ["hominid", "homo_habilis", "early_homo", "increased_brain_size", "bipedal_with_arboreal_capacity", "oldowan_tool_user", "scavenger_primary", "rudimentary_shelter_builder", "social_larger_groups_cooperative_defense"], // Research: [cite: 64, 65, 66, 69, 72, 253, 266]
        faction: "PlayerTribe_ToolMakersDawn",
        is_interactive: true,
        is_destructible: true,
        max_health: 80,
        loot_table_placeholders: undefined,
        base_speed_units_sec: 1.8,
        perception_radius_pixels: 140,
        default_ai_state_placeholder: "PopState.IDLE_SCAVENGING_TOOLMAKING",
        ai_behavior_archetype: "Scavenger_Crafter_GroupDefense",
        base_attack_damage: 4, // With simple tools
        diet_type_tags: ["omnivorous_fruits_leaves_woody_plants", "scavenged_meat_marrow_primary_animal_protein"], // Research: [cite: 69, 150, 152]
        carrying_capacity_units: 7,
        skill_aptitude_foraging: 1.0,
        skill_aptitude_tree_climbing: 1.0, // Still some capacity [cite: 65]
        skill_aptitude_tool_use_oldowan: 1.5, // Key trait [cite: 66]
        skill_aptitude_scavenging: 1.3, // Research: [cite: 68, 71]
        skill_aptitude_crafting_basic_stone_tools: 1.2, // Oldowan choppers/flakes
        brain_size_cc_approx: 650, // Research: 500-800cc [cite: 22, 64]
        shelter_preference_tags: ["rudimentary_stone_hut_circle", "natural_cave_improved", "windbreak_branches"], // Research: [cite: 72, 179]
        communication_tags: ["gestural_expanded", "basic_vocalizations_coordinated", "proto_symbolic_tool_meaning"], // Research: [cite: 238]
        social_structure_tags: ["multi_male_groups_defense_oriented", "estimated_group_size_70_85", "communal_butchering_eating_grounds"], // Research: [cite: 30, 253, 254, 266]
        fire_use_level_tag: "fire_none_likely_opportunistic_harvesting_natural_fires", // Research: [cite: 30]
        tool_industry_level_tag: "tool_oldowan_mode1_choppers_flakes_consistent_use", // Research: [cite: 29, 66, 285]
        flavor_text_lore_snippet: "With a sharper mind and a clever hand, they carve a new path from the scraps of the old world.",
        // IDEA: GDD - Unlocks "Tool Efficiency I," "Scavenging Expertise" traits[cite: 75].
        // IDEA: Research - Environmental pressure (cooler, drier grasslands) drove reliance on scavenging[cite: 70, 71, 79].
        // TODO: AI for cooperative defense using thrown stones/sticks.
    };

    _db[$ EntityType.POP_HOMO_ERECTUS_EARLY] = {
        name: "Early Homo erectus", // Research: Homo erectus [cite: 82]
        description: "A highly successful, adaptable hominin with modern body proportions, efficient bipedalism, controlled fire use, and Acheulean tool technology. The first great migrator.",
        object_index: obj_pop,
        default_sprite: undefined, // TODO: Sprite for H. erectus
        tags: ["hominid", "homo_erectus", "efficient_bipedal_long_distance", "controlled_fire_user", "acheulean_tool_maker_handaxes_spears", "active_hunter_large_game", "migratory_species_out_of_africa", "cooperative_social_groups_care_for_weak", "proto_language_user", "rudimentary_symbolic_behavior_ochre_engravings"], // Research: [cite: 83, 90, 87, 89, 93, 85, 95, 97, 98, 99]
        faction: "PlayerTribe_FireBearersJourney",
        is_interactive: true,
        is_destructible: true,
        max_health: 120, // More robust
        loot_table_placeholders: undefined,
        base_speed_units_sec: 2.5, // Efficient long-distance walking/running [cite: 83]
        perception_radius_pixels: 160,
        default_ai_state_placeholder: "PopState.IDLE_HUNTING_MAINTAINING_FIRE_EXPLORING",
        ai_behavior_archetype: "HunterGatherer_Explorer_FireKeeper_Cooperative",
        base_attack_damage: 8, // With Acheulean tools
        diet_type_tags: ["omnivorous_meat_rich_active_hunting", "eats_cooked_food", "eats_aquatic_resources_fish_shellfish", "eats_tubers_roots"], // Research: [cite: 93, 94, 106, 153, 155]
        carrying_capacity_units: 12,
        skill_aptitude_hunting_large_game: 1.5,
        skill_aptitude_tool_use_acheulean: 1.5, // Handaxes, spears [cite: 87, 89]
        skill_aptitude_fire_management: 1.3, // Controlled fire, hearths, cooking [cite: 90, 91, 101]
        skill_aptitude_endurance_running: 1.2, // Long-distance travel [cite: 83]
        skill_aptitude_crafting_advanced_stone_tools: 1.3,
        brain_size_cc_approx: 900, // Research: 650-1100cc [cite: 22, 84]
        shelter_preference_tags: ["constructed_branch_huts_stone_bracing", "long_huts_communal", "cave_shelters_improved_with_hearths"], // Research: [cite: 181, 182]
        communication_tags: ["proto_language_complex_coordination", "instructional_communication_tool_making_voyages"], // Research: [cite: 97, 239, 240]
        social_structure_tags: ["cooperative_multi_male_groups_large_hunts_quarrying", "social_care_for_old_weak", "larger_social_groups_complex_interactions", "group_size_over_20_inferred"], // Research: [cite: 95, 96, 255, 256, 277]
        fire_use_level_tag: "fire_controlled_hearths_cooking_warmth_protection_pyrotechnology_tool_treatment", // Research: [cite: 90, 91, 92, 106, 302, 311]
        tool_industry_level_tag: "tool_acheulean_mode2_bifacial_handaxes_wooden_spears_levallois_technique_later", // Research: [cite: 32, 87, 88, 89, 301]
        symbolic_behavior_tags: ["rudimentary_engravings_trinil_shell", "ochre_use_early"], // Research: [cite: 34, 98, 99, 359, 361]
        flavor_text_lore_snippet: "They carried fire and finely wrought stone across new horizons, their stride long and their gaze fixed on the unknown.",
        // IDEA: GDD - "Migration Challenges" requiring tech/traits[cite: 112]. Unlocks long-distance travel.
        // IDEA: Research - Feedback loop: cognitive advance -> tech progress -> better diet -> brain dev[cite: 107, 108].
        // TODO: Implement hearth mechanics and cooking benefits. AI for cooperative hunting of large game.
    };

    _db[$ EntityType.POP_HOMO_SAPIENS_ARCHAIC] = { // Represents early H. sapiens or intermediate forms like H. heidelbergensis if needed
        name: "Archaic Homo sapiens", // Research: Early H. sapiens[cite: 113], H. heidelbergensis as precursor [cite: 312]
        description: "An early form of Homo sapiens, demonstrating significant cognitive advancements, more sophisticated tool use, and increasingly complex social behaviors. Building hearths and expanding their world.",
        object_index: obj_pop,
        default_sprite: undefined, // TODO: Sprite for Archaic H. sapiens
        tags: ["hominid", "homo_sapiens_archaic", "advanced_cognition_early", "sophisticated_tool_use_hafting", "complex_social_behavior_early_burials_maybe", "controlled_fire_hearths_consistent", "active_hunter_diversified_prey", "early_symbolic_thought_pigments"], // Research: [cite: 116, 312, 304] (Neanderthal fire use also relevant context)
        faction: "PlayerTribe_HearthBuildersMindAwakens",
        is_interactive: true,
        is_destructible: true,
        max_health: 130,
        loot_table_placeholders: undefined,
        base_speed_units_sec: 2.3,
        perception_radius_pixels: 170,
        default_ai_state_placeholder: "PopState.IDLE_GROUP_HUNT_ADVANCED_CRAFTING_RITUAL_EARLY",
        ai_behavior_archetype: "HunterGatherer_CommunityBuilder_EarlyThinker",
        base_attack_damage: 10, // With better hafted tools
        diet_type_tags: ["omnivorous_highly_varied_cooked_food", "specialized_hunting_fishing_techniques_early", "diverse_plant_exploitation"], // Research: [cite: 124, 125, 156, 158]
        carrying_capacity_units: 15,
        skill_aptitude_hunting_specialized: 1.3,
        skill_aptitude_tool_use_levallois_hafted: 1.4, // More advanced stone working, hafting
        skill_aptitude_fire_engineering: 1.5, // Consistent hearths, pyrotechnology [cite: 303, 312]
        skill_aptitude_abstract_thought_early: 1.2, // Precursor to full symbolic thought
        skill_aptitude_cooperative_planning: 1.4,
        brain_size_cc_approx: 1200, // Transitional towards modern H. sapiens [cite: 115] (H. heidelbergensis ~1100-1400cc)
        shelter_preference_tags: ["constructed_huts_more_durable", "organized_cave_living_spaces_with_hearths", "semi_permanent_settlements_seasonal"], // Research: [cite: 123]
        communication_tags: ["proto_language_more_complex_nuanced", "teaching_knowledge_transfer_more_efficient"], // Research:
        social_structure_tags: ["larger_kin_groups_extended_families", "evidence_of_care_for_injured_elderly_more_pronounced", "early_ritualistic_behavior_around_death_maybe"], // Research: [cite: 128, 277]
        fire_use_level_tag: "fire_mastery_engineered_hearths_systematic_pyrotechnology_cooking_essential", // Research: [cite: 303, 312, 314]
        tool_industry_level_tag: "tool_middle_paleolithic_levallois_prepared_core_hafted_points_early_blades", // Research: (Context from Neanderthal/early H. sapiens tech)
        symbolic_behavior_tags: ["ochre_use_systematic_pigments", "early_engravings_bone_stone", "possible_simple_ornamentation"], // Research: [cite: 131, 364]
        flavor_text_lore_snippet: "The mind expands, the fire burns brighter, and the first true stories begin to be told around the communal hearth.",
        // IDEA: Could represent H. heidelbergensis or other transitional forms before full H. sapiens.
        // TODO: Define specific "hafting" recipes and benefits.
    };

    _db[$ EntityType.POP_HOMO_SAPIENS_MODERN] = {
        name: "Modern Homo sapiens", // Research: Early H. sapiens (anatomically modern) [cite: 113]
        description: "Anatomically and cognitively modern human, capable of complex language, abstract thought, sophisticated toolmaking, intricate social structures, and profound artistic and symbolic expression. The ultimate adapter.",
        object_index: obj_pop,
        default_sprite: undefined, // TODO: Sprite for H. sapiens
        tags: ["hominid", "homo_sapiens_modern", "complex_language_user", "abstract_thinker_planner", "specialized_composite_tool_maker_bow_arrow_needles", "global_dispersal_extreme_environment_adapter", "complex_cultural_groups_large_social_networks", "symbolic_art_music_ritual_burial_creator", "highly_cooperative_knowledge_transfer_advanced"], // Research: [cite: 116, 117, 119, 121, 122, 127, 129, 130, 132]
        faction: "PlayerTribe_LineageLegacyBuilders",
        is_interactive: true,
        is_destructible: true,
        max_health: 150, // Peak hominid health
        loot_table_placeholders: undefined,
        base_speed_units_sec: 2.2, // Adapted for varied terrains
        perception_radius_pixels: 180,
        default_ai_state_placeholder: "PopState.IDLE_ENGAGED_IN_COMPLEX_TASK_SOCIALIZING_CREATING",
        ai_behavior_archetype: "Innovator_CulturalLeader_MasterSurvivor_StrategicPlanner",
        base_attack_damage: 12, // With advanced weapons
        diet_type_tags: ["omnivorous_highly_adaptable_global_diet", "cooked_food_specialized_processing", "fishing_shellfish_hunting_trapping_agriculture_rudimentary_eventually"], // Research: [cite: 124, 125, 126, 157]
        carrying_capacity_units: 20, // With carrying aids (baskets, bags)
        skill_aptitude_all_max_potential: 1.5, // Highest learning potential
        skill_aptitude_language_complex: 2.0, // Key trait [cite: 117, 242]
        skill_aptitude_artistic_symbolic_expression: 1.8, // [cite: 130, 366]
        skill_aptitude_teaching_knowledge_transfer: 1.6, // [cite: 129, 386]
        brain_size_cc_approx: 1350, // Research: ~1300cc avg [cite: 22, 115]
        shelter_preference_tags: ["constructed_semi_permanent_huts_mammoth_bone_animal_skin", "organized_settlements_central_hearths_specialized_areas", "adapted_shelters_for_extreme_climates"], // Research: [cite: 123, 184]
        communication_tags: ["complex_syntactic_language_abstract_concepts_storytelling_planning", "symbolic_communication_art_music_ritual"], // Research: [cite: 117, 130, 137, 242]
        social_structure_tags: ["complex_multi_family_cultural_groups_alliances_trade_networks", "elaborate_social_rules_traditions_leadership_roles", "purposeful_burials_with_grave_goods_ritual_significance", "dunbars_number_group_cohesion_challenges_large_scale_cooperation"], // Research: [cite: 127, 130, 259, 260, 271, 373, 374]
        fire_use_level_tag: "fire_mastery_advanced_applications_kilns_lamps_complex_cooking", // Beyond just hearths
        tool_industry_level_tag: "tool_upper_paleolithic_specialized_blades_microliths_composite_tools_bow_arrow_spear_thrower_sewing_needles_fishing_hooks_harpoons_weaving_pottery", // Research: [cite: 36, 119, 120, 291, 292, 293]
        symbolic_behavior_tags: ["advanced_cave_art_painting_engraving_sculpture_ceramics", "musical_instruments_flutes_drums", "personal_ornamentation_jewelry_beads_body_paint", "complex_burial_rituals_grave_goods"], // Research: [cite: 130, 131, 132, 365, 366, 374]
        flavor_text_lore_snippet: "With minds ablaze and voices shaping new realities, they weave the tapestry of culture and walk paths to every corner of the world.",
        // IDEA: GDD - "Cultural Tech Tree" unlocks[cite: 139]. "Language System" fully developed[cite: 135].
        // IDEA: Research - "Cognitive Revolution"[cite: 136]. Adaptation to extreme climates[cite: 122, 140, 143].
        // TODO: Implement advanced crafting chains for composite tools, pottery, weaving.
    };

    // ... (Specialized Role data structs like HOMINID_ROLE_HUNTER would inherit from a base species like POP_HOMO_SAPIENS_MODERN but have different default AI, skill boosts, and equipment preferences)
    _db[$ EntityType.HOMINID_ROLE_HUNTER] = { // Example of a role, applied to a H. sapiens base
        name: "Skilled Hunter (H. sapiens)",
        description: "A Homo sapiens specializing in tracking, stalking, and taking down prey, vital for the tribe's sustenance.",
        // Many fields would be similar to POP_HOMO_SAPIENS_MODERN, but with overrides:
        // object_index, default_sprite (maybe slightly different attire/gear), faction would be same.
        // max_health could be slightly higher or have damage resistance.
        // loot_table: might carry more hunting tools.
        // --- Overrides & Additions ---
        // extends_entity_type: EntityType.POP_HOMO_SAPIENS_MODERN, // Hypothetical field for inheritance if system supports it
        tags: ["hominid", "homo_sapiens_modern", "role_hunter", "specialized_tracker", "expert_marksman_thrower", "stealthy_ambusher", "knows_animal_behavior", "logic_prioritizes_hunting_tasks", "logic_leads_hunting_parties"],
        base_speed_units_sec: 2.4, // Slightly faster or better stamina for chase
        perception_radius_pixels: 200, // Better at spotting prey
        default_ai_state_placeholder: "PopState.HUNTING_TRACKING_PREY",
        ai_behavior_archetype: "Specialist_Hunter_Stalker",
        base_attack_damage: 15, // Assumes proficient with hunting weapons
        skill_aptitude_hunting_specialized: 1.8, // Higher aptitude for their role
        skill_aptitude_tracking: 1.7,
        skill_aptitude_stealth: 1.5,
        skill_aptitude_ranged_weapons_bow_spear_thrower: 1.6,
        carrying_capacity_units: 18, // Carries back more game
        sound_placeholders: { alert: "snd_hunter_signal_call", attack: "snd_hominid_attack_focused_grunt" },
        flavor_text_lore_snippet: "Their senses are tuned to the rhythm of the wild, their aim true as the flight of an eagle.",
        // IDEA: GDD - Might generate more DP/EP from successful hunts.
        // IDEA: Unlocks ability to hunt more dangerous/elusive prey.
    };
    #endregion // End Hominids Data

    // --- SECTION: Wildlife - Herbivores (Example update with research context) ---
    #region Wildlife - Herbivores Data
    _db[$ EntityType.MAMMOTH_WOOLLY] = { // Represents a generic adult, variants for juvenile/matriarch could exist or be AI states
        name: "Woolly Mammoth", // Research: Hunted by H. sapiens [cite: 351]
        description: "A colossal, shaggy herbivore of the ice ages, its massive tusks a formidable defense and a prized resource.",
        object_index: obj_placeholder_entity, // Intended: obj_mammoth_ai
        default_sprite: undefined, // TODO: Sprite
        tags: ["fauna", "animal", "mammal", "herbivore", "megafauna", "wildlife", "source_meat_mammoth_massive", "source_hide_thick_furry_cold_insulation", "source_ivory_tusks_valuable_crafting_art", "source_bones_shelter_tools", "herd_animal_family_groups", "dangerous_when_threatened_or_protecting_young", "slow_but_powerful_charge", "ice_age_creature", "logic_resistant_to_cold", "logic_leaves_large_footprints_tracks"],
        faction: "Wildlife_Megafauna_NeutralDefensiveHerd",
        is_interactive: true,
        is_destructible: true,
        max_health: 800,
        loot_table_placeholders: [
            { item_enum_placeholder: "ITEM_RAW_MAMMOTH_MEAT_HUGE", quantity_min: 25, quantity_max: 40, chance: 1.0 },
            { item_enum_placeholder: "ITEM_MAMMOTH_HIDE_THICKEST_FUR", quantity_min: 3, quantity_max: 5, chance: 1.0 },
            { item_enum_placeholder: "ITEM_IVORY_TUSK_LARGE_PAIR_UNCARVED", quantity_min: 1, quantity_max: 1, chance: 0.9 },
            { item_enum_placeholder: "ITEM_MAMMOTH_BONE_GIANT", quantity_min: 5, quantity_max: 10, chance: 0.8 } // Research: H. sapiens used mammoth bones for huts [cite: 184]
        ],
        base_speed_units_sec: 1.7,
        perception_radius_pixels: 180, // Relies on smell and hearing too
        default_ai_state_placeholder: "AnimalState.GRAZING_HERD_PROTECTIVE",
        ai_behavior_archetype: "Megafauna_HerdGuardian_ChargeThreats_ProtectCalves",
        base_attack_damage: 45, // Tusk gore, stomp
        attack_range_pixels: 35,
        attack_cooldown_seconds: 4.5,
        attack_effect_tags: ["knockback_massive", "stun_chance_high", "area_of_effect_stomp_large_radius_tremor"],
        diet_type_tags: ["herbivore_grazer_browser", "eats_grasses_sedges_large_volume", "eats_shrubs_willow_birch_alder", "eats_tree_bark_winter_survival"],
        sound_placeholders: { alert: "snd_mammoth_trumpet_alarm_deep", attack: "snd_mammoth_charge_earthshaking_roar", death: "snd_mammoth_death_bellow_resounding", idle: "snd_mammoth_rumble_low_breathing_snow_crunch" },
        footstep_sfx_type: "MegafaunaHeavyThudSnow",
        primary_threats_tags: ["pop_homo_sapiens_modern_hunting_party_coordinated_traps", "saberthooth_cat_smilodon_pack_desperate_on_juveniles", "dire_wolf_pack_large_harassing_weak_individuals", "cave_lion_pride_opportunistic"],
        flavor_text_lore_snippet: "A walking mountain of fur and might, patriarch of the frozen plains, its memory etched in ice and ivory.",
        // IDEA: Research - Hunting mammoths a major endeavor requiring cooperation, advanced tools, and planning[cite: 270, 351].
        // IDEA: GDD - Could be a "key species" for certain biomes or eras, driving specific Hominid adaptations (e.g., "Mammoth Hunter" traits/culture).
    };
    #endregion

    // --- SECTION: Structures - Functional (Example update with research context) ---
    #region Structures - Functional Data
    _db[$ EntityType.STRUCTURE_FIRE_PIT_HEARTH] = {
        name: "Communal Hearth", // Research: H. erectus/heidelbergensis hearths [cite: 90, 312]
        description: "A well-maintained fire pit, often lined with stones. The heart of the camp, providing warmth, light, protection, and a place to cook food and socialize.",
        object_index: obj_placeholder_entity, // Intended: obj_structure_hearth
        default_sprite: undefined, // TODO: Sprite (inactive, active fire small, active fire large)
        tags: ["structure", "player_built", "functional_building", "fire_source_controlled", "cooking_station_basic", "warmth_source_cold_protection", "light_source_night_deterrent", "social_gathering_spot", "craftable_homo_erectus_era_onwards", "requires_fuel_wood_dung", "logic_deters_predators_small_medium", "logic_enables_cooking_recipes", "logic_provides_comfort_buff_aura"], // Research: Benefits of fire [cite: 91, 314, 315, 316]
        faction: "PlayerTribe_BuiltStructure_Essential",
        is_interactive: true, // Add fuel, cook, extinguish
        is_destructible: true, // Can be destroyed by weather or attack
        max_health: 120,
        build_materials_cost_placeholders: [
            { item_placeholder: "ITEM_STONE_RIVER_PEBBLE", quantity: 10 }, // For lining
            { item_placeholder: "ITEM_WOOD_BRANCH_DRY", quantity: 5 } // Initial fuel
        ],
        shelter_quality_rating: 0, // Is not shelter itself, but enhances it
        crafting_recipes_unlocked_tags: ["recipe_group_food_cooked_basic_meat_fish_roots"], // Enables cooking [cite: 91, 106]
        storage_capacity_slots: 0, // Or small for fuel
        allowed_placement_terrain_tags: ["terrain_flat_dirt_sheltered", "terrain_cave_floor_dry"], // Needs safe placement
        decay_rate_health_per_day: 2, // Needs maintenance if exposed
        worker_slots_max: 1, // For tending/cooking
        aura_effect_radius_pixels: 150, // Warmth/light/comfort radius
        aura_effect_tags: ["aura_buff_warmth_small", "aura_buff_comfort_small", "aura_deterrent_predator_weak"],
        is_repairable_flag: true,
        upgrade_to_entity_type_placeholder: "STRUCTURE_KILN_POTTERY_PIT", // If hearth can be upgraded for pyrotechnology
        structural_integrity_rating: 0.3,
        flavor_text_lore_snippet: "The crackling heart of the tribe, where stories are shared and the chill of the wild is kept at bay.",
        // IDEA: Research - Fire management as a skill[cite: 317]. Pyrotechnology for tool treatment[cite: 92, 303].
        // IDEA: GDD - "Mastery of Fire" is a key discovery. Needs fuel management.
    };
    #endregion

    // Add other sections and entities, refining with research and GDD...
    // For example, tool entities (though not directly in this script, their requirements are defined by pop capabilities):
    // Tool: Oldowan Chopper - Usable by: POP_HOMO_HABILIS_EARLY onwards. Materials: NODE_FLINT. Tags: ["tool_oldowan", "early_game_cutting_scraping"] [cite: 66, 286]
    // Tool: Acheulean Handaxe - Usable by: POP_HOMO_ERECTUS_EARLY onwards. Materials: NODE_FLINT_HIGH_GRADE. Tags: ["tool_acheulean", "mid_game_butchering_digging_woodworking"] [cite: 87, 288]
    // Tool: Hafted Spear - Usable by: POP_HOMO_SAPIENS_ARCHAIC onwards. Materials: ITEM_WOOD_LOG_HARD, ITEM_FLINT_SHARD_PREPARED, ITEM_PLANT_FIBER_STRONG. Tags: ["tool_composite", "hunting_weapon_thrusting_throwing"] [cite: 290, 304]
    // Tool: Bow and Arrow - Usable by: POP_HOMO_SAPIENS_MODERN. Materials: ITEM_WOOD_FLEXIBLE, ITEM_SINEW_ANIMAL, ITEM_FEATHERS_FLETCHING, ITEM_FLINT_ARROWHEAD. Tags: ["tool_ranged_weapon_advanced", "hunting_precision"] [cite: 119, 292]

    show_debug_message($"Entity Database Initialized. {struct_names_count(_db)} entities defined. (v3 Hominid Research Integrated)");
    return _db;
}
#endregion

