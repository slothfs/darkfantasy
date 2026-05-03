extends Node2D

@onready var collect_area: Area2D = $Collect

func _ready() -> void:
	collect_area.body_entered.connect(_on_collect_body_entered)

func _on_collect_body_entered(body: Node2D) -> void:
	if body.is_in_group("player(scene)") or body.name == "Player":
		body.has_key = true
		AudioController.play_key()
		
		# Assuming KeyNotify is in the same level scene, we can find it
		var key_notify = get_tree().current_scene.get_node_or_null("KeyNotify")
		if key_notify:
			key_notify.visible = true
			
		# Enable door collision
		var door = get_tree().current_scene.get_node_or_null("Door")
		if door:
			var door_col = door.get_node_or_null("CollisionShape2D")
			if door_col:
				door_col.set_deferred("disabled", false)
				
		queue_free()
