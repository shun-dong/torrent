extends CanvasLayer

# Debug Manager - Singleton for debug functionality
# Features:
# - F1: Teleport menu
# - F2: God mode toggle
# - F3: Kill all enemies
# - F4: Quick death

const SCENE_PATHS := {
	"V01": "res://scenes/world/V01_Home.tscn",
	"V02": "res://scenes/world/V02_VillageRoad.tscn",
	"V03": "res://scenes/world/V03_VillageSquare.tscn",
	"V04": "res://scenes/world/V04_VillageGate.tscn",
	"G01": "res://scenes/world/G01_OutskirtsEntry.tscn",
	"G02": "res://scenes/world/G02_DrainageDitch.tscn",
	"G03": "res://scenes/world/G03_AbandonedFarm.tscn",
	"S01": "res://scenes/world/S01_Shelter.tscn",
	"test_arena": "res://scenes/world/TestArena.tscn",
}

const ROOM_NAMES := {
	"V01": "采薇的家",
	"V02": "村路",
	"V03": "村会场",
	"V04": "村外栅栏",
	"G01": "郊区入口",
	"G02": "排水沟",
	"G03": "废弃农道",
	"S01": "小型避难所",
	"test_arena": "测试场",
}

var god_mode := false
var teleport_menu_visible := false

@onready var teleport_panel: Panel = $TeleportPanel
@onready var room_list: VBoxContainer = $TeleportPanel/ScrollContainer/RoomList
@onready var current_room_label: Label = $TeleportPanel/CurrentRoomLabel
@onready var debug_info: Label = $DebugInfo


func _ready() -> void:
	add_to_group("debug_manager")
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_teleport_menu()
	_update_debug_info()
	# Ensure UI is on top
	layer = 100


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and teleport_menu_visible:
		_hide_teleport_menu()
		return

	if not event is InputEventKey or not event.pressed:
		return

	match event.keycode:
		KEY_F1:
			_toggle_teleport_menu()
		KEY_F2:
			_toggle_god_mode()
		KEY_F3:
			_kill_all_enemies()
		KEY_F4:
			_trigger_quick_death()


func _toggle_teleport_menu() -> void:
	if teleport_menu_visible:
		_hide_teleport_menu()
	else:
		_show_teleport_menu()


func _show_teleport_menu() -> void:
	teleport_menu_visible = true
	_build_teleport_menu()  # Rebuild to update current room
	teleport_panel.show()
	teleport_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	current_room_label.text = "当前: %s (%s)" % [GameState.current_scene_id, ROOM_NAMES.get(GameState.current_scene_id, "未知")]
	get_tree().paused = true


func _hide_teleport_menu() -> void:
	teleport_menu_visible = false
	teleport_panel.hide()
	get_tree().paused = false


func _build_teleport_menu() -> void:
	# Clear existing buttons
	for child in room_list.get_children():
		child.queue_free()

	# Create header
	var header := Label.new()
	header.text = "选择传送目的地:"
	header.add_theme_font_size_override("font_size", 18)
	room_list.add_child(header)

	# Create buttons for each room
	for room_id in SCENE_PATHS.keys():
		var button := Button.new()
		button.text = "%s - %s" % [room_id, ROOM_NAMES.get(room_id, "未知")]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_on_teleport_button_pressed.bind(room_id))
		# Ensure buttons work while paused
		button.process_mode = Node.PROCESS_MODE_ALWAYS

		# Highlight current room
		if room_id == GameState.current_scene_id:
			button.text += " [当前]"
			button.modulate = Color(0.7, 1.0, 0.7)

		room_list.add_child(button)

	# Add close button
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	room_list.add_child(spacer)

	var close_button := Button.new()
	close_button.text = "关闭 (ESC)"
	close_button.process_mode = Node.PROCESS_MODE_ALWAYS
	close_button.pressed.connect(_hide_teleport_menu)
	room_list.add_child(close_button)


func _on_teleport_button_pressed(room_id: String) -> void:
	_hide_teleport_menu()
	call_deferred("_teleport_to_room", room_id)


func _teleport_to_room(room_id: String) -> void:
	if not SCENE_PATHS.has(room_id):
		push_error("Unknown room: " + room_id)
		return

	print("[Debug] Teleporting to: ", room_id)
	GameState.current_scene_id = room_id

	var main := get_tree().get_first_node_in_group("main")
	if main != null and main.has_method("_load_arena"):
		main._load_arena("start")


func _toggle_god_mode() -> void:
	god_mode = not god_mode
	print("[Debug] God mode: ", "ON" if god_mode else "OFF")
	_update_debug_info()

	var player := get_tree().get_first_node_in_group("player")
	if player != null and god_mode:
		# Restore full health in god mode
		if player.has_method("restore_resources"):
			player.restore_resources()


func _trigger_quick_death() -> void:
	print("[Debug] Quick death triggered")
	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("receive_damage"):
		# Check if player is already dead
		if player.current_state == "dead":
			print("[Debug] Player already dead")
			return
		player.receive_damage(999, Vector2.ZERO)


func _kill_all_enemies() -> void:
	print("[Debug] Killing all enemies")
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("receive_hit"):
			enemy.receive_hit(999, Vector2.ZERO)


func _update_debug_info() -> void:
	var status := []
	status.append("Debug Mode")
	status.append("F1:传送 F2:无敌[%s] F3:清敌 F4:死亡" % ["ON" if god_mode else "OFF"])
	debug_info.text = " | ".join(status)


func _process(_delta: float) -> void:
	# Ensure god mode keeps player at full health
	if god_mode:
		var player := get_tree().get_first_node_in_group("player")
		if player != null and player.has_method("restore_resources"):
			player.restore_resources()
