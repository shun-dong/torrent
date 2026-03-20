extends Node

func execute(event_data: Dictionary, content: Dictionary, on_complete: Callable) -> void:
	var room_id: String = event_data.get("room_id", "")
	var room = EventManager.get_active_room(room_id)
	if room and room.has_method("spawn_enemies"):
		room.spawn_enemies(content.get("enemies", []))
	on_complete.call()
