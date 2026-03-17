extends "res://scenes/actors/enemy_base.gd"


func _ready() -> void:
	enemy_id = "EN_G02"
	enemy_asset_id = "2"  # 雨虫群使用素材2
	max_health = 1  # HP极低
	attack_damage = 2  # 爆裂伤害较高
	move_speed = 20  # 移动缓慢
	super._ready()
