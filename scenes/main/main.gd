extends Node

const MAIN_MENU_SCENE := preload("res://scenes/ui/MainMenu.tscn")
const DEBUG_MANAGER_SCENE := preload("res://scenes/debug/DebugManager.tscn")
const SCENE_PATHS := {
	"V01": "res://scenes/world/V01_Home.tscn",
	"V02": "res://scenes/world/V02_VillageRoad.tscn",
	"V03": "res://scenes/world/V03_VillageSquare.tscn",
	"V04": "res://scenes/world/V04_VillageGate.tscn",
	"G01": "res://scenes/world/G01_OutskirtsEntry.tscn",
	"G02": "res://scenes/world/G02_DrainageDitch.tscn",
	"G03": "res://scenes/world/G03_AbandonedFarm.tscn",
	"S01": "res://scenes/world/S01_Shelter.tscn",
	"test_arena": "res://scenes/world/TestArena.tscn",
}

var menu: Control
var current_arena: Node
var in_pause_menu := false
var debug_manager: CanvasLayer


func _ready() -> void:
	print("[Main] Main scene ready")
	add_to_group("main")

	# Initialize debug manager
	debug_manager = DEBUG_MANAGER_SCENE.instantiate()
	add_child(debug_manager)

	menu = MAIN_MENU_SCENE.instantiate()
	add_child(menu)
	menu.start_requested.connect(_on_start_requested)
	menu.continue_requested.connect(_on_continue_requested)
	menu.exit_requested.connect(_on_exit_requested)
	_refresh_menu()
	print("[Main] Menu ready, waiting for start")


func _unhandled_input(event: InputEvent) -> void:
	# Don't process pause if debug menu is visible
	if debug_manager != null and debug_manager.teleport_menu_visible:
		return
	if event.is_action_pressed("pause") and current_arena != null:
		if menu.visible:
			_resume_game()
		else:
			_show_pause_menu()
		get_viewport().set_input_as_handled()


func _on_start_requested() -> void:
	GameState.new_game()
	_load_arena(GameState.get_continue_spawn_id())


func _on_continue_requested() -> void:
	if current_arena != null and menu.visible:
		_resume_game()
		return
	if not GameState.begin_continue():
		return
	_load_arena(GameState.get_continue_spawn_id())


func _on_exit_requested() -> void:
	get_tree().quit()


func respawn_player() -> void:
	print("[Main] Respawning player at rainsleep point: ", GameState.recent_rainsleep_id)
	# Get the scene ID for the rainsleep point
	var respawn_scene_id := GameState.get_rainsleep_scene_id()
	print("[Main] Respawn scene ID: ", respawn_scene_id, ", current scene: ", GameState.current_scene_id)

	if respawn_scene_id != GameState.current_scene_id:
		# Need to switch scenes - use call_deferred to avoid physics conflicts
		GameState.current_scene_id = respawn_scene_id
		call_deferred("_load_arena", GameState.recent_rainsleep_id)
	else:
		# Same scene, just reposition and reset player
		if current_arena != null and current_arena.has_method("initialize_arena"):
			current_arena.initialize_arena(GameState.recent_rainsleep_id)


func _load_arena(spawn_id: String) -> void:
	print("[Main] Loading arena, spawn_id: ", spawn_id, ", current_scene: ", GameState.current_scene_id)
	get_tree().paused = false
	in_pause_menu = false
	if current_arena != null:
		current_arena.queue_free()

	var scene_id := GameState.current_scene_id
	var scene_path: String = SCENE_PATHS.get(scene_id, SCENE_PATHS["test_arena"])
	print("[Main] Loading scene: ", scene_path)
	var scene: PackedScene = load(scene_path)
	if scene == null:
		push_error("Failed to load scene: " + scene_path)
		return

	var arena: Node = scene.instantiate()
	current_arena = arena
	add_child(arena)
	move_child(current_arena, 0)
	print("[Main] Scene instantiated, connecting portals...")

	# Connect portal signals if the scene has them
	_connect_portals(arena)

	if current_arena.has_method("initialize_arena"):
		print("[Main] Initializing arena with spawn_id: ", spawn_id)
		current_arena.initialize_arena(spawn_id)
	_refresh_menu()
	menu.hide()


func _connect_portals(arena: Node) -> void:
	print("[Main] Connecting portals...")
	for child in arena.get_children():
		if child.name == "Portals":
			print("[Main] Found Portals node with ", child.get_child_count(), " children")
			for portal in child.get_children():
				if portal is AreaPortal:
					portal.portal_triggered.connect(_on_portal_triggered)
					print("[Main] Connected portal: ", portal.name, " -> ", portal.target_scene_path)


func _on_portal_triggered(target_path: String, spawn_id: String) -> void:
	print("[Main] Portal triggered: ", target_path, " spawn: ", spawn_id)
	# Extract scene ID from path
	for id in SCENE_PATHS.keys():
		if SCENE_PATHS[id] == target_path:
			GameState.current_scene_id = id
			print("[Main] Set current_scene_id to: ", id)
			break
	# Load arena immediately for smoother transition
	_load_arena(spawn_id)


func _show_pause_menu() -> void:
	if current_arena == null:
		return
	in_pause_menu = true
	get_tree().paused = true
	_refresh_menu()
	menu.show()


func _resume_game() -> void:
	in_pause_menu = false
	get_tree().paused = false
	menu.hide()
	_refresh_menu()


func _refresh_menu() -> void:
	var has_save := GameState.has_save_file()
	var can_resume := current_arena != null
	if menu.has_method("set_menu_state"):
		menu.set_menu_state(has_save, can_resume, in_pause_menu)
