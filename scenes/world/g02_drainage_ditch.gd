extends Node2D

const PLAYER_SCENE := preload("res://scenes/actors/Player.tscn")

var player: Node

@onready var hud: CanvasLayer = $HUD
@onready var g01_spawn: Marker2D = $SpawnPoints/G01Entrance
@onready var g03_spawn: Marker2D = $SpawnPoints/G03Entrance


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
	hud.show_status("排水沟。雨虫群在积水处蠕动，小心爆裂。")


func _spawn_for_id(spawn_id: String) -> Marker2D:
	match spawn_id:
		"G02Entrance":
			return g03_spawn
		_:
			return g01_spawn


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
