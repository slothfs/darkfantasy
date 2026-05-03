extends Area2D

@export var alert_scene: PackedScene = preload("res://scenes/door_alert.tscn")
var current_alert: Node = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player(scene)") or body.name == "Player":
		if body.get("has_key") == true:
			call_deferred("_transition_level")
		else:
			_show_alert()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player(scene)") or body.name == "Player":
		_hide_alert()

func _show_alert() -> void:
	if not current_alert and alert_scene:
		current_alert = alert_scene.instantiate()
		if get_tree().current_scene:
			get_tree().current_scene.add_child(current_alert)

func _hide_alert() -> void:
	if current_alert:
		current_alert.queue_free()
		current_alert = null

func _transition_level() -> void:
	AudioController.play_door()
	var next_level = "res://scenes/levels/level_3.tscn"
	if ResourceLoader.exists(next_level):
		Fade.transition_to_scene(next_level)
	else:
		print("Next level not found, restarting current level.")
		Fade.transition_to_scene(get_tree().current_scene.scene_file_path)
