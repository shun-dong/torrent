extends Node2D

const PLAYER_SCENE := preload("res://scenes/actors/Player.tscn")

var player: Node

@onready var hud: CanvasLayer = $HUD
@onready var v01_spawn: Marker2D = $SpawnPoints/V01Entrance
@onready var v03_spawn: Marker2D = $SpawnPoints/V03Entrance


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
	hud.show_status("村路。绕过障碍前往村会场。")


func _spawn_for_id(spawn_id: String) -> Marker2D:
	match spawn_id:
		"V01Entrance", "from_V01":
			return v01_spawn
		"V03Entrance", "from_V03":
			return v03_spawn
		"V04Entrance", "from_V04":
			return v03_spawn  # V03 and V04 entrances are close
		_:
			print("[V02] Unknown spawn_id: ", spawn_id, ", defaulting to V01Entrance")
			return v01_spawn


func _on_player_prompt_changed(text: String, is_visible: bool) -> void:
	hud.set_prompt(text, is_visible)


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
		call_deferred("initialize_arena", GameState.recent_rainsleep_id)
		hud.show_status("采薇在最近的雨眠点醒来。")
