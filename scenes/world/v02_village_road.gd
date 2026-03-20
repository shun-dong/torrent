extends RoomBase

@onready var v01_spawn: Marker2D = $SpawnPoints/V01Entrance
@onready var v03_spawn: Marker2D = $SpawnPoints/V03Entrance

func _ready() -> void:
	room_id = "V02"
	super._ready()

func _get_spawn_position(spawn_id: String) -> Vector2:
	match spawn_id:
		"V01Entrance", "from_V01":
			return v01_spawn.global_position
		"V03Entrance", "from_V03":
			return v03_spawn.global_position
		"V04Entrance", "from_V04":
			return v03_spawn.global_position
		_:
			return v01_spawn.global_position
