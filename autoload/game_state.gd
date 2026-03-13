extends Node

signal save_state_changed(has_save: bool)
signal stats_changed(snapshot: Dictionary)

const SAVE_PATH := "user://savegame.json"
const DATA_FILES := {
	"operations": "res://data/operation.csv",
	"enemies": "res://data/enemy.csv",
	"items": "res://data/item.csv",
}

var design_data: Dictionary = {}
var initial_equipment: Dictionary = {}
var current_player_state := {
	"health": 5,
	"max_health": 5,
	"stamina": 100.0,
	"max_stamina": 100.0,
	"spirit": 0,
}
var karma: int = 0
var recent_rainsleep_id := "start"
var current_scene_id := "test_arena"
var runtime_active := false


func _ready() -> void:
	ensure_input_map()
	load_design_data()
	initial_equipment = {
		"weapon": design_data.get("items", {}).get("IT_W01", {}),
		"cloak": design_data.get("items", {}).get("IT_C01", {}),
	}
	save_state_changed.emit(has_save_file())


func ensure_input_map() -> void:
	var bindings := {
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"interact": [KEY_E],
		"pause": [KEY_ESCAPE],
		"light_attack": [KEY_J],
		"parry": [KEY_L],
	}
	for action in bindings.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for keycode in bindings[action]:
			if _action_has_key(action, keycode):
				continue
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			event.keycode = keycode
			InputMap.action_add_event(action, event)


func _action_has_key(action: String, keycode: int) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == keycode:
			return true
	return false


func load_design_data() -> void:
	design_data.clear()
	for key in DATA_FILES.keys():
		design_data[key] = load_csv_dict(DATA_FILES[key])


func load_csv_dict(path: String) -> Dictionary:
	var result := {}
	if not FileAccess.file_exists(path):
		return result
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return result
	var headers: PackedStringArray = []
	if not file.eof_reached():
		headers = file.get_csv_line()
	for index in headers.size():
		headers[index] = headers[index].strip_edges()
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.is_empty():
			continue
		var entry := {}
		for index in min(headers.size(), row.size()):
			entry[headers[index]] = row[index].strip_edges()
		var row_id := String(entry.get("id", ""))
		if not row_id.is_empty():
			result[row_id] = entry
	return result


func new_game() -> void:
	runtime_active = true
	karma = 0
	recent_rainsleep_id = "start"
	current_scene_id = "test_arena"
	current_player_state = default_player_state()
	stats_changed.emit(get_runtime_snapshot())


func begin_continue() -> bool:
	var save_data := load_game()
	if save_data.is_empty():
		return false
	runtime_active = true
	current_scene_id = String(save_data.get("scene_id", "test_arena"))
	recent_rainsleep_id = String(save_data.get("recent_rainsleep_id", "start"))
	karma = int(save_data.get("karma", 0))
	var saved_state: Dictionary = save_data.get("player_state", {})
	current_player_state = default_player_state()
	for key in saved_state.keys():
		current_player_state[key] = saved_state[key]
	stats_changed.emit(get_runtime_snapshot())
	return true


func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func get_continue_spawn_id() -> String:
	return recent_rainsleep_id


func default_player_state() -> Dictionary:
	return {
		"health": 5,
		"max_health": 5,
		"stamina": 100.0,
		"max_stamina": 100.0,
		"spirit": 0,
	}


func update_player_state(snapshot: Dictionary) -> void:
	for key in snapshot.keys():
		current_player_state[key] = snapshot[key]
	stats_changed.emit(get_runtime_snapshot())


func get_player_state() -> Dictionary:
	return current_player_state.duplicate(true)


func get_runtime_snapshot() -> Dictionary:
	return {
		"player_state": get_player_state(),
		"karma": karma,
		"recent_rainsleep_id": recent_rainsleep_id,
		"scene_id": current_scene_id,
	}


func record_rainsleep(checkpoint_id: String, player_snapshot: Dictionary) -> void:
	recent_rainsleep_id = checkpoint_id
	update_player_state(player_snapshot)
	restore_player_resources()
	save_game()


func restore_player_resources() -> void:
	current_player_state["health"] = current_player_state.get("max_health", 5)
	current_player_state["stamina"] = current_player_state.get("max_stamina", 100.0)
	stats_changed.emit(get_runtime_snapshot())


func add_karma(amount: int) -> void:
	karma += amount
	stats_changed.emit(get_runtime_snapshot())


func handle_player_death() -> Dictionary:
	restore_player_resources()
	return get_player_state()


func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	var payload := {
		"scene_id": current_scene_id,
		"recent_rainsleep_id": recent_rainsleep_id,
		"karma": karma,
		"player_state": current_player_state,
	}
	file.store_string(JSON.stringify(payload))
	save_state_changed.emit(true)


func load_game() -> Dictionary:
	if not has_save_file():
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed
