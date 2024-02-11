extends CharacterBody2D

enum {
	IDLE,
	ATTACK,
	CHASE,
	RECOVER,
	DAMAGE,
	DEATH
}

var damage = 20
var player_position
var direction

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animation_player = $AnimationPlayer
@onready var attack_collision_shape_2d = $AttackDirection/AttackRange/AttackCollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var attack_direction = $AttackDirection
@onready var mob_health = $MobHealth

var state: int = 0:
	set(value):
		state = value
		_on_state_update(value)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	match state:
		CHASE:
			chase_physics_process()

	move_and_slide()


func _on_attack_range_body_entered(body):
	state = ATTACK
	#print("Attack!")
	#animation_player.play("attack")
	#if body.has_method("take_hit"):
		#body.take_hit(damage)

func _on_state_update(value):
	match state:
		IDLE:
			idle_state()
		ATTACK:
			attack_state()
		CHASE:
			chase_state()
		DEATH:
			death_state()
		DAMAGE:
			damage_state()
		RECOVER:
			recover_state()
	
func idle_state():
	animation_player.play("idle")

	state = CHASE

func recover_state():
	animation_player.play("recover")
	await animation_player.animation_finished
	state = IDLE
	
func attack_state():
	animation_player.play("attack")
	await animation_player.animation_finished
	state = RECOVER

func chase_state():
	pass
	
func death_state():
	velocity.x = 0
	animation_player.play("death")
	await animation_player.animation_finished
	queue_free()
	
func damage_state():
	velocity.x = 0
	animation_player.stop()
	animation_player.play("hit")
	await animation_player.animation_finished
	state = IDLE
	
func take_hit(damage):
	mob_health.take_hit(damage)

func chase_physics_process():
	direction = (PlayerManager.position -  self.position).normalized()
	if direction.x < 0:
		animated_sprite_2d.flip_h = true
		attack_direction.scale = Vector2(-1, 1)
	elif direction.x > 0:
		animated_sprite_2d.flip_h = false
		attack_direction.scale = Vector2(1, 1)

func _on_hit_box_area_entered(area):
	var body = area.target_object
	if body.has_method("take_hit"):
		body.take_hit(damage)

func _on_mob_health_no_health():
	state = DEATH

func _on_mob_health_damaged(hp):
	state = DAMAGE
