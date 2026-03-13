extends Node

const MAIN_MENU_SCENE := preload("res://scenes/ui/MainMenu.tscn")
const TEST_ARENA_SCENE := preload("res://scenes/world/TestArena.tscn")

var menu: Control
var current_arena: Node
var in_pause_menu := false


func _ready() -> void:
	menu = MAIN_MENU_SCENE.instantiate()
	add_child(menu)
	menu.start_requested.connect(_on_start_requested)
	menu.continue_requested.connect(_on_continue_requested)
	menu.exit_requested.connect(_on_exit_requested)
	_refresh_menu()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and current_arena != null:
		if menu.visible:
			_resume_game()
		else:
			_show_pause_menu()
		get_viewport().set_input_as_handled()


func _on_start_requested() -> void:
	GameState.new_game()
	_load_arena(GameState.get_continue_spawn_id())


func _on_continue_requested() -> void:
	if current_arena != null and menu.visible:
		_resume_game()
		return
	if not GameState.begin_continue():
		return
	_load_arena(GameState.get_continue_spawn_id())


func _on_exit_requested() -> void:
	get_tree().quit()


func _load_arena(spawn_id: String) -> void:
	get_tree().paused = false
	in_pause_menu = false
	if current_arena != null:
		current_arena.queue_free()
	var arena := TEST_ARENA_SCENE.instantiate()
	current_arena = arena
	add_child(arena)
	move_child(current_arena, 0)
	if current_arena.has_method("initialize_arena"):
		current_arena.initialize_arena(spawn_id)
	_refresh_menu()
	menu.hide()


func _show_pause_menu() -> void:
	if current_arena == null:
		return
	in_pause_menu = true
	get_tree().paused = true
	_refresh_menu()
	menu.show()


func _resume_game() -> void:
	in_pause_menu = false
	get_tree().paused = false
	menu.hide()
	_refresh_menu()


func _refresh_menu() -> void:
	var has_save := GameState.has_save_file()
	var can_resume := current_arena != null
	if menu.has_method("set_menu_state"):
		menu.set_menu_state(has_save, can_resume, in_pause_menu)
