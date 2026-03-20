extends RoomBase

@onready var v02_spawn: Marker2D = $SpawnPoints/V02Entrance
@onready var v04_spawn: Marker2D = $SpawnPoints/V04Entrance
@onready var stage_front: Marker2D = $SpawnPoints/StageFront
@onready var silhouette: Sprite2D = $Silhouette

var _shanhai_triggered := false

func _ready() -> void:
	room_id = "V03"
	super._ready()

func _on_arena_initialized(_spawn_id: String) -> void:
	if _shanhai_triggered:
		hud.show_status("山海的回响已给出指引。前往村口，进入郊区。")
	else:
		hud.show_status(room_status_text)

func _get_spawn_position(spawn_id: String) -> Vector2:
	match spawn_id:
		"V02Entrance", "from_V02":
			return v02_spawn.global_position
		"V04Entrance", "from_V04":
			return v04_spawn.global_position
		_:
			return v04_spawn.global_position

func play_cg_event(config: Dictionary, on_complete: Callable) -> void:
	var cg_type: String = config.get("cg_type", "")
	if cg_type == "shanhai_echo":
		_shanhai_triggered = true
		_play_shanhai_echo(config, on_complete)
	else:
		on_complete.call()

func _play_shanhai_echo(config: Dictionary, on_complete: Callable) -> void:
	silhouette.visible = true
	silhouette.modulate = Color(0.3, 0.3, 0.4, 0)

	var steps: Array = config.get("steps", [])
	var tween := create_tween()

	for step in steps:
		var step_type: String = step.get("type", "")
		match step_type:
			"show_sprite":
				var fade_in: float = step.get("fade_in", 1.0)
				tween.tween_property(silhouette, "modulate", Color(0.3, 0.3, 0.4, 0.6), fade_in)
				tween.tween_interval(1.0)
			"dialogue":
				var speaker: String = step.get("speaker", "")
				var text: String = step.get("text", "")
				tween.tween_callback(func():
					hud.show_status("%s：'%s'" % [speaker, text])
				)
				tween.tween_interval(3.0)
			"fade_out":
				var duration: float = step.get("duration", 1.0)
				tween.tween_property(silhouette, "modulate", Color(0.3, 0.3, 0.4, 0), duration)

	tween.tween_callback(func():
		silhouette.visible = false
		hud.show_status("获得指引：前往郊区避难所。村口通道已开启。")
		on_complete.call()
	)
