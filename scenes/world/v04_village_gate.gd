extends RoomBase

@onready var v03_spawn: Marker2D = $SpawnPoints/V03Entrance
@onready var g01_spawn: Marker2D = $SpawnPoints/G01Entrance

func _ready() -> void:
	room_id = "V04"
	super._ready()

func _get_spawn_position(spawn_id: String) -> Vector2:
	match spawn_id:
		"V03Entrance", "from_V03":
			return v03_spawn.global_position
		"G01Entrance", "from_G01":
			return g01_spawn.global_position
		_:
			return v03_spawn.global_position
