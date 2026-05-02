extends CharacterBody2D

enum State {
	IDLE,
	PATROL,
	CHASE,
	ATTACK,
	RETREAT,
	DEAD
}

@export_category("Stats")
@export var hitpoints: int = 200
@export var max_hitpoints: int = 200
@export var move_speed: float = 90.0
@export var chase_speed: float = 140.0
@export var retreat_speed: float = 170.0
@export var attack_damage: int = 25

@export_category("Ai")
@export var vision_distance: float = 260.0
@export var attack_range: float = 45.0
@export var attack_cooldown: float = 1.0
@export var patrol_radius: float = 180.0

@export_category("Related Scenes")
@export var death_packed: Packed
