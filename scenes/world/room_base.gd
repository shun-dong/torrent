class_name RoomBase
extends Node2D

const PLAYER_SCENE := preload("res://scenes/actors/Player.tscn")
const RAIN_SPORE_SCENE := preload("res://scenes/actors/RainSporeRemnant.tscn")
const RAIN_BUG_SCENE := preload("res://scenes/actors/RainBugSwarm.tscn")
const WET_SHELL_SCENE := preload("res://scenes/actors/WetShellScavenger.tscn")

@export var room_id: String = ""
@export var default_spawn_id: String = ""
@export var room_status_text: String = ""

@onready var hud: CanvasLayer = $HUD
@onready var spawn_points: Node2D = $SpawnPoints
@onready var actors: Node2D = $Actors
@onready var interactables: Node2D = $Interactables
@onready var portals: Node2D = $Portals

var player: Node = null
var _spawn_markers: Dictionary = {}
var _initialized := false

func _ready() -> void:
	_load_room_config()
	_cache_spawn_markers()
	_connect_interactables()
	_initialized = true
	EventManager.register_room(self)

func _load_room_config() -> void:
	if room_id.is_empty():
		return
	var rooms: Dictionary = GameState.design_data.get("rooms", {})
	var room_data: Dictionary = rooms.get(room_id, {})
	if room_data.is_empty():
		return

	# Load from CSV if not already set
	if room_status_text.is_empty():
		room_status_text = room_data.get("status_text", "")
	if default_spawn_id.is_empty():
		default_spawn_id = room_data.get("default_spawn", "")

func _cache_spawn_markers() -> void:
	if spawn_points:
		for marker in spawn_points.get_children():
			if marker is Marker2D:
				_spawn_markers[marker.name] = marker

func _connect_interactables() -> void:
	if not interactables:
		return
	for interactable in interactables.get_children():
		if interactable.has_signal("interacted"):
			if not interactable.interacted.is_connected(_on_interactable):
				interactable.interacted.connect(_on_interactable)

func initialize_arena(spawn_id: String) -> void:
	_cleanup_player()
	_spawn_player(spawn_id)
	_on_arena_initialized(spawn_id)
	EventManager.on_room_initialized(room_id, spawn_id)

func _on_arena_initialized(_spawn_id: String) -> void:
	if room_status_text:
		hud.show_status(room_status_text)

func _cleanup_player() -> void:
	if player != null and is_instance_valid(player):
		_disconnect_player_signals()
		player.queue_free()
		player = null

func _disconnect_player_signals() -> void:
	if player.died.is_connected(_on_player_died):
		player.died.disconnect(_on_player_died)
	if player.interaction_prompt_changed.is_connected(_on_player_prompt_changed):
		player.interaction_prompt_changed.disconnect(_on_player_prompt_changed)

func _spawn_player(spawn_id: String) -> void:
	player = PLAYER_SCENE.instantiate()
	actors.add_child(player)

	player.died.connect(_on_player_died)
	player.interaction_prompt_changed.connect(_on_player_prompt_changed)

	hud.bind_player(player)
	player.apply_state(GameState.get_player_state())
	player.global_position = _get_spawn_position(spawn_id)

func _get_spawn_position(spawn_id: String) -> Vector2:
	var marker = _spawn_markers.get(spawn_id, null)
	if marker:
		return marker.global_position
	if _spawn_markers.size() > 0:
		return _spawn_markers.values()[0].global_position
	return Vector2.ZERO

func _on_player_prompt_changed(text: String, visible_flag: bool) -> void:
	hud.set_prompt(text, visible_flag)

func _on_interactable(kind: String, checkpoint_id: String, message: String) -> void:
	var was_handled := EventManager.on_interactable_triggered(room_id, kind, checkpoint_id, message)
	if not was_handled:
		_handle_interactable_default(kind, checkpoint_id, message)

func _handle_interactable_default(kind: String, checkpoint_id: String, message: String) -> void:
	match kind:
		"message":
			hud.show_status(message)
		"portal":
			hud.show_status(message)
			await get_tree().create_timer(0.5).timeout
			_trigger_portal(checkpoint_id)
		"checkpoint":
			_handle_checkpoint(checkpoint_id, message)
		_:
			hud.show_status(message)

func _trigger_portal(target_scene: String) -> void:
	if not portals:
		return
	for portal in portals.get_children():
		if portal.has_signal("portal_triggered"):
			if target_scene in portal.target_scene_path:
				portal.monitoring = false
				portal.portal_triggered.emit(portal.target_scene_path, portal.target_spawn_id)
				return

func _handle_checkpoint(checkpoint_id: String, message: String) -> void:
	GameState.record_rainsleep(checkpoint_id, player.capture_state())
	player.apply_state(GameState.get_player_state())
	hud.show_status(message)

func _on_player_died() -> void:
	GameState.handle_player_death()
	var main := get_tree().get_first_node_in_group("main")
	if main != null and main.has_method("respawn_player"):
		main.respawn_player()
	else:
		call_deferred("initialize_arena", GameState.recent_rainsleep_id)
		hud.show_status("采薇在最近的雨眠点醒来。")

func play_cg_event(_config: Dictionary, on_complete: Callable) -> void:
	on_complete.call()

func spawn_enemies(enemy_config: Array) -> void:
	for enemy_data in enemy_config:
		var enemy_id: String = enemy_data.get("enemy_id", "")
		var pos: Dictionary = enemy_data.get("position", {})
		_spawn_enemy_at(enemy_id, Vector2(pos.get("x", 0), pos.get("y", 0)))

func _spawn_enemy_at(enemy_id: String, spawn_position: Vector2) -> void:
	var enemy_scene: PackedScene
	match enemy_id:
		"EN_G01":
			enemy_scene = RAIN_SPORE_SCENE
		"EN_G02":
			enemy_scene = RAIN_BUG_SCENE
		"EN_G03":
			enemy_scene = WET_SHELL_SCENE
		_:
			enemy_scene = RAIN_SPORE_SCENE

	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_position
	actors.add_child(enemy)

	if enemy.has_signal("defeated"):
		if not enemy.defeated.is_connected(_on_enemy_defeated):
			enemy.defeated.connect(_on_enemy_defeated)

func _on_enemy_defeated(enemy_id: String) -> void:
	EventManager.on_enemy_defeated(room_id, enemy_id)

func show_tutorial(tutorial_config: Dictionary) -> void:
	var steps: Array = tutorial_config.get("steps", [])
	for step in steps:
		var text: String = step.get("text", "")
		if text:
			hud.show_status(text)
		await get_tree().create_timer(3.0).timeout

func show_dialogue(dialogue_config: Dictionary) -> void:
	var speaker: String = dialogue_config.get("speaker", "")
	var lines: Array = dialogue_config.get("lines", [])
	for line in lines:
		hud.show_status("%s：%s" % [speaker, line])
		await get_tree().create_timer(2.5).timeout

func get_room_id() -> String:
	return room_id
