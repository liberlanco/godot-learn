extends CharacterBody2D

signal test

enum {
	IDLE,
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	SLIDE
}

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer
var health = 100
var gold = 0
var state = MOVE
var combo = false
var attack_cooldown = false
var player_pos

func _physics_process(delta):
	
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		ATTACK2:
			attack2_state()
		ATTACK3:
			attack3_state()
		BLOCK:
			block_state()
		SLIDE:
			slide_state()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if velocity.y > 0:
		animPlayer.play("fall")

	if health <= 0:
		health = 0
		animPlayer.play("death")
		await animPlayer.animation_finished
		queue_free()
		get_tree().change_scene_to_file("res://menu.tscn")

	move_and_slide()
	
	player_pos = self.position
	Signals.emit_signal("player_position_update", player_pos)


func move_state():
	var direction = Input.get_axis("left", "right")
	var running = Input.is_action_pressed("run")
	if direction:
		velocity.x = direction * SPEED * (1.5 if running else 1.0)
		animPlayer.play("run" if running else "walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		animPlayer.play("idle")	

	if direction == -1:
		anim.flip_h = true
	elif direction == 1:
		anim.flip_h = false
		
	if Input.is_action_just_pressed("block"):
		state = BLOCK if velocity.x == 0 else SLIDE
		
	if Input.is_action_just_pressed("attack") and not attack_cooldown:
		state = ATTACK

func block_state():
	velocity.x = 0
	animPlayer.play("block")
	if Input.is_action_just_released("block"):
		state = MOVE

func slide_state():
	animPlayer.play("slide")
	await animPlayer.animation_finished
	state = MOVE
	
func attack_state():
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK2
	velocity.x = 0
	animPlayer.play("attack")
	await animPlayer.animation_finished
	attack_freeze()
	state = MOVE
	
func combo1():
	combo = true
	await animPlayer.animation_finished
	combo = false
	
func attack2_state():
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK3
	animPlayer.play("attack 2")
	await animPlayer.animation_finished
	state = MOVE
	
func attack3_state():
	animPlayer.play("attack 3")
	await animPlayer.animation_finished
	state = MOVE

func attack_freeze():
	attack_cooldown = true
	await get_tree().create_timer(0.5).timeout
	attack_cooldown = false
	
func take_hit(damage):
	print("Took " + str(damage))
