extends Control

func _on_a_1_pressed() -> void:
	AudioController.play_button()
	Fade.transition_to_scene("res://scenes/levels/level_1.tscn")

func _on_a_2_pressed() -> void:
	AudioController.play_button()
	Fade.transition_to_scene("res://scenes/levels/level_2.tscn")

func _on_a_3_pressed() -> void:
	AudioController.play_button()
	Fade.transition_to_scene("res://scenes/levels/level_3.tscn")

func _on_a_4_pressed() -> void:
	AudioController.play_button()
	Fade.transition_to_scene("res://scenes/levels/level_4.tscn")

func _on_a_5_pressed() -> void:
	AudioController.play_button()
	Fade.transition_to_scene("res://scenes/levels/level_4.tscn")

func _on_a_6_pressed() -> void:
	AudioController.play_button()
	Fade.transition_to_scene("res://scenes/levels/level_4.tscn")
