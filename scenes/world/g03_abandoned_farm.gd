extends RoomBase

@onready var g02_spawn: Marker2D = $SpawnPoints/G02Entrance
@onready var s01_spawn: Marker2D = $SpawnPoints/S01Entrance
@onready var shadow_figure: Sprite2D = $ShadowFigure

func _ready() -> void:
	room_id = "G03"
	super._ready()

func _on_arena_initialized(_spawn_id: String) -> void:
	# Connect enemy defeated signals for this room
	for actor in actors.get_children():
		if actor.is_in_group("enemies"):
			if actor.has_signal("defeated") and not actor.defeated.is_connected(_on_enemy_defeated):
				actor.defeated.connect(_on_enemy_defeated)
	hud.show_status(room_status_text)

func _get_spawn_position(spawn_id: String) -> Vector2:
	match spawn_id:
		"G02Entrance", "from_G02":
			return g02_spawn.global_position
		"S01Entrance", "from_S01", "S01":
			return s01_spawn.global_position
		_:
			return g02_spawn.global_position

func play_cg_event(config: Dictionary, on_complete: Callable) -> void:
	var cg_type: String = config.get("cg_type", "")
	if cg_type == "shadow_appears":
		_play_shadow_event(config, on_complete)
	else:
		on_complete.call()

func _play_shadow_event(config: Dictionary, on_complete: Callable) -> void:
	hud.show_status("影隐：'...采薇...'（远处的身影消失了）")

	shadow_figure.visible = true
	shadow_figure.modulate = Color(0.8, 0.8, 0.9, 0)

	var steps: Array = config.get("steps", [])
	var tween := create_tween()

	for step in steps:
		var step_type: String = step.get("type", "")
		match step_type:
			"show_sprite":
				var fade_in: float = step.get("fade_in", 1.0)
				tween.tween_property(shadow_figure, "modulate", Color(0.8, 0.8, 0.9, 0.7), fade_in)
			"wait":
				var duration: float = step.get("duration", 1.0)
				tween.tween_interval(duration)
			"fade_out":
				var duration: float = step.get("duration", 1.0)
				tween.tween_property(shadow_figure, "modulate", Color(0.8, 0.8, 0.9, 0), duration)

	tween.tween_callback(func():
		shadow_figure.visible = false
		on_complete.call()
	)
