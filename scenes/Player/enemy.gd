extends CharacterBody2D

@export_category("Stats")
@export var hitpoints: int = 180
@export_category("Realted Scenes")
@export var death_packed: PackedScene = preload("res://scenes/effects/death.tscn")


func take_damage(damage_taken: int) -> void:
	hitpoints -= damage_taken
	if hitpoints <= 0:
		death()
		
		
func death() -> void:
	if death_packed:
		var death_scene: Node2D = death_packed.instantiate()
		death_scene.position = global_position + Vector2(0.0, -32.0)
		var parent = get_parent()
		if parent and parent.name == "Enemies":
			parent.add_child(death_scene)
		else:
			get_tree().current_scene.add_child(death_scene)
	queue_free()
