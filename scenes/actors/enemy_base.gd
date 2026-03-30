extends CharacterBody2D

signal defeated(enemy_id: String)

const FRAME_SIZE := Vector2i(32, 32)

@export var enemy_id := "EN_G01"
@export var enemy_asset_id := "4"  # 素材包中的敌人编号 (1-4)
@export var move_speed := 40.0
@export var max_health := 3
@export var attack_damage := 1
@export var detection_radius := 120.0
@export var attack_radius := 26.0

var health := 3
var current_state := "idle"
var facing := Vector2.DOWN
var facing_key := "down"
var state_timer := 0.0
var attack_resolved := false
var player: Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	_build_frames()
	sprite.play("down_idle")


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
	if current_state == "hurt" and state_timer <= 0.0:
		current_state = "idle"
	if current_state == "stagger" and state_timer <= 0.0:
		current_state = "idle"
	if current_state == "windup":
		velocity = Vector2.ZERO
		sprite.flip_h = facing.x > 0.0
		sprite.play(_animation_key("attack"))
		if state_timer <= 0.0:
			current_state = "attack"
			state_timer = 0.18
			attack_resolved = false
	elif current_state == "attack":
		velocity = Vector2.ZERO
		if not attack_resolved and state_timer <= 0.1:
			_resolve_attack()
		if state_timer <= 0.0:
			current_state = "idle"
	elif current_state in ["hurt", "stagger"]:
		velocity = Vector2.ZERO
	else:
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


func receive_hit(amount: int, from_position: Vector2) -> void:
	if current_state == "dead":
		return
	health -= amount
	if health <= 0:
		_die()
		return
	facing = (global_position - from_position).normalized()
	facing_key = _facing_key_from_vector(facing)
	current_state = "hurt"
	state_timer = 0.3
	sprite.flip_h = facing.x > 0.0
	sprite.play(_animation_key("hurt"))


func on_parried() -> void:
	current_state = "stagger"
	state_timer = 0.6
	sprite.flip_h = facing.x > 0.0
	sprite.play(_animation_key("hurt"))


func _resolve_attack() -> void:
	attack_resolved = true
	if player == null or not is_instance_valid(player):
		return
	if player.global_position.distance_to(global_position) > attack_radius + 8.0:
		return
	if player.has_method("can_parry_attack") and player.can_parry_attack(global_position):
		on_parried()
		return
	player.receive_damage(attack_damage, global_position)


func _die() -> void:
	current_state = "dead"
	velocity = Vector2.ZERO
	sprite.flip_h = facing.x > 0.0
	sprite.play(_animation_key("death"))
	var karma_value := GameState.get_enemy_karma(enemy_id)
	GameState.add_karma_temp(karma_value)
	defeated.emit(enemy_id)
	set_physics_process(false)
	await get_tree().create_timer(0.35).timeout
	queue_free()


func _facing_key_from_vector(vector: Vector2) -> String:
	if absf(vector.x) > absf(vector.y):
		return "side"
	return "up" if vector.y < 0.0 else "down"


func _animation_key(action: String) -> String:
	return "%s_%s" % [facing_key, action]


func _build_frames() -> void:
	var frames := SpriteFrames.new()
	var base_path := "res://asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/3 Dungeon Enemies/%s" % enemy_asset_id
	_add_sheet_animation(frames, "down_idle", "%s/D_Idle.png" % base_path)
	_add_sheet_animation(frames, "down_walk", "%s/D_Walk.png" % base_path)
	_add_sheet_animation(frames, "down_attack", "%s/D_Attack.png" % base_path)
	_add_sheet_animation(frames, "down_hurt", "%s/D_Hurt.png" % base_path)
	_add_sheet_animation(frames, "down_death", "%s/D_Death.png" % base_path)
	_add_sheet_animation(frames, "side_idle", "%s/S_Idle.png" % base_path)
	_add_sheet_animation(frames, "side_walk", "%s/S_Walk.png" % base_path)
	_add_sheet_animation(frames, "side_attack", "%s/S_Attack.png" % base_path)
	_add_sheet_animation(frames, "side_hurt", "%s/S_Hurt.png" % base_path)
	_add_sheet_animation(frames, "side_death", "%s/S_Death.png" % base_path)
	_add_sheet_animation(frames, "up_idle", "%s/U_Idle.png" % base_path)
	_add_sheet_animation(frames, "up_walk", "%s/U_Walk.png" % base_path)
	_add_sheet_animation(frames, "up_attack", "%s/U_Attack.png" % base_path)
	_add_sheet_animation(frames, "up_hurt", "%s/U_Hurt.png" % base_path)
	_add_sheet_animation(frames, "up_death", "%s/U_Death.png" % base_path)
	sprite.sprite_frames = frames


func _add_sheet_animation(frames: SpriteFrames, animation_name: String, texture_path: String) -> void:
	var texture: Texture2D = load(texture_path)
	var frame_count := int(texture.get_width() / float(FRAME_SIZE.x))
	frames.add_animation(animation_name)
	frames.set_animation_loop(animation_name, animation_name.ends_with("idle") or animation_name.ends_with("walk"))
	frames.set_animation_speed(animation_name, 8.0)
	for frame_index in frame_count:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2i(frame_index * FRAME_SIZE.x, 0, FRAME_SIZE.x, FRAME_SIZE.y)
		frames.add_frame(animation_name, atlas)
