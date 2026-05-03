extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")


func _on_levels_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_menu.tscn")
	
