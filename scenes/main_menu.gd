extends Control

func _ready() -> void:
	$Play.pressed.connect(_on_play_pressed)
	$Levels.pressed.connect(_on_levels_pressed)

func _on_play_pressed() -> void:
	AudioController.play_button()
	Fade.transition_to_scene("res://scenes/levels/level_1.tscn")

func _on_levels_pressed() -> void:
	AudioController.play_button()
	Fade.transition_to_scene("res://scenes/level_menu.tscn")
