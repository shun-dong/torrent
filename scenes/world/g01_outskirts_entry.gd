extends Node2D

const PLAYER_SCENE := preload("res://scenes/actors/Player.tscn")

var player: Node

@onready var hud: CanvasLayer = $HUD
@onready var v04_spawn: Marker2D = $SpawnPoints/V04Entrance
@onready var g02_spawn: Marker2D = $SpawnPoints/G02Entrance


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
	hud.show_status("郊区入口。小心雨孢残骸，它们被活雨扭曲了。")


func _spawn_for_id(spawn_id: String) -> Marker2D:
	match spawn_id:
		"G01Entrance":
			return g02_spawn
		_:
			return v04_spawn


func _on_player_prompt_changed(text: String, visible: bool) -> void:
	hud.set_prompt(text, visible)


func _on_interactable(kind: String, _checkpoint_id: String, message: String) -> void:
	match kind:
		"message":
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
