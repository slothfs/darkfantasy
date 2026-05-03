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
@export var death_packed: PackedScene = preload ("res://scenes/effects/death.tscn")

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var sprite : Sprite2D = $Sprite2D

var facing_dir: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var is_dead: bool = false

var state: State = State.IDLE
var player: Node2D
var can_attack: bool = true

var patrol_target: Vector2 = Vector2.ZERO
var patrol_timer: float = 0.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	animation_tree.active = true
	_pick_patrol_point()
	
func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if player == null:
		return
		
	_update_state()
	_execute_state()
	_update_animation()
	
func _update_state() -> void:
	var dist = global_position.distance_to(player.global_position)
	
	if hitpoints < max_hitpoints * 0.25:
		state = State.RETREAT
		return
	
	if dist <= attack_range:
		state = State.ATTACK
	elif dist <= vision_distance:
		state = State.CHASE
	else:
		if state == State.CHASE:
			state = State.PATROL
			
func _execute_state() -> void:
	match state:
		State.IDLE:
			velocity = Vector2.ZERO
			move_and_slide()
			
		State.PATROL:
			_patrol()
			
		State.CHASE:
			_chase()
			
		State.ATTACK:
			_attack()
			
		State.RETREAT:
			_retreat()
			
func _patrol() -> void:
	var dir= (patrol_target - global_position)
	
	if dir.length() < 10:
		_pick_patrol_point()
		state = State.IDLE
		return
		
	velocity = dir.normalized() * move_speed
	move_and_slide()
	
func _pick_patrol_point() -> void:
	var offset = Vector2(
		randf_range(-patrol_radius , patrol_radius),
		randf_range(-patrol_radius, patrol_radius)
	)
	patrol_target = global_position + offset
	patrol_timer = randf_range(1.5, 3.0)
	
	
func _chase() -> void:
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * chase_speed
	move_and_slide()
	
	facing_dir = dir 
	
func _attack() -> void:
	if is_attacking:
		return
		
	is_attacking = true
	velocity = Vector2.ZERO
	move_and_slide()
	
	playback.travel("attack")
	
	await get_tree().create_timer(0.25).timeout
	
	
	if player and player.has_method("take_damage"):
		player.take_damage(attack_damage)
		
	await get_tree().create_timer(0.4).timeout
	
	is_attacking = false
	
func _retreat() -> void:
	var dir = (global_position - player.global_position).normalized()
	velocity = dir* retreat_speed
	move_and_slide()
	
	facing_dir
	
func _update_animation() -> void:
	if is_dead:
		playback.travel("death")
		return
		
	if is_attacking:
		playback.travel("attack")
		
	if velocity.length() > 5:
		playback.travel("run")
	else:
		playback.travel("idle")
	
	if velocity.length() > 0.1:
		facing_dir = velocity.normalized()
		
	sprite.flip_h = facing_dir.x < 0 
	sprite.flip_v = false
	
	animation_tree.set("parameters/idle/blend_position", facing_dir)
	animation_tree.set("parameters/run/blend_position", facing_dir)
	animation_tree.set("parameters/attack/blend_position", facing_dir)
	
func death() -> void:
	is_dead = true 
	state = State.DEAD
	velocity = Vector2.ZERO
	
	playback.travel("death")
	
	await get_tree().create_timer(0.8).timeout
	
	if death_packed:
		var fx = death_packed.instantiate()
		fx.global_position = global_position
		get_tree().current_scene.add_child(fx)
		
	queue_free()
	
	


	
	
	
	
	
	
	
	
	
	
	
	
