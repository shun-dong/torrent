extends Node2D

const PLAYER_SCENE := preload("res://scenes/actors/Player.tscn")

var player: Node

@onready var hud: CanvasLayer = $HUD
@onready var start_spawn: Marker2D = $SpawnPoints/StartSpawn
@onready var shelter_spawn: Marker2D = $SpawnPoints/ShelterSpawn
@onready var sign: Interactable = $Interactables/TutorialSign
@onready var rainsleep: Interactable = $Interactables/RainSleepPoint


func _ready() -> void:
	sign.interacted.connect(_on_interactable)
	rainsleep.interacted.connect(_on_interactable)


func initialize_arena(spawn_id: String) -> void:
	if player == null:
		player = PLAYER_SCENE.instantiate()
		$Actors.add_child(player)
		player.died.connect(_on_player_died)
		player.interaction_prompt_changed.connect(_on_player_prompt_changed)
	hud.bind_player(player)
	player.apply_state(GameState.get_player_state())
	player.global_position = _spawn_for_id(spawn_id).global_position
	hud.show_status("旧猎刀已装备，按 J 攻击，按 L 弹反。")


func _spawn_for_id(spawn_id: String) -> Marker2D:
	return shelter_spawn if spawn_id == "shelter" else start_spawn


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
	var restored_state := GameState.handle_player_death()
	player.apply_state(restored_state)
	player.global_position = _spawn_for_id(GameState.get_continue_spawn_id()).global_position
	player.current_state = "idle"
	hud.show_status("采薇在最近的雨眠点醒来。")
