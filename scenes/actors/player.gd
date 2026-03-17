extends CharacterBody2D

signal interaction_prompt_changed(text: String, visible: bool)
signal died

const FRAME_SIZE := Vector2i(32, 32)

@export var move_speed := 95.0
@export var max_health := 5
@export var max_stamina := 100.0
@export var stamina_recovery_rate := 22.0
@export var parry_cost := 25.0
@export var attack_damage := 1

var health := 5
var stamina := 100.0
var spirit := 0
var facing := Vector2.DOWN
var facing_key := "down"
var current_state := "idle"
var state_timer := 0.0
var attack_resolved := false
var nearby_interactable: Interactable

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var interaction_area: Area2D = $InteractionArea


func _ready() -> void:
	add_to_group("player")
	print("[Player] Ready, collision layer: ", collision_layer)
	health = max_health
	stamina = max_stamina
	_build_frames()
	_play_movement_animation(Vector2.ZERO)
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)
	_update_attack_transform()


func _physics_process(delta: float) -> void:
	if current_state == "dead":
		return
	_process_state(delta)
	if current_state in ["idle", "move"]:
		_handle_movement()
		_handle_actions()
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	if current_state != "parry":
		stamina = min(max_stamina, stamina + stamina_recovery_rate * delta)
	GameState.update_player_state(capture_state())


func _handle_movement() -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector != Vector2.ZERO:
		facing = input_vector.normalized()
		facing_key = _facing_key_from_vector(facing)
		current_state = "move"
		velocity = facing * move_speed
	else:
		current_state = "idle"
		velocity = Vector2.ZERO
	_play_movement_animation(input_vector)
	_update_attack_transform()


func _handle_actions() -> void:
	if Input.is_action_just_pressed("interact") and nearby_interactable != null:
		nearby_interactable.interact()
	if Input.is_action_just_pressed("light_attack"):
		begin_attack()
	elif Input.is_action_just_pressed("parry"):
		begin_parry()


func _process_state(delta: float) -> void:
	if current_state in ["attack", "parry", "hurt", "dead"]:
		state_timer -= delta
	if current_state == "attack":
		if not attack_resolved and state_timer <= 0.15:
			_resolve_attack()
		if state_timer <= 0.0:
			current_state = "idle"
			attack_resolved = false
	elif current_state == "parry" and state_timer <= 0.0:
		current_state = "idle"
	elif current_state == "hurt" and state_timer <= 0.0:
		current_state = "idle"


func begin_attack() -> void:
	if current_state not in ["idle", "move"]:
		return
	current_state = "attack"
	state_timer = 0.28
	attack_resolved = false
	sprite.flip_h = facing.x > 0.0
	sprite.play(_animation_key("attack"))


func begin_parry() -> bool:
	if current_state not in ["idle", "move"]:
		return false
	if stamina < parry_cost:
		return false
	stamina -= parry_cost
	current_state = "parry"
	state_timer = 0.22
	sprite.flip_h = facing.x > 0.0
	sprite.play(_animation_key("hurt"))
	return true


func can_parry_attack(attacker_position: Vector2) -> bool:
	if current_state != "parry" or state_timer <= 0.0:
		return false
	var to_attacker := (attacker_position - global_position).normalized()
	return to_attacker.dot(facing.normalized()) >= -0.25


func receive_damage(amount: int, from_position: Vector2) -> void:
	if current_state == "dead":
		return
	# Check for god mode
	var debug_manager := get_tree().get_first_node_in_group("debug_manager")
	if debug_manager != null and debug_manager.god_mode:
		return
	if can_parry_attack(from_position):
		return
	health -= amount
	if health <= 0:
		health = 0
		current_state = "dead"
		state_timer = 0.8
		sprite.play(_animation_key("death"))
		died.emit()
		return
	current_state = "hurt"
	state_timer = 0.25
	facing = (global_position - from_position).normalized()
	facing_key = _facing_key_from_vector(facing)
	sprite.flip_h = facing.x > 0.0
	sprite.play(_animation_key("hurt"))


func capture_state() -> Dictionary:
	return {
		"health": health,
		"max_health": max_health,
		"stamina": stamina,
		"max_stamina": max_stamina,
		"spirit": spirit,
	}


func apply_state(snapshot: Dictionary) -> void:
	health = int(snapshot.get("health", max_health))
	max_health = int(snapshot.get("max_health", max_health))
	stamina = float(snapshot.get("stamina", max_stamina))
	max_stamina = float(snapshot.get("max_stamina", max_stamina))
	spirit = int(snapshot.get("spirit", 0))


func restore_resources() -> void:
	health = max_health
	stamina = max_stamina


func _resolve_attack() -> void:
	attack_resolved = true
	for body in attack_area.get_overlapping_bodies():
		if body.has_method("receive_hit"):
			body.receive_hit(attack_damage, global_position)


func _facing_key_from_vector(vector: Vector2) -> String:
	if absf(vector.x) > absf(vector.y):
		return "side"
	return "up" if vector.y < 0.0 else "down"


func _animation_key(action: String) -> String:
	return "%s_%s" % [facing_key, action]


func _play_movement_animation(input_vector: Vector2) -> void:
	sprite.flip_h = facing.x > 0.0
	if current_state == "attack" or current_state == "hurt" or current_state == "dead":
		return
	if input_vector == Vector2.ZERO:
		sprite.play(_animation_key("idle"))
	else:
		sprite.play(_animation_key("walk"))


func _update_attack_transform() -> void:
	attack_area.position = facing.normalized() * 20.0
	attack_area.scale = Vector2.ONE


func _build_frames() -> void:
	var frames := SpriteFrames.new()
	_add_sheet_animation(frames, "down_idle", "res://asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/D_Idle.png")
	_add_sheet_animation(frames, "down_walk", "res://asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/D_Walk.png")
	_add_sheet_animation(frames, "down_attack", "res://asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/D_Attack.png")
	_add_sheet_animation(frames, "down_hurt", "res://asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/D_Hurt.png")
	_add_sheet_animation(frames, "down_death", "res://asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/D_Death.png")
	_add_sheet_animation(frames, "side_idle", "res://asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/S_Idle.png")
	_add_sheet_animation(frames, "side_walk", "res://asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/S_Walk.png")
	_add_sheet_animation(frames, "side_attack", "res://asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/S_Attack.png")
	_add_sheet_animation(frames, "side_hurt", "res://asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/S_Hurt.png")
	_add_sheet_animation(frames, "side_death", "res://asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/S_Death.png")
	_add_sheet_animation(frames, "up_idle", "res://asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/U_Idle.png")
	_add_sheet_animation(frames, "up_walk", "res://asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/U_Walk.png")
	_add_sheet_animation(frames, "up_attack", "res://asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/U_Attack.png")
	_add_sheet_animation(frames, "up_hurt", "res://asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/U_Hurt.png")
	_add_sheet_animation(frames, "up_death", "res://asserts/third_party/Top-Down_Roguelike_Game_Kit_Pixel_Art/1 Characters/1/U_Death.png")
	sprite.sprite_frames = frames


func _add_sheet_animation(frames: SpriteFrames, animation_name: String, texture_path: String) -> void:
	var texture: Texture2D = load(texture_path)
	var frame_count := int(texture.get_width() / float(FRAME_SIZE.x))
	frames.add_animation(animation_name)
	frames.set_animation_loop(animation_name, animation_name.ends_with("idle") or animation_name.ends_with("walk"))
	frames.set_animation_speed(animation_name, 10.0 if animation_name.ends_with("walk") else 8.0)
	for frame_index in frame_count:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2i(frame_index * FRAME_SIZE.x, 0, FRAME_SIZE.x, FRAME_SIZE.y)
		frames.add_frame(animation_name, atlas)


func _on_interaction_area_entered(area: Area2D) -> void:
	print("[Player] Area entered: ", area.name, " class: ", area.get_class())
	print("[Player] Area script: ", area.get_script())
	if area is Interactable:
		print("[Player] Is Interactable: ", area.prompt_text)
		nearby_interactable = area
		interaction_prompt_changed.emit(area.prompt_text, true)
	else:
		print("[Player] Not an Interactable")


func _on_interaction_area_exited(area: Area2D) -> void:
	print("[Player] Interaction area exited: ", area.name)
	if area == nearby_interactable:
		nearby_interactable = null
		interaction_prompt_changed.emit("", false)
