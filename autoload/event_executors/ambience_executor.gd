extends Node

func execute(event_data: Dictionary, content: Dictionary, on_complete: Callable) -> void:
	var room_id: String = event_data.get("room_id", "")
	var room = EventManager.get_active_room(room_id)
	if room and room.hud:
		var region: String = content.get("region_popup", "")
		if region:
			room.hud.show_status(region)
	on_complete.call()
