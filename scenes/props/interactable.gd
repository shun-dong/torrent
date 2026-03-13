extends Area2D
class_name Interactable

signal interacted(kind: String, checkpoint_id: String, message: String)

@export var prompt_text := "E 互动"
@export var interaction_message := ""
@export var interaction_kind := "message"
@export var checkpoint_id := ""


func interact() -> void:
	interacted.emit(interaction_kind, checkpoint_id, interaction_message)
