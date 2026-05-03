extends CharacterBody2D

enum State {
	IDLE,
	RUN,
	ATTACK,
	DEAD
}

@export_category("Stats")
@export var speed: int = 400
@export var attack_speed: float = 0.6 
@export var attack_damage: int = 60


var state: State = State.IDLE
var move_direction: Vector2 =  Vector2(0,0)
var knockback_velocity: Vector2 = Vector2.ZERO
var has_key: bool = false

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]


func _ready() -> void:
	animation_tree.set_active(true)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		attack()
	
func _physics_process(delta: float) -> void:
	update_healthbar()
	if not state == State.ATTACK:
		movement_loop()
		
	if knockback_velocity.length() > 0.1:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 600 * delta)
		move_and_slide()
		return

	
func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	move_direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	var motion: Vector2 = move_direction.normalized() * speed
	set_velocity(motion)
	move_and_slide()
	
	if state == State.IDLE or state == State.RUN:
		# Horizontal flip for left/right movement
		if abs(move_direction.x) > 0.01:
			$Sprite2D.flip_h = move_direction.x < 0

		# Keep the sprite upright even when moving vertically.
		$Sprite2D.flip_v = false


	if motion != Vector2.ZERO and state == State.IDLE:
		state = State.RUN
		update_animation()
	elif motion == Vector2.ZERO and state == State.RUN:
		state = State.IDLE
		update_animation()
		
	if state == State.RUN and Engine.get_frames_drawn() % 20 == 0:
		AudioController.play_walk()


func update_animation() -> void:
	match state:
		State.IDLE:
			animation_playback.travel("idle")
		State.RUN:
			animation_playback.travel("run")
		State.ATTACK:
			animation_playback.travel("attack")
			
func attack() -> void:
	if state == State.ATTACK:
		return
	state = State.ATTACK
	
	AudioController.play_attack()

	
	var mouse_pos: Vector2 = get_global_mouse_position()
	var attack_dir: Vector2 = (mouse_pos - global_position).normalized()
	# Horizontal flipping based on attack direction only
	if abs(attack_dir.x) > 0.01:
		$Sprite2D.flip_h = attack_dir.x < 0
	# Keep the sprite upright
	$Sprite2D.flip_v = false
	animation_tree.set("parameters/attack/BlendSpace2D/blend_position", attack_dir)
	update_animation()
	
	
	await get_tree().create_timer(attack_speed).timeout
	state = State.IDLE
	update_animation()


func update_healthbar():
	var healthbar = $HealthBar
	healthbar.value = hitpoints
	
	if hitpoints >= 300:
		healthbar.visible = false
	else:
		healthbar.visible = true 
	
	
func _on_regin_timer_timeout() -> void:
	if hitpoints < 300:
		hitpoints = hitpoints + 20
		if hitpoints > 300:
			hitpoints = 300
	if hitpoints <= 0:
		hitpoints = 0

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.owner and area.owner.has_method("take_damage"):
		area.owner.take_damage(attack_damage)
		
@export_category("Player Stats")
@export var hitpoints: int = 100


func take_damage(damage_taken: int) -> void:
	hitpoints -= damage_taken
	AudioController.play_player_hurt()

	if hitpoints <= 0:
		death()
		
func apply_knockback(force: Vector2) -> void:
	knockback_velocity = force


func death() -> void:
	queue_free()
