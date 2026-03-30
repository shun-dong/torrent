extends CanvasLayer

## 地图 UI
## 显示当前区域的地图，包括房间节点和连接

@onready var map_panel: Panel = $MapPanel
@onready var map_container: Control = $MapPanel/MapContainer
@onready var title_label: Label = $MapPanel/TitleLabel

# 地图配置
const ROOM_SIZE := 24           # 房间方块大小
const ROOM_SPACING := 40        # 房间间距
const MAP_OFFSET := Vector2(20, 40)  # 地图内边距
const LINE_WIDTH := 2           # 连线宽度

# 节点引用
var _room_nodes: Dictionary = {}
var _connection_lines: Array[Line2D] = []
var _is_visible := false
var _active_tweens: Array[Tween] = []

func _ready() -> void:
	# 设置地图 UI 在暂停时仍然处理
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide_map()


## 显示地图
func show_map() -> void:
	if _is_visible:
		return

	if not is_instance_valid(map_panel) or not is_instance_valid(map_container):
		push_error("[MapUI] Map nodes not valid")
		return

	_is_visible = true
	visible = true
	_refresh_map()


## 隐藏地图
func hide_map() -> void:
	if not _is_visible:
		return

	_is_visible = false
	visible = false
	_clear_map()
	_stop_all_tweens()


## 切换地图显示
func toggle_map() -> void:
	if _is_visible:
		hide_map()
	else:
		show_map()


## 检查地图是否显示
func is_map_visible() -> bool:
	return _is_visible


## 刷新地图显示
func _refresh_map() -> void:
	_clear_map()

	if not is_instance_valid(map_panel) or not is_instance_valid(map_container):
		push_warning("[MapUI] Map panel or container is not valid")
		return

	var area := MapManager.get_current_area()
	if area.is_empty():
		title_label.text = "地图"
		push_warning("[MapUI] No current area set")
		return

	title_label.text = MapManager.get_area_display_name(area)

	var rooms := MapManager.get_area_rooms()
	if rooms.is_empty():
		push_warning("[MapUI] No rooms found in current area")
		return

	# 计算边界和偏移
	var bounds := _calculate_bounds(rooms)
	var center_offset := _calculate_center_offset(bounds)

	# 绘制连线（先绘制连线，后绘制房间，确保房间在连线上方）
	_draw_connections(rooms, center_offset)

	# 绘制房间
	_draw_rooms(rooms, center_offset)


## 计算房间边界
func _calculate_bounds(rooms: Array[Dictionary]) -> Rect2i:
	if rooms.is_empty():
		return Rect2i()

	var min_x := 999999
	var min_y := 999999
	var max_x := -999999
	var max_y := -999999

	for room: Dictionary in rooms:
		var coord: Vector2i = room.get("coordinate", Vector2i.ZERO)
		min_x = mini(min_x, coord.x)
		min_y = mini(min_y, coord.y)
		max_x = maxi(max_x, coord.x)
		max_y = maxi(max_y, coord.y)

	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


## 计算居中偏移
func _calculate_center_offset(bounds: Rect2i) -> Vector2:
	if not is_instance_valid(map_panel):
		return Vector2.ZERO

	var panel_size := map_panel.size - MAP_OFFSET * 2
	var map_size := Vector2(bounds.size.x * ROOM_SPACING, bounds.size.y * ROOM_SPACING)
	var centering_offset := (panel_size - map_size) / 2
	return centering_offset + MAP_OFFSET


## 绘制房间节点
func _draw_rooms(rooms: Array[Dictionary], center_offset: Vector2) -> void:
	if not is_instance_valid(map_container):
		return

	var current_room_id := MapManager.get_current_room_id()

	for room: Dictionary in rooms:
		var room_id: String = room.get("id", "")
		var coord: Vector2i = room.get("coordinate", Vector2i.ZERO)
		var room_type: String = room.get("type", "normal")

		# 创建房间节点容器
		var room_node := Control.new()
		room_node.position = center_offset + Vector2(coord.x * ROOM_SPACING, coord.y * ROOM_SPACING)
		room_node.custom_minimum_size = Vector2(ROOM_SIZE, ROOM_SIZE)
		map_container.add_child(room_node)
		_room_nodes[room_id] = room_node

		# 创建房间方块
		var room_rect := ColorRect.new()
		room_rect.custom_minimum_size = Vector2(ROOM_SIZE, ROOM_SIZE)
		room_rect.size = Vector2(ROOM_SIZE, ROOM_SIZE)
		room_rect.color = MapManager.get_room_type_color(room_type)
		room_node.add_child(room_rect)

		# 如果是当前房间，添加高亮边框
		if room_id == current_room_id:
			var border := ColorRect.new()
			border.custom_minimum_size = Vector2(ROOM_SIZE + 4, ROOM_SIZE + 4)
			border.size = Vector2(ROOM_SIZE + 4, ROOM_SIZE + 4)
			border.color = MapManager.CURRENT_ROOM_BORDER
			border.position = Vector2(-2, -2)
			room_node.add_child(border)
			room_node.move_child(border, 0)

			# 闪烁动画暂时禁用，测试是否有卡死问题
			# if is_instance_valid(border):
			# 	var tween := create_tween()
			# 	if tween != null:
			# 		tween.set_loops()
			# 		tween.tween_property(border, "modulate:a", 0.5, 0.5)
			# 		tween.tween_property(border, "modulate:a", 1.0, 0.5)
			# 		_active_tweens.append(tween)


## 绘制房间连接
func _draw_connections(rooms: Array[Dictionary], center_offset: Vector2) -> void:
	if not is_instance_valid(map_container):
		return

	var drawn_connections: Dictionary = {}

	for room: Dictionary in rooms:
		var room_id: String = room.get("id", "")
		var coord: Vector2i = room.get("coordinate", Vector2i.ZERO)
		var connections := MapManager.get_room_connections(room_id)

		for target_id: String in connections:
			# 检查目标房间是否已访问
			if not MapManager.is_room_visited(target_id):
				continue

			# 检查目标房间是否在当前区域
			var target_room := MapManager.get_room_data(target_id)
			if target_room.is_empty():
				continue
			if target_room.get("area", "") != MapManager.get_current_area():
				continue

			# 避免重复绘制
			var connection_key := _get_connection_key(room_id, target_id)
			if drawn_connections.has(connection_key):
				continue
			drawn_connections[connection_key] = true

			# 计算起点和终点
			var target_coord: Vector2i = target_room.get("coordinate", Vector2i.ZERO)
			var start_pos := center_offset + Vector2(
				coord.x * ROOM_SPACING + ROOM_SIZE / 2.0,
				coord.y * ROOM_SPACING + ROOM_SIZE / 2.0
			)
			var end_pos := center_offset + Vector2(
				target_coord.x * ROOM_SPACING + ROOM_SIZE / 2.0,
				target_coord.y * ROOM_SPACING + ROOM_SIZE / 2.0
			)

			# 创建连线
			var line := Line2D.new()
			line.add_point(start_pos)
			line.add_point(end_pos)
			line.width = LINE_WIDTH
			line.default_color = MapManager.CONNECTION_COLOR
			map_container.add_child(line)
			_connection_lines.append(line)


## 获取连接的唯一键（无序）
func _get_connection_key(id1: String, id2: String) -> String:
	if id1 < id2:
		return id1 + "-" + id2
	return id2 + "-" + id1


## 清除地图
func _clear_map() -> void:
	# 清除房间节点
	for room_id: String in _room_nodes.keys():
		var node: Node = _room_nodes[room_id]
		if is_instance_valid(node):
			node.queue_free()
	_room_nodes.clear()

	# 清除连线
	for line: Line2D in _connection_lines:
		if is_instance_valid(line):
			line.queue_free()
	_connection_lines.clear()


## 停止所有 tween 动画
func _stop_all_tweens() -> void:
	for tween: Tween in _active_tweens:
		if is_instance_valid(tween) and tween.is_running():
			tween.kill()
	_active_tweens.clear()


## 更新当前房间（外部调用）
func update_current_room() -> void:
	if _is_visible:
		_refresh_map()
