extends "res://scenes/actors/enemy_base.gd"

var explosion_windup := 1.0  # 1 second delay before explosion
var explosion_radius := 50.0  # AOE radius
var is_winding_up := false

func _ready() -> void:
	enemy_id = "EN_G02"
	enemy_asset_id = "2"  # 雨虫群使用素材2
	max_health = 1  # HP极低
	attack_damage = 2  # 爆裂伤害较高
	move_speed = 20  # 移动缓慢
	super._ready()


func _physics_process(delta: float) -> void:
	if current_state == "dead":
		return
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	state_timer = max(state_timer - delta, 0.0)
	var to_player := player.global_position - global_position
	if to_player != Vector2.ZERO:
		facing = to_player.normalized()
		facing_key = _facing_key_from_vector(facing)

	# Handle hurt/stagger recovery
	if current_state == "hurt" and state_timer <= 0.0:
		current_state = "idle"
		is_winding_up = false
	if current_state == "stagger" and state_timer <= 0.0:
		current_state = "idle"
		is_winding_up = false

	# Handle explosion windup
	if current_state == "explode_windup":
		velocity = Vector2.ZERO
		# Flash effect using modulate
		var flash_speed := 10.0
		sprite.modulate = Color(1.0, 0.5 + 0.5 * sin(Time.get_time_dict_from_system()["second"] * flash_speed), 0.5, 1.0)
		if state_timer <= 0.0:
			_explode()
		return

	if current_state in ["hurt", "stagger"]:
		velocity = Vector2.ZERO
	elif current_state == "attack":
		velocity = Vector2.ZERO
	else:
		# Check distance to player
		var dist := to_player.length()
		if dist <= attack_radius and not is_winding_up:
			# Start explosion windup
			current_state = "explode_windup"
			state_timer = explosion_windup
			is_winding_up = true
			velocity = Vector2.ZERO
			sprite.flip_h = facing.x > 0.0
			sprite.play(_animation_key("hurt"))  # Use hurt animation as windup visual
		elif dist <= detection_radius:
			current_state = "move"
			is_winding_up = false
			velocity = to_player.normalized() * move_speed
			sprite.flip_h = facing.x > 0.0
			sprite.play(_animation_key("walk"))
		else:
			current_state = "idle"
			is_winding_up = false
			velocity = Vector2.ZERO
			sprite.flip_h = facing.x > 0.0
			sprite.play(_animation_key("idle"))

	move_and_slide()


func _explode() -> void:
	# Deal AOE damage to player
	if player != null and is_instance_valid(player):
		var dist_to_player := player.global_position.distance_to(global_position)
		if dist_to_player <= explosion_radius:
			player.receive_damage(attack_damage, global_position)

	# Visual effect - flash white then die
	sprite.modulate = Color.WHITE
	# Self-destruct
	current_state = "dead"
	var karma_value := GameState.get_enemy_karma(enemy_id)
	GameState.add_karma_temp(karma_value)
	defeated.emit(enemy_id)
	set_physics_process(false)
	queue_free()


func receive_hit(amount: int, from_position: Vector2) -> void:
	# If hit during windup, cancel explosion and take damage normally
	if current_state == "explode_windup":
		is_winding_up = false
		sprite.modulate = Color.WHITE
	super.receive_hit(amount, from_position)


func _die() -> void:
	current_state = "dead"
	velocity = Vector2.ZERO
	sprite.modulate = Color.WHITE
	sprite.flip_h = facing.x > 0.0
	sprite.play(_animation_key("death"))
	var karma_value := GameState.get_enemy_karma(enemy_id)
	GameState.add_karma_temp(karma_value)
	defeated.emit(enemy_id)
	set_physics_process(false)
	await get_tree().create_timer(0.35).timeout
	queue_free()
