extends Node2D

const PLAYER_SCENE := preload("res://scenes/actors/Player.tscn")

var player: Node
var shanhai_triggered := false

@onready var hud: CanvasLayer = $HUD
@onready var v02_spawn: Marker2D = $SpawnPoints/V02Entrance
@onready var v04_spawn: Marker2D = $SpawnPoints/V04Entrance
@onready var stage_front: Marker2D = $SpawnPoints/StageFront


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

	if not shanhai_triggered:
		hud.show_status("村会场。山海的回响在这里等待。")
	else:
		hud.show_status("山海的回响已给出指引。前往村口，进入郊区。")


func _spawn_for_id(spawn_id: String) -> Marker2D:
	match spawn_id:
		"V02Entrance":
			return v02_spawn
		_:
			return v04_spawn


func _on_player_prompt_changed(text: String, is_visible: bool) -> void:
	hud.set_prompt(text, is_visible)


func _on_interactable(kind: String, _checkpoint_id: String, message: String) -> void:
	match kind:
		"message":
			hud.show_status(message)
			if not shanhai_triggered:
				shanhai_triggered = true
				_show_shanhai_event()
		_:
			hud.show_status(message)


func _show_shanhai_event() -> void:
	# 简单的剧情触发
	await get_tree().create_timer(3.0).timeout
	hud.show_status("获得指引：前往郊区避难所。村口通道已开启。")


func _on_player_died() -> void:
	var restored_state := GameState.handle_player_death()
	player.apply_state(restored_state)
	player.global_position = _spawn_for_id(GameState.get_continue_spawn_id()).global_position
	player.current_state = "idle"
	hud.show_status("采薇在最近的雨眠点醒来。")
