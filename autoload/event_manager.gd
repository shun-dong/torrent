extends Node

signal event_completed(event_id: String)
signal event_triggered(event_id: String)

enum EventState {
	LOCKED,
	READY,
	RUNNING,
	COMPLETED,
}

var _event_states: Dictionary = {}
var _completed_events: Array = []
var _room_events: Dictionary = {}
var _active_rooms: Dictionary = {}
var _event_data: Dictionary = {}

var _executors: Dictionary = {}
var _current_event: String = ""
var _event_queue: Array = []

func _ready() -> void:
	_load_event_data()
	_register_executors()

func _load_event_data() -> void:
	var events: Dictionary = GameState.load_csv_dict("res://data/event.csv")
	for event_id in events.keys():
		var event_entry = events[event_id]
		event_entry["state"] = EventState.LOCKED
		_event_data[event_id] = event_entry

		var room_id: String = event_entry.get("room_id", "")
		if not _room_events.has(room_id):
			_room_events[room_id] = []
		_room_events[room_id].append(event_id)

func _register_executors() -> void:
	# Use load() instead of preload to avoid circular dependency
	var dialogue_executor = load("res://autoload/event_executors/dialogue_executor.gd").new()
	var cg_executor = load("res://autoload/event_executors/cg_executor.gd").new()
	var spawn_enemy_executor = load("res://autoload/event_executors/spawn_enemy_executor.gd").new()
	var tutorial_executor = load("res://autoload/event_executors/tutorial_executor.gd").new()
	var message_executor = load("res://autoload/event_executors/message_executor.gd").new()
	var ambience_executor = load("res://autoload/event_executors/ambience_executor.gd").new()

	_executors["dialogue"] = dialogue_executor
	_executors["cg"] = cg_executor
	_executors["spawn_enemy"] = spawn_enemy_executor
	_executors["tutorial"] = tutorial_executor
	_executors["message"] = message_executor
	_executors["ambience"] = ambience_executor

	for executor in _executors.values():
		add_child(executor)

func register_room(room: Node) -> void:
	if room.has_method("get_room_id"):
		_active_rooms[room.room_id] = room
	else:
		_active_rooms[room.room_id] = room

func unregister_room(room_id: String) -> void:
	_active_rooms.erase(room_id)

func get_active_room(room_id: String) -> Node:
	return _active_rooms.get(room_id, null)

func on_room_initialized(room_id: String, spawn_id: String) -> void:
	check_and_trigger_event(room_id, "first_enter", spawn_id)

func check_and_trigger_event(room_id: String, trigger_condition: String, trigger_param: String) -> bool:
	var events: Array = _room_events.get(room_id, [])
	for event_id in events:
		var event_data: Dictionary = _event_data.get(event_id, {})
		if event_data.get("state") != EventState.LOCKED:
			continue
		if _check_trigger(event_data, trigger_condition, trigger_param):
			_trigger_event(event_id)
			return true
	return false

func _check_trigger(event_data: Dictionary, condition: String, param: String) -> bool:
	var event_trigger: String = event_data.get("trigger_condition", "")
	var event_param: String = event_data.get("trigger_param", "")

	if event_trigger != condition:
		return false

	if event_param.is_empty():
		return true
	return event_param == param

func _trigger_event(event_id: String) -> void:
	if _current_event != "" and _current_event != event_id:
		_event_queue.append(event_id)
		return

	var event_data = _event_data.get(event_id, {})
	if event_data.is_empty():
		push_error("Event not found: " + event_id)
		return

	event_data["state"] = EventState.RUNNING
	_current_event = event_id

	var event_type: String = event_data.get("event_type", "")
	var content_str: String = event_data.get("content", "{}")
	var content = {}
	if content_str:
		var parsed = JSON.parse_string(content_str)
		if parsed != null:
			content = parsed

	var executor = _executors.get(event_type)
	if executor:
		executor.execute(event_data, content, _on_event_complete.bind(event_id))
	else:
		push_error("No executor for event type: " + event_type)
		_on_event_complete(event_id)

	event_triggered.emit(event_id)

func _on_event_complete(event_id: String) -> void:
	var event_data = _event_data.get(event_id, {})
	event_data["state"] = EventState.COMPLETED
	_completed_events.append(event_id)
	_current_event = ""

	var room_id: String = event_data.get("room_id", "")
	check_and_trigger_event(room_id, "event_complete", event_id)

	event_completed.emit(event_id)

	if _event_queue.size() > 0:
		var next_event = _event_queue.pop_front()
		_trigger_event(next_event)

func trigger_event_by_id(event_id: String) -> void:
	if _event_data.has(event_id):
		_trigger_event(event_id)

func is_event_completed(event_id: String) -> bool:
	return event_id in _completed_events

func on_interactable_triggered(room_id: String, kind: String, checkpoint_id: String, _message: String) -> bool:
	if kind == "message" or kind == "checkpoint":
		return check_and_trigger_event(room_id, "interact_object", checkpoint_id)
	return false

func on_enemy_defeated(room_id: String, _enemy_id: String) -> void:
	_check_enemy_cleared(room_id)

func _check_enemy_cleared(room_id: String) -> void:
	var room = _active_rooms.get(room_id)
	if not room:
		return

	var has_enemies := false
	if room.has_node("Actors"):
		for actor in room.get_node("Actors").get_children():
			if actor.is_in_group("enemies"):
				has_enemies = true
				break

	if not has_enemies:
		check_and_trigger_event(room_id, "enemy_cleared", "")
