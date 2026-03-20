extends RoomBase

@onready var g01_spawn: Marker2D = $SpawnPoints/G01Entrance
@onready var g03_spawn: Marker2D = $SpawnPoints/G03Entrance

func _ready() -> void:
	room_id = "G02"
	super._ready()

func _get_spawn_position(spawn_id: String) -> Vector2:
	match spawn_id:
		"G01Entrance", "from_G01":
			return g01_spawn.global_position
		"G03Entrance", "from_G03":
			return g03_spawn.global_position
		_:
			return g01_spawn.global_position
