extends RoomBase

@onready var g03_spawn: Marker2D = $SpawnPoints/G03Entrance
@onready var shelter_spawn: Marker2D = $SpawnPoints/ShelterPoint

func _ready() -> void:
	room_id = "S01"
	super._ready()

func _get_spawn_position(spawn_id: String) -> Vector2:
	match spawn_id:
		"shelter", "S01":
			return shelter_spawn.global_position
		_:
			return g03_spawn.global_position

func _handle_interactable_default(kind: String, checkpoint_id: String, message: String) -> void:
	match kind:
		"message":
			hud.show_status(message)
		"checkpoint":
			# S01 uses "S01" as rainsleep ID
			GameState.record_rainsleep("S01", player.capture_state())
			player.apply_state(GameState.get_player_state())
			hud.show_status(message)
		_:
			hud.show_status(message)
