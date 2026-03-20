extends Node

func execute(event_data: Dictionary, content: Dictionary, on_complete: Callable) -> void:
	var room_id: String = event_data.get("room_id", "")
	var room = EventManager.get_active_room(room_id)
	if room and room.hud:
		room.hud.show_status(content.get("text", ""))
		await room.get_tree().create_timer(2.0).timeout
	on_complete.call()
