class_name EventExecutorBase
extends Node

func execute(event_data: Dictionary, content: Dictionary, on_complete: Callable) -> void:
	push_error("execute() must be implemented by subclass")
