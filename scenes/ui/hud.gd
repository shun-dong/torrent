extends CanvasLayer

var player: Node

@onready var health_bar: ProgressBar = %HealthBar
@onready var stamina_bar: ProgressBar = %StaminaBar
@onready var prompt_label: Label = %PromptLabel
@onready var status_label: Label = %StatusLabel
@onready var message_label: Label = %MessageLabel


func bind_player(target: Node) -> void:
	player = target
	_update_bars()


func set_prompt(text: String, show_prompt: bool) -> void:
	prompt_label.text = text
	prompt_label.visible = show_prompt


func show_status(text: String) -> void:
	message_label.text = text


func _process(_delta: float) -> void:
	_update_bars()
	status_label.text = "业 %d  |  精神 %d" % [GameState.karma, int(GameState.current_player_state.get("spirit", 0))]


func _update_bars() -> void:
	if player == null:
		return
	health_bar.max_value = player.max_health
	health_bar.value = player.health
	stamina_bar.max_value = player.max_stamina
	stamina_bar.value = player.stamina
