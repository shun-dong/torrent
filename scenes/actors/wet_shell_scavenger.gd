extends "res://scenes/actors/enemy_base.gd"


func _ready() -> void:
	enemy_id = "EN_G03"
	enemy_asset_id = "3"  # 湿壳拾荒鼠使用素材3
	max_health = 2  # HP较低
	move_speed = 70  # 速度较快
	super._ready()
