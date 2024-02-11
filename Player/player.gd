extends CharacterBody2D

signal health_changed(hp)

enum {
	IDLE,
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	SLIDE,
	DAMAGE,
	DEATH
}

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer
@onready var attack_direction = $AttackDirection

var max_health = 100
var base_damage = 10
var damage_combo_mod = 1

var health = 0:
	set(value):
		health = value
		if health < 0:
			health = 0
		health_changed.emit(health)
var damage = 0:
	get: 
		return base_damage * damage_combo_mod

var gold = 0
var state = MOVE:
	set(value):
		state = value
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
			DAMAGE:
				damage_state()
			DEATH:
				death_state()

var combo = false
var attack_cooldown = false
var player_pos


func _ready():
	health = max_health

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
#
	#if velocity.y > 0:
		#animPlayer.play("fall")
	
	match state:
		MOVE:
			move_state_physics_process()
		BLOCK:
			block_state_physics_process()
		ATTACK:
			attack_state_physics_process()
		ATTACK2:
			attack2_state_physics_process()
		

	move_and_slide()
	
	player_pos = self.position
	Signals.emit_signal("player_position_update", player_pos)


func move_state():
	pass

func move_state_physics_process():
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
		attack_direction.scale = Vector2(-1, 1)
	elif direction == 1:
		anim.flip_h = false
		attack_direction.scale = Vector2(1, 1)
		
	if Input.is_action_pressed("block") and state != SLIDE:
		state = BLOCK if velocity.x == 0 else SLIDE
		
	if Input.is_action_just_pressed("attack") and not attack_cooldown:
		state = ATTACK

func block_state():
	velocity.x = 0
	animPlayer.play("block")
		
func block_state_physics_process():
	if Input.is_action_just_released("block"):
		state = MOVE

func slide_state():
	animPlayer.play("slide")
	await animPlayer.animation_finished
	state = MOVE
	
func attack_state():
	velocity.x = 0
	damage_combo_mod = 1
	animPlayer.play("attack")
	await animPlayer.animation_finished
	if state == ATTACK:
		attack_freeze()
	state = MOVE
	
func attack_state_physics_process():
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK2	
	
func combo1():
	combo = true
	await animPlayer.animation_finished
	combo = false
	
func attack2_state():
	damage_combo_mod = 1.2
	animPlayer.play("attack 2")
	await animPlayer.animation_finished
	state = MOVE
	
func attack2_state_physics_process():
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK3	
	
func attack3_state():
	damage_combo_mod = 2
	animPlayer.play("attack 3")
	await animPlayer.animation_finished
	state = MOVE

func attack_freeze():
	attack_cooldown = true
	await get_tree().create_timer(0.5).timeout
	attack_cooldown = false
	
func damage_state():
	velocity.x = 0
	animPlayer.play("damage")
	await animPlayer.animation_finished
	state = MOVE
	
func death_state():
	velocity.x = 0
	animPlayer.play("death")
	await animPlayer.animation_finished
	queue_free()
	#get_tree().change_scene_to_file("res://menu.tscn")

func take_hit(damage):
	if state == BLOCK:
		damage /= 4
	elif state == SLIDE:
		return
	else:
		state = DAMAGE
		
	health -= damage
	if health <= 0:
		state = DEATH


func _on_hit_box_area_entered(area):
	var body = area.target_object
	if body.has_method("take_hit"):
		body.take_hit(damage)
