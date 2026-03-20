extends RoomBase

@onready var bed_spawn: Marker2D = $SpawnPoints/BedSpawn
@onready var v02_spawn: Marker2D = $SpawnPoints/V02Spawn
@onready var opening_cutscene: CanvasLayer = $OpeningCutscene
@onready var black_screen: ColorRect = $OpeningCutscene/BlackScreen
@onready var intro_label: Label = $OpeningCutscene/IntroLabel
@onready var wake_label: Label = $OpeningCutscene/WakeLabel

var _opening_played := false

func _ready() -> void:
	room_id = "V01"
	super._ready()
	print("[V01_Home] Ready")

func initialize_arena(spawn_id: String) -> void:
	print("[V01_Home] Initializing arena with spawn_id: ", spawn_id)

	# Check if we should play opening cutscene (new game, coming from bed)
	if spawn_id == "bed" and not _opening_played:
		_play_opening_cutscene()
	else:
		_cleanup_player()
		_spawn_player(spawn_id)
		hud.show_status(room_status_text)
		EventManager.on_room_initialized(room_id, spawn_id)

func _get_spawn_position(spawn_id: String) -> Vector2:
	match spawn_id:
		"V02Entrance", "from_V02":
			return v02_spawn.global_position
		"bed", "start", _:
			return bed_spawn.global_position

func _handle_interactable_default(kind: String, checkpoint_id: String, message: String) -> void:
	match kind:
		"message":
			hud.show_status(message)
		"portal":
			hud.show_status(message)
			await get_tree().create_timer(0.5).timeout
			_trigger_portal(checkpoint_id)
		_:
			hud.show_status(message)

func play_cg_event(config: Dictionary, on_complete: Callable) -> void:
	var cg_type: String = config.get("cg_type", "")
	if cg_type == "opening":
		_play_opening_cg(config, on_complete)
	else:
		on_complete.call()

func _play_opening_cutscene() -> void:
	# Legacy opening - will be called by EventManager via play_cg_event
	_opening_played = true
	opening_cutscene.visible = true
	intro_label.modulate = Color(1, 1, 1, 0)
	wake_label.modulate = Color(1, 1, 1, 0)

	_cleanup_player()
	_spawn_player("bed")
	player.visible = false
	hud.visible = false

	var tween := create_tween()
	tween.tween_property(intro_label, "modulate", Color(1, 1, 1, 1), 2.0)
	tween.tween_interval(2.0)
	tween.tween_property(intro_label, "modulate", Color(1, 1, 1, 0), 1.0)
	tween.tween_callback(func():
		intro_label.visible = false
		wake_label.visible = true
	)
	tween.tween_property(wake_label, "modulate", Color(1, 1, 1, 1), 1.5)
	tween.tween_interval(2.0)
	tween.tween_property(black_screen, "modulate", Color(0, 0, 0, 0), 2.0)
	tween.tween_callback(func():
		opening_cutscene.visible = false
		player.visible = true
		hud.visible = true
		hud.show_status(room_status_text)
		EventManager.trigger_event_by_id("EV_V002")
	)

func _play_opening_cg(config: Dictionary, on_complete: Callable) -> void:
	_opening_played = true
	opening_cutscene.visible = true
	intro_label.modulate = Color(1, 1, 1, 0)
	wake_label.modulate = Color(1, 1, 1, 0)

	_cleanup_player()
	_spawn_player("bed")
	player.visible = false
	hud.visible = false

	var steps: Array = config.get("steps", [])
	var tween := create_tween()

	for step in steps:
		var step_type: String = step.get("type", "")
		match step_type:
			"fade_in":
				var target_name: String = step.get("target", "")
				var duration: float = step.get("duration", 1.0)
				var text: String = step.get("text", "")
				var wait: float = step.get("wait", 0.0)
				var target = _get_target(target_name)
				if target is Label and not text.is_empty():
					target.text = text
				if target:
					tween.tween_property(target, "modulate", Color(1, 1, 1, 1), duration)
				if wait > 0:
					tween.tween_interval(wait)
			"fade_out":
				var target_name: String = step.get("target", "")
				var duration: float = step.get("duration", 1.0)
				var target = _get_target(target_name)
				if target:
					tween.tween_property(target, "modulate", Color(1, 1, 1, 0), duration)

	tween.tween_callback(func():
		opening_cutscene.visible = false
		player.visible = true
		hud.visible = true
		hud.show_status(room_status_text)
		on_complete.call()
	)

func _get_target(target_name: String) -> Node:
	match target_name:
		"black_screen": return black_screen
		"intro_label": return intro_label
		"wake_label": return wake_label
		_: return null
