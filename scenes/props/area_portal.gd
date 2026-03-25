extends Area2D

class_name AreaPortal

@export var target_scene_path: String = ""
@export var target_spawn_id: String = ""
@export var portal_id: String = ""
@export var cooldown: float = 0.3  # 传送后冷却时间，防止反复触发

signal portal_triggered(target_path: String, spawn_id: String)

var just_triggered: bool = false  # 标记是否刚触发过


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if just_triggered:
		return  # 冷却中，忽略
	if not body.is_in_group("player"):
		return

	# 触发传送 - 使用 call_deferred 避免 physics 查询冲突
	call_deferred("_emit_portal_triggered")

	# 进入冷却
	just_triggered = true
	await get_tree().create_timer(cooldown).timeout
	just_triggered = false


func _emit_portal_triggered() -> void:
	portal_triggered.emit(target_scene_path, target_spawn_id)
