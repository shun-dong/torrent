extends Node2D

const PLAYER_SCENE := preload("res://scenes/actors/Player.tscn")

var player: Node
var shanhai_triggered := false

@onready var hud: CanvasLayer = $HUD
@onready var v02_spawn: Marker2D = $SpawnPoints/V02Entrance
@onready var v04_spawn: Marker2D = $SpawnPoints/V04Entrance
@onready var stage_front: Marker2D = $SpawnPoints/StageFront
@onready var silhouette: Sprite2D = $Silhouette


func _ready() -> void:
	for interactable in $Interactables.get_children():
		if interactable.has_signal("interacted"):
			interactable.interacted.connect(_on_interactable)


func initialize_arena(spawn_id: String) -> void:
	# Disconnect existing signals to prevent double-connection on respawn
	if player != null and is_instance_valid(player):
		if player.died.is_connected(_on_player_died):
			player.died.disconnect(_on_player_died)
		if player.interaction_prompt_changed.is_connected(_on_player_prompt_changed):
			player.interaction_prompt_changed.disconnect(_on_player_prompt_changed)
		player.queue_free()
		player = null

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
		"V02Entrance", "from_V02":
			return v02_spawn
		"V04Entrance", "from_V04":
			return v04_spawn
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
	# 增强的山海回响演出
	silhouette.visible = true
	silhouette.modulate = Color(0.3, 0.3, 0.4, 0)

	# Fade in silhouette from right edge
	var tween := create_tween()
	tween.tween_property(silhouette, "modulate", Color(0.3, 0.3, 0.4, 0.6), 2.0)
	tween.tween_interval(1.0)

	# Show dialogue
	tween.tween_callback(func():
		hud.show_status("山海：'采薇...来避难所...'")
	)
	tween.tween_interval(3.0)

	# Fade out silhouette
	tween.tween_property(silhouette, "modulate", Color(0.3, 0.3, 0.4, 0), 2.0)
	tween.tween_callback(func():
		silhouette.visible = false
		hud.show_status("获得指引：前往郊区避难所。村口通道已开启。")
	)


func _on_player_died() -> void:
	GameState.handle_player_death()
	var main := get_tree().get_first_node_in_group("main")
	if main != null and main.has_method("respawn_player"):
		main.respawn_player()
	else:
		call_deferred("initialize_arena", GameState.recent_rainsleep_id)
		hud.show_status("采薇在最近的雨眠点醒来。")
