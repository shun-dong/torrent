extends "res://scenes/actors/enemy_base.gd"

var retreat_speed := 120.0  # 后撤速度更快
var retreat_duration := 0.5  # 后撤持续时间
var retreat_timer := 0.0

func _ready() -> void:
	enemy_id = "EN_G03"
	enemy_asset_id = "3"  # 湿壳拾荒鼠使用素材3
	max_health = 2  # HP较低
	move_speed = 70  # 速度较快
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
	if current_state == "stagger" and state_timer <= 0.0:
		current_state = "idle"

	# Handle windup -> attack transition
	if current_state == "windup":
		velocity = Vector2.ZERO
		sprite.flip_h = facing.x > 0.0
		sprite.play(_animation_key("attack"))
		if state_timer <= 0.0:
			current_state = "attack"
			state_timer = 0.18
			attack_resolved = false
		return

	# Handle attack -> retreat transition
	if current_state == "attack":
		velocity = Vector2.ZERO
		if not attack_resolved and state_timer <= 0.1:
			_resolve_attack()
		if state_timer <= 0.0:
			# Attack finished, start retreat
			current_state = "retreat"
			retreat_timer = retreat_duration
			# Calculate retreat direction (away from player)
			var retreat_dir := -facing.normalized()
			velocity = retreat_dir * retreat_speed
			sprite.flip_h = retreat_dir.x > 0.0
			sprite.play(_animation_key("walk"))
		return

	# Handle retreat state
	if current_state == "retreat":
		retreat_timer -= delta
		# Continue moving backward
		var retreat_dir := -facing.normalized()
		velocity = retreat_dir * retreat_speed
		sprite.flip_h = retreat_dir.x > 0.0
		if retreat_timer <= 0.0:
			current_state = "idle"
			velocity = Vector2.ZERO
		return

	if current_state in ["hurt", "stagger"]:
		velocity = Vector2.ZERO
	else:
		# Normal AI - chase and attack
		if to_player.length() <= attack_radius:
			current_state = "windup"
			state_timer = 0.35
		elif to_player.length() <= detection_radius:
			current_state = "move"
			velocity = to_player.normalized() * move_speed
			sprite.flip_h = facing.x > 0.0
			sprite.play(_animation_key("walk"))
		else:
			current_state = "idle"
			velocity = Vector2.ZERO
			sprite.flip_h = facing.x > 0.0
			sprite.play(_animation_key("idle"))

	move_and_slide()
