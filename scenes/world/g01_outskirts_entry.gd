extends RoomBase

@onready var v04_spawn: Marker2D = $SpawnPoints/V04Entrance
@onready var g02_spawn: Marker2D = $SpawnPoints/G02Entrance

func _ready() -> void:
	room_id = "G01"
	super._ready()

func _get_spawn_position(spawn_id: String) -> Vector2:
	match spawn_id:
		"V04Entrance", "from_V04":
			return v04_spawn.global_position
		"G02Entrance", "from_G02":
			return g02_spawn.global_position
		_:
			return v04_spawn.global_position
