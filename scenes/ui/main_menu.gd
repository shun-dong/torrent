extends Control

signal start_requested
signal continue_requested
signal exit_requested

@onready var title_label: Label = %TitleLabel
@onready var hint_label: Label = %HintLabel
@onready var continue_button: Button = %ContinueButton


func _ready() -> void:
	%StartButton.pressed.connect(func() -> void: start_requested.emit())
	continue_button.pressed.connect(func() -> void: continue_requested.emit())
	%ExitButton.pressed.connect(func() -> void: exit_requested.emit())


func set_menu_state(has_save: bool, can_resume: bool, paused: bool) -> void:
	title_label.text = "暂停" if paused else "Torrent Prototype"
	continue_button.disabled = not (has_save or can_resume)
	continue_button.text = "继续游戏" if paused and can_resume else "继续"
	hint_label.text = "第一轮骨架：俯视角移动、交互、轻攻击、弹反、雨眠存档。"
