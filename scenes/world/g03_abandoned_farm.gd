extends Node2D

const PLAYER_SCENE := preload("res://scenes/actors/Player.tscn")

var player: Node
var enemies_remaining := 0
var shadow_event_triggered := false

@onready var hud: CanvasLayer = $HUD
@onready var g02_spawn: Marker2D = $SpawnPoints/G02Entrance
@onready var s01_spawn: Marker2D = $SpawnPoints/S01Entrance
@onready var shadow_figure: Sprite2D = $ShadowFigure


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

	# Connect to enemy defeat signals
	enemies_remaining = 0
	for enemy in $Actors.get_children():
		if enemy.is_in_group("enemies"):
			enemies_remaining += 1
			enemy.defeated.connect(_on_enemy_defeated)

	hud.show_status("废弃农道。湿壳拾荒鼠在此徘徊，前面就是避难所。")


func _on_enemy_defeated(_enemy_id: String) -> void:
	enemies_remaining -= 1
	if enemies_remaining <= 0 and not shadow_event_triggered:
		_trigger_shadow_event()


func _spawn_for_id(spawn_id: String) -> Marker2D:
	match spawn_id:
		"G03Entrance":
			return s01_spawn
		_:
			return g02_spawn


func _on_player_prompt_changed(text: String, visible: bool) -> void:
	hud.set_prompt(text, visible)


func _on_interactable(kind: String, _checkpoint_id: String, message: String) -> void:
	match kind:
		"message":
			hud.show_status(message)
		_:
			hud.show_status(message)


func _trigger_shadow_event() -> void:
	shadow_event_triggered = true
	hud.show_status("影隐：'...采薇...'（远处的身影消失了）")

	# Show shadow figure with fade in
	shadow_figure.visible = true
	shadow_figure.modulate = Color(0.8, 0.8, 0.9, 0)

	var tween := create_tween()
	tween.tween_property(shadow_figure, "modulate", Color(0.8, 0.8, 0.9, 0.7), 1.0)
	tween.tween_interval(2.0)
	tween.tween_property(shadow_figure, "modulate", Color(0.8, 0.8, 0.9, 0), 1.5)
	tween.tween_callback(func():
		shadow_figure.visible = false
	)


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
