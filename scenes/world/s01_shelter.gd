extends Node2D

const PLAYER_SCENE := preload("res://scenes/actors/Player.tscn")

var player: Node

@onready var hud: CanvasLayer = $HUD
@onready var g03_spawn: Marker2D = $SpawnPoints/G03Entrance
@onready var shelter_spawn: Marker2D = $SpawnPoints/ShelterPoint


func _ready() -> void:
	for interactable in $Interactables.get_children():
		if interactable.has_signal("interacted"):
			interactable.interacted.connect(_on_interactable)


func initialize_arena(spawn_id: String) -> void:
	if player == null:
		player = PLAYER_SCENE.instantiate()
		$Actors.add_child(player)
		player.died.connect(_on_player_died)
		player.interaction_prompt_changed.connect(_on_player_prompt_changed)
	hud.bind_player(player)
	player.apply_state(GameState.get_player_state())
	player.global_position = _spawn_for_id(spawn_id).global_position
	hud.show_status("小型避难所。安全区域，可雨眠存档。")


func _spawn_for_id(spawn_id: String) -> Marker2D:
	match spawn_id:
		"shelter":
			return shelter_spawn
		_:
			return g03_spawn


func _on_player_prompt_changed(text: String, visible: bool) -> void:
	hud.set_prompt(text, visible)


func _on_interactable(kind: String, checkpoint_id: String, message: String) -> void:
	match kind:
		"message":
			hud.show_status(message)
		"checkpoint":
			player.restore_resources()
			GameState.record_rainsleep(checkpoint_id, player.capture_state())
			player.apply_state(GameState.get_player_state())
			hud.show_status(message)
		_:
			hud.show_status(message)


func _on_player_died() -> void:
	GameState.handle_player_death()
	var main := get_tree().get_first_node_in_group("main")
	if main != null and main.has_method("respawn_player"):
		main.respawn_player()
	else:
		player.apply_state(GameState.get_player_state())
		player.global_position = _spawn_for_id(GameState.get_continue_spawn_id()).global_position
		player.current_state = "idle"
		hud.show_status("采薇在最近的雨眠点醒来。")
