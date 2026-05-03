extends CharacterBody2D

enum State {
	IDLE,
	CHASE,
	ATTACK,
	RETREAT,
	DEAD
}

@export_category("Stats")
@export var hitpoints: int = 200
@export var max_hitpoints: int = 200
@export var move_speed: float = 150.0
@export var retreat_speed: float = 220.0
@export var attack_damage: int = 25
@export var heal_amount: int = 15

@export_category("AI")
@export var vision_distance: float = 500.0
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.0
@export var retreat_health_percent: float = 0.25
@export var return_health_percent: float = 0.60

@export_category("Realted Scenes")
@export var death_packed: PackedScene = preload("res://scenes/effects/death.tscn")

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var sprite: Sprite2D = $Sprite2D

var state: State = State.IDLE
var player: Node2D = null
var is_attacking: bool = false
var is_dead: bool = false
var is_healing: bool = false
var facing_dir: Vector2 = Vector2.RIGHT


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	animation_tree.active = true


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)

	if state != State.RETREAT and hitpoints <= max_hitpoints * retreat_health_percent:
		state = State.RETREAT
		
		# Disappear for 1 sec to evade, but stay killable
		sprite.visible = false
		await get_tree().create_timer(1.0).timeout
		
		if is_instance_valid(sprite) and not is_dead:
			sprite.visible = true
			hitpoints = mini(hitpoints + 50, max_hitpoints)
			state = State.CHASE

	match state:
		State.IDLE:
			if distance <= vision_distance:
				state = State.CHASE

			velocity = Vector2.ZERO
			move_and_slide()
			playback.travel("idle")

		State.CHASE:
			if distance <= attack_range:
				state = State.ATTACK

			var dir = (player.global_position - global_position).normalized()
			velocity = dir * move_speed
			move_and_slide()

			facing_dir = dir
			sprite.flip_h = facing_dir.x < 0
			playback.travel("run")

			animation_tree.set("parameters/run/blend_position", facing_dir)
			animation_tree.set("parameters/idle/blend_position", facing_dir)

		State.ATTACK:
			if distance > attack_range:
				state = State.CHASE

			velocity = Vector2.ZERO
			move_and_slide()

			if not is_attacking:
				attack()

		State.RETREAT:
			var dir = (global_position - player.global_position).normalized()
			velocity = dir * retreat_speed
			move_and_slide()

			facing_dir = dir
			sprite.flip_h = facing_dir.x < 0
			playback.travel("run")

			animation_tree.set("parameters/run/blend_position", facing_dir)
			animation_tree.set("parameters/idle/blend_position", facing_dir)


func start_healing() -> void:
	if is_healing:
		return

	is_healing = true

	while state == State.RETREAT and not is_dead:
		await get_tree().create_timer(1.5).timeout

		if state != State.RETREAT:
			break

		hitpoints += heal_amount

		if hitpoints > max_hitpoints:
			hitpoints = max_hitpoints


func attack() -> void:
	is_attacking = true

	playback.travel("attack")
	animation_tree.set("parameters/attack/BlendSpace2D/blend_position", facing_dir)

	await get_tree().create_timer(0.25).timeout

	if player and player.has_method("take_damage"):
		player.take_damage(attack_damage)

	await get_tree().create_timer(attack_cooldown).timeout

	is_attacking = false


func take_damage(amount: int) -> void:
	if is_dead:
		return

	hitpoints -= amount

	playback.travel("hurt")

	if hitpoints <= 0:
		death()


func death() -> void:
	is_dead = true
	state = State.DEAD
	velocity = Vector2.ZERO
	is_healing = false

	playback.travel("death")

	await get_tree().create_timer(0.8).timeout

	if death_packed:
		var fx = death_packed.instantiate()
		fx.global_position = global_position
		get_tree().current_scene.add_child(fx)

	queue_free()
