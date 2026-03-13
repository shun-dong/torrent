extends SceneTree

const MAIN_SCENE := preload("res://scenes/main/Main.tscn")


func _initialize() -> void:
	GameState.new_game()
	var main := MAIN_SCENE.instantiate()
	root.add_child(main)
	await process_frame
	main._on_start_requested()
	await process_frame
	await process_frame
	var arena = main.current_arena
	assert(arena != null, "Main scene did not create the arena")
	var player = arena.player
	assert(player != null, "Arena did not create the player")
	assert(GameState.design_data.get("operations", {}).has("A1"), "Operation data was not loaded")
	assert(GameState.initial_equipment.get("weapon", {}).get("id", "") == "IT_W01", "Initial weapon mapping missing")
	player.begin_parry()
	var enemy = arena.get_node("Actors/RainSporeRemnant")
	enemy.global_position = player.global_position + Vector2(18, 0)
	enemy._resolve_attack()
	assert(player.health == player.max_health, "Parry window did not block enemy attack")
	enemy.receive_hit(enemy.health, player.global_position)
	assert(GameState.karma >= 1, "Enemy defeat did not increase karma")
	GameState.record_rainsleep("shelter", player.capture_state())
	assert(GameState.get_continue_spawn_id() == "shelter", "Checkpoint save did not update")
	quit(0)
