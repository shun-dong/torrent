extends Node2D

const PLAYER_SCENE := preload("res://scenes/actors/Player.tscn")

var player: Node
var opening_played := false

@onready var hud: CanvasLayer = $HUD
@onready var bed_spawn: Marker2D = $SpawnPoints/BedSpawn
@onready var v02_spawn: Marker2D = $SpawnPoints/V02Spawn
@onready var opening_cutscene: CanvasLayer = $OpeningCutscene
@onready var black_screen: ColorRect = $OpeningCutscene/BlackScreen
@onready var intro_label: Label = $OpeningCutscene/IntroLabel
@onready var wake_label: Label = $OpeningCutscene/WakeLabel


func _ready() -> void:
	print("[V01_Home] Ready, connecting interactables...")
	for interactable in $Interactables.get_children():
		print("[V01_Home] Found interactable: ", interactable.name)
		if interactable.has_signal("interacted"):
			interactable.interacted.connect(_on_interactable)
			print("[V01_Home] Connected signal for: ", interactable.name)


func initialize_arena(spawn_id: String) -> void:
	print("[V01_Home] Initializing arena with spawn_id: ", spawn_id)

	# Check if we should play opening cutscene (new game, coming from bed)
	if spawn_id == "bed" and not opening_played:
		_play_opening_cutscene()
	else:
		_setup_player(spawn_id)
		hud.show_status("永宁村，采薇的家。去村会场找山海的回响。")


func _setup_player(spawn_id: String) -> void:
	if player == null:
		player = PLAYER_SCENE.instantiate()
		$Actors.add_child(player)
		player.died.connect(_on_player_died)
		player.interaction_prompt_changed.connect(_on_player_prompt_changed)
		print("[V01_Home] Player created")
	hud.bind_player(player)
	player.apply_state(GameState.get_player_state())
	player.global_position = _spawn_for_id(spawn_id).global_position
	print("[V01_Home] Player spawned at: ", player.global_position)


func _play_opening_cutscene() -> void:
	opening_played = true
	opening_cutscene.visible = true
	intro_label.modulate = Color(1, 1, 1, 0)
	wake_label.modulate = Color(1, 1, 1, 0)

	# Setup player but keep hidden initially
	_setup_player("bed")
	player.visible = false
	hud.visible = false

	# Sequence: fade in "清洗...活雨..."
	var tween := create_tween()
	tween.tween_property(intro_label, "modulate", Color(1, 1, 1, 1), 2.0)
	tween.tween_interval(2.0)
	tween.tween_property(intro_label, "modulate", Color(1, 1, 1, 0), 1.0)

	# Then fade in "采薇，醒来..."
	tween.tween_callback(func():
		intro_label.visible = false
		wake_label.visible = true
	)
	tween.tween_property(wake_label, "modulate", Color(1, 1, 1, 1), 1.5)
	tween.tween_interval(2.0)

	# Fade out black screen and show player
	tween.tween_property(black_screen, "modulate", Color(0, 0, 0, 0), 2.0)
	tween.tween_callback(func():
		opening_cutscene.visible = false
		player.visible = true
		hud.visible = true
		hud.show_status("永宁村，采薇的家。去村会场找山海的回响。")
	)


func _spawn_for_id(spawn_id: String) -> Marker2D:
	match spawn_id:
		"V02Entrance":
			return v02_spawn
		_:
			return bed_spawn


func _on_player_prompt_changed(text: String, visible: bool) -> void:
	hud.set_prompt(text, visible)


func _on_interactable(kind: String, checkpoint_id: String, message: String) -> void:
	match kind:
		"message":
			hud.show_status(message)
		"portal":
			hud.show_status(message)
			# Trigger portal transition
			await get_tree().create_timer(0.5).timeout
			_go_through_portal(checkpoint_id)
		_:
			hud.show_status(message)


func _go_through_portal(target_scene: String) -> void:
	print("[V01_Home] Going through portal to: ", target_scene)
	# Find the portal and trigger it
	for portal in $Portals.get_children():
		# Check if it's an AreaPortal by checking the script or method
		if portal.has_signal("portal_triggered"):
			print("[V01_Home] Checking portal: ", portal.name, " -> ", portal.target_scene_path)
			if target_scene in portal.target_scene_path:
				print("[V01_Home] Triggering portal: ", portal.name)
				# Disable monitoring to prevent player body from triggering it again
				portal.monitoring = false
				portal.portal_triggered.emit(portal.target_scene_path, portal.target_spawn_id)
				return


func _on_player_died() -> void:
	GameState.handle_player_death()
	# Find Main scene and trigger respawn
	var main := get_tree().get_first_node_in_group("main")
	if main != null and main.has_method("respawn_player"):
		main.respawn_player()
	else:
		# Fallback: local respawn
		player.apply_state(GameState.get_player_state())
		player.global_position = _spawn_for_id(GameState.get_continue_spawn_id()).global_position
		player.current_state = "idle"
		hud.show_status("采薇在最近的雨眠点醒来。")
