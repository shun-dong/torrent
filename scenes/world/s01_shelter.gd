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
