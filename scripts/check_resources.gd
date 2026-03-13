extends SceneTree

const REQUIRED_RESOURCES := [
	"res://autoload/game_state.gd",
	"res://scenes/main/Main.tscn",
	"res://scenes/main/main.gd",
	"res://scenes/ui/MainMenu.tscn",
	"res://scenes/ui/main_menu.gd",
	"res://scenes/ui/HUD.tscn",
	"res://scenes/ui/hud.gd",
	"res://scenes/world/TestArena.tscn",
	"res://scenes/world/test_arena.gd",
	"res://scenes/actors/Player.tscn",
	"res://scenes/actors/player.gd",
	"res://scenes/actors/RainSporeRemnant.tscn",
	"res://scenes/actors/rain_spore_remnant.gd",
	"res://scenes/actors/enemy_base.gd",
	"res://scenes/props/Interactable.tscn",
	"res://scenes/props/interactable.gd",
]


func _initialize() -> void:
	for path in REQUIRED_RESOURCES:
		assert(ResourceLoader.exists(path), "Missing resource: %s" % path)
		var resource = load(path)
		assert(resource != null, "Failed to load resource: %s" % path)
	quit(0)
