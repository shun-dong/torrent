extends Node2D

const PLAYER_SCENE := preload("res://scenes/actors/Player.tscn")

var player: Node

@onready var hud: CanvasLayer = $HUD
@onready var g02_spawn: Marker2D = $SpawnPoints/G02Entrance
@onready var s01_spawn: Marker2D = $SpawnPoints/S01Entrance


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
	hud.show_status("废弃农道。湿壳拾荒鼠在此徘徊，前面就是避难所。")


func _spawn_for_id(spawn_id: String) -> Marker2D:
	match spawn_id:
		"G03Entrance":
			return s01_spawn
		_:
			return g02_spawn


func _on_player_prompt_changed(text: String, is_visible: bool) -> void:
	hud.set_prompt(text, is_visible)


func _on_interactable(kind: String, _checkpoint_id: String, message: String) -> void:
	match kind:
		"message":
			hud.show_status(message)
		_:
			hud.show_status(message)


func _on_player_died() -> void:
	var restored_state := GameState.handle_player_death()
	player.apply_state(restored_state)
	player.global_position = _spawn_for_id(GameState.get_continue_spawn_id()).global_position
	player.current_state = "idle"
	hud.show_status("采薇在最近的雨眠点醒来。")
