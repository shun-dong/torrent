extends Node2D

const PLAYER_SCENE := preload("res://scenes/actors/Player.tscn")

var player: Node

@onready var hud: CanvasLayer = $HUD
@onready var bed_spawn: Marker2D = $SpawnPoints/BedSpawn
@onready var v02_spawn: Marker2D = $SpawnPoints/V02Spawn


func _ready() -> void:
	print("[V01_Home] Ready, connecting interactables...")
	for interactable in $Interactables.get_children():
		print("[V01_Home] Found interactable: ", interactable.name)
		if interactable.has_signal("interacted"):
			interactable.interacted.connect(_on_interactable)
			print("[V01_Home] Connected signal for: ", interactable.name)


func initialize_arena(spawn_id: String) -> void:
	print("[V01_Home] Initializing arena with spawn_id: ", spawn_id)
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
	hud.show_status("永宁村，采薇的家。去村会场找山海的回响。")


func _spawn_for_id(spawn_id: String) -> Marker2D:
	match spawn_id:
		"V02Entrance":
			return v02_spawn
		_:
			return bed_spawn


func _on_player_prompt_changed(text: String, is_visible: bool) -> void:
	hud.set_prompt(text, is_visible)


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
	var restored_state := GameState.handle_player_death()
	player.apply_state(restored_state)
	player.global_position = _spawn_for_id(GameState.get_continue_spawn_id()).global_position
	player.current_state = "idle"
	hud.show_status("采薇在最近的雨眠点醒来。")
