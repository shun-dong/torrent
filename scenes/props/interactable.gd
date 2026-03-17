extends Area2D
class_name Interactable

signal interacted(kind: String, checkpoint_id: String, message: String)

@export var prompt_text := "E 互动"
@export var interaction_message := ""
@export var interaction_kind := "message"
@export var checkpoint_id := ""


func _ready() -> void:
	print("[Interactable] Ready: ", name, " kind: ", interaction_kind)
	print("[Interactable] Collision layer: ", collision_layer, ", monitorable: ", monitorable)


func interact() -> void:
	print("[Interactable] Interacted: ", name, " -> ", interaction_message.substr(0, 30), "...")
	interacted.emit(interaction_kind, checkpoint_id, interaction_message)
