extends CharacterBody2D

enum State {
	IDLE,
	RUN,
	WALK,
	ATTACK,
	DEAD
}

@export_category("Stats")
@export var hitpoints: int = 50
@export var run_speed: float = 180.0
@export var walk_speed: float = 90.0
@export var attack_damage: int = 50
@export var vision_distance: float = 500.0
@export var attack_range: float = 45.0
@export var attack_cooldown: float = 1.0
@export var knockback_force: float = 350.0

var state: State = State.IDLE
var player: Node2D = null
var is_attacking: bool = false
var is_dead: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance > vision_distance:
		state = State.IDLE
	elif distance > vision_distance * 0.5:
		state = State.RUN
	elif distance > attack_range:
		state = State.WALK
	else:
		state = State.ATTACK

	match state:
		State.IDLE:
			velocity = Vector2.ZERO
			move_and_slide()
			play_anim("idle")

		State.RUN:
			move_toward_player(run_speed, "run")

		State.WALK:
			move_toward_player(walk_speed, "walk")

		State.ATTACK:
			velocity = Vector2.ZERO
			move_and_slide()

			if not is_attacking:
				attack()


func move_toward_player(speed: float, anim: String) -> void:
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()

	animated_sprite.flip_h = dir.x < 0
	play_anim(anim)


func play_anim(anim: String) -> void:
	if animated_sprite.animation != anim:
		animated_sprite.play(anim)


func attack() -> void:
	is_attacking = true

	play_anim("hurt")

	await get_tree().create_timer(0.2).timeout

	if player and player.has_method("take_damage"):
		player.take_damage(attack_damage)

		var push_dir = (player.global_position - global_position).normalized()

		if player.has_method("apply_knockback"):
			player.apply_knockback(push_dir * knockback_force)

	await get_tree().create_timer(attack_cooldown).timeout

	is_attacking = false


func take_damage(amount: int) -> void:
	if is_dead:
		return

	hitpoints -= amount

	play_anim("hurt")

	if hitpoints <= 0:
		death()


func death() -> void:
	is_dead = true
	state = State.DEAD
	velocity = Vector2.ZERO

	queue_free()
