## 地图系统验证脚本
## 在 Godot 控制台中运行此脚本来测试地图系统

extends SceneTree

func _init():
	# 等待一帧确保自动加载完成
	await create_timer(0.1).timeout

	print("=== 地图系统验证 ===")

	# 检查 MapManager 是否存在
	var map_mgr = get_root().get_node_or_null("MapManager")
	if map_mgr == null:
		print("错误: MapManager 未找到")
		quit()
		return

	print("✓ MapManager 已加载")

	# 检查房间数据
	var rooms = map_mgr._rooms_data
	print("房间数量: " + str(rooms.size()))

	for room_id in rooms.keys():
		var room = rooms[room_id]
		print("房间: " + room_id)
		print("  - 名称: " + room.get("name", ""))
		print("  - 坐标: " + str(room.get("coordinate", Vector2i.ZERO))
		print("  - 类型: " + room.get("type", "normal"))
		print("  - 区域: " + room.get("area", "unknown"))
		print("  - 出口: " + str(room.get("out", [])))
		print("  - 入口: " + str(room.get("in", [])))

	# 检查区域分组
	print("\n区域分组:")
	for area in map_mgr._area_rooms.keys():
		var area_rooms = map_mgr._area_rooms[area]
		print("  " + area + ": " + str(area_rooms))

	# 测试当前房间
	map_mgr.set_current_room("V01")
	print("\n当前房间: " + map_mgr.get_current_room_id())
	print("当前区域: " + map_mgr.get_current_area())

	# 测试区域房间获取
	var village_rooms = map_mgr.get_area_rooms("village")
	print("\n永宁村房间数: " + str(village_rooms.size()))

	quit()
