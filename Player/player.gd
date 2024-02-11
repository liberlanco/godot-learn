extends CharacterBody2D

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

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var damage_combo_mod = 1

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var attack_direction = $AttackDirection

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

func _ready():
	PlayerManager.connect("hp_updated", Callable(self, "_on_player_hp_updated"))
	PlayerManager.connect("no_health", Callable(self, "_on_player_no_health"))
	PlayerManager.connect("no_stamina", Callable(self, "_on_player_no_stamina"))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
#
	#if velocity.y > 0:
		#animation_player.play("fall")
	
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
	PlayerManager.position = position

func move_state():
	pass

func move_state_physics_process():
	var direction = Input.get_axis("left", "right")
	var running = Input.is_action_pressed("run")
	if direction:
		velocity.x = direction * PlayerManager.speed * (1.5 if running else 1.0)
		animation_player.play("run" if running else "walk")
	else:
		velocity.x = move_toward(velocity.x, 0, PlayerManager.speed)
		animation_player.play("idle")	

	if direction == -1:
		animated_sprite_2d.flip_h = true
		attack_direction.scale = Vector2(-1, 1)
	elif direction == 1:
		animated_sprite_2d.flip_h = false
		attack_direction.scale = Vector2(1, 1)
		
	if Input.is_action_pressed("block") and state != SLIDE:
		state = BLOCK if velocity.x == 0 else SLIDE
		
	if Input.is_action_just_pressed("attack") and not attack_cooldown:
		state = ATTACK

func block_state():
	velocity.x = 0
	animation_player.play("block")
		
func block_state_physics_process():
	if Input.is_action_just_released("block"):
		state = MOVE

func slide_state():
	animation_player.play("slide")
	await animation_player.animation_finished
	state = MOVE
	
func attack_state():
	velocity.x = 0
	damage_combo_mod = 1
	animation_player.play("attack")
	await animation_player.animation_finished
	if state == ATTACK:
		attack_freeze()
	state = MOVE
	
func attack_state_physics_process():
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK2
	
func combo1():
	combo = true
	await animation_player.animation_finished
	combo = false
	
func attack2_state():
	damage_combo_mod = 1.2
	animation_player.play("attack 2")
	await animation_player.animation_finished
	state = MOVE
	
func attack2_state_physics_process():
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK3
	
func attack3_state():
	damage_combo_mod = 2
	animation_player.play("attack 3")
	await animation_player.animation_finished
	state = MOVE

func attack_freeze():
	attack_cooldown = true
	await get_tree().create_timer(0.5).timeout
	attack_cooldown = false
	
func damage_state():
	velocity.x = 0
	animation_player.play("damage")
	await animation_player.animation_finished
	state = MOVE
	
func death_state():
	velocity.x = 0
	animation_player.play("death")
	await animation_player.animation_finished
	queue_free()
	get_tree().change_scene_to_file("res://menu.tscn")

func take_hit(damage):
	if state == BLOCK:
		damage /= 4
	elif state == SLIDE:
		return
	PlayerManager.health -= damage

func _on_hit_box_area_entered(area):
	var body = area.target_object
	if body.has_method("take_hit"):
		body.take_hit(PlayerManager.damage * damage_combo_mod)

func _on_player_hp_updated(hp):
	if state != BLOCK:
		state = DAMAGE

func _on_player_no_health():
	state = DEATH

func _on_player_no_stamina():
	state = IDLE
