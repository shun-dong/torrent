extends Node

## 地图管理器
## 负责管理地图数据、房间连接关系和区域分组

# 房间类型颜色配置
const ROOM_COLORS := {
	"start": Color("#4CAF50"),      # 绿色 - 起始房间
	"normal": Color("#9E9E9E"),     # 灰色 - 普通房间
	"event": Color("#9C27B0"),      # 紫色 - 事件房间
	"shelter": Color("#2196F3"),    # 蓝色 - 避难所
	"shop": Color("#FFC107"),       # 黄色 - 商店
	"boss": Color("#F44336"),       # 红色 - Boss房间
}

# 当前房间高亮边框颜色
const CURRENT_ROOM_BORDER := Color("#FFFFFF")

# 连线颜色
const CONNECTION_COLOR := Color("#666666")

# 房间数据缓存
var _rooms_data: Dictionary = {}
var _area_rooms: Dictionary = {}
var _room_connections: Dictionary = {}
var _current_room_id: String = ""
var _current_area: String = ""
var _visited_rooms: Dictionary = {}  # 已访问的房间

func _ready() -> void:
	# 等待 GameState 加载完成
	await get_tree().process_frame
	_build_map_data()


## 构建地图数据
func _build_map_data() -> void:
	var rooms: Dictionary = GameState.design_data.get("rooms", {})
	if rooms.is_empty():
		push_warning("[MapManager] No room data found in GameState")
		return

	for room_id: String in rooms.keys():
		var room_data: Dictionary = rooms[room_id]
		var map_room := _parse_room_data(room_id, room_data)
		if map_room.is_empty():
			continue

		_rooms_data[room_id] = map_room

		# 按区域分组
		var area: String = map_room.get("area", "unknown")
		if not _area_rooms.has(area):
			_area_rooms[area] = []
		_area_rooms[area].append(room_id)

	# 构建连接关系
	_build_connections()

	print("[MapManager] Map data built: " + str(_rooms_data.size()) + " rooms in " + str(_area_rooms.size()) + " areas")


## 解析房间数据
func _parse_room_data(room_id: String, room_data: Dictionary) -> Dictionary:
	var coordinate_str: String = room_data.get("coordinate", "")
	if coordinate_str.is_empty():
		push_warning("[MapManager] Room %s has no coordinate" % room_id)
		return {}

	var coords := coordinate_str.split(",")
	if coords.size() != 2:
		push_warning("[MapManager] Room %s has invalid coordinate format: %s" % [room_id, coordinate_str])
		return {}

	return {
		"id": room_id,
		"name": room_data.get("name", ""),
		"coordinate": Vector2i(int(coords[0]), int(coords[1])),
		"type": room_data.get("type", "normal"),
		"area": room_data.get("area", "unknown"),
		"out": _parse_room_list(room_data.get("out", "")),
		"in": _parse_room_list(room_data.get("in", "")),
	}


## 解析房间列表字符串
func _parse_room_list(list_str: String) -> Array[String]:
	var result: Array[String] = []
	if list_str.is_empty():
		return result

	var items := list_str.split(";")
	for item in items:
		var trimmed := item.strip_edges()
		if not trimmed.is_empty():
			result.append(trimmed)
	return result


## 构建房间连接关系
func _build_connections() -> void:
	for room_id: String in _rooms_data.keys():
		var room: Dictionary = _rooms_data[room_id]
		var connections: Array[String] = []

		# 从 out 字段获取连接
		var out_rooms: Array[String] = room.get("out", [])
		for target_id: String in out_rooms:
			if _rooms_data.has(target_id) and target_id not in connections:
				connections.append(target_id)

		# 从 in 字段获取连接（双向）
		var in_rooms: Array[String] = room.get("in", [])
		for source_id: String in in_rooms:
			if _rooms_data.has(source_id) and source_id not in connections:
				connections.append(source_id)

		_room_connections[room_id] = connections


## 设置当前房间
func set_current_room(room_id: String) -> void:
	if _rooms_data.is_empty():
		push_warning("[MapManager] Room data not loaded yet")
		return

	if not _rooms_data.has(room_id):
		push_warning("[MapManager] Unknown room id: %s" % room_id)
		return

	_current_room_id = room_id
	var room: Dictionary = _rooms_data[room_id]
	_current_area = room.get("area", "")

	# 标记为已访问
	_visited_rooms[room_id] = true


## 获取当前房间ID
func get_current_room_id() -> String:
	return _current_room_id


## 获取当前区域
func get_current_area() -> String:
	return _current_area


## 获取当前区域的所有房间（只返回已访问的）
func get_area_rooms(area: String = "") -> Array[Dictionary]:
	var target_area := area if not area.is_empty() else _current_area

	if target_area.is_empty():
		return []

	if not _area_rooms.has(target_area):
		return []

	var result: Array[Dictionary] = []
	for room_id: String in _area_rooms[target_area]:
		if _rooms_data.has(room_id) and _visited_rooms.has(room_id):
			result.append(_rooms_data[room_id].duplicate())
	return result


## 检查房间是否已访问
func is_room_visited(room_id: String) -> bool:
	return _visited_rooms.has(room_id)


## 获取已访问房间数量
func get_visited_count() -> int:
	return _visited_rooms.size()


## 获取房间数据
func get_room_data(room_id: String) -> Dictionary:
	if _rooms_data.has(room_id):
		return _rooms_data[room_id].duplicate()
	return {}


## 获取房间的连接
func get_room_connections(room_id: String) -> Array[String]:
	if _room_connections.has(room_id):
		return _room_connections[room_id].duplicate()
	return []


## 检查两个房间是否相连
func are_rooms_connected(room_id1: String, room_id2: String) -> bool:
	if not _room_connections.has(room_id1):
		return false
	return room_id2 in _room_connections[room_id1]


## 获取房间类型颜色
func get_room_type_color(room_type: String) -> Color:
	return ROOM_COLORS.get(room_type, ROOM_COLORS["normal"])


## 获取所有区域列表
func get_all_areas() -> Array[String]:
	var result: Array[String] = []
	for area: String in _area_rooms.keys():
		result.append(area)
	return result


## 获取区域显示名称
func get_area_display_name(area: String) -> String:
	match area:
		"village": return "永宁村"
		"outskirts": return "郊区"
		"shelter_area": return "避难所"
		"boss_area": return "回响裂隙"
		_: return area
