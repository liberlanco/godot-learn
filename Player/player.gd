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
	DEATH,
	RECOVERY
}


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var damage_combo_mod = 1
var no_run = false

@onready var state_chart = $StateChart
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
			RECOVERY:
				recovery_state()

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
			move_state_physics_process(delta)
		BLOCK:
			block_state_physics_process(delta)
		ATTACK:
			attack_state_physics_process(delta)
		ATTACK2:
			attack2_state_physics_process(delta)

	move_and_slide()

	if state in [MOVE, RECOVERY] and velocity.x == 0:
		state_chart.send_event("idle")
	else:
		state_chart.send_event("not idle")

	PlayerManager.position = position
	
func move_state():
	pass
	
func move_state_physics_process(delta):
	var direction = Input.get_axis("left", "right")
	var running = Input.is_action_pressed("run") and pre_run(delta)

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
		if abs(velocity.x) < 0.1:
			state = BLOCK
		elif spend_action_stamina(SLIDE):
			state = SLIDE
		
	if Input.is_action_just_pressed("attack") and pre_attack(ATTACK):
		state = ATTACK

	if PlayerManager.stamina < 100 and not running:
		var recovery = PlayerManager.recovery_speed * delta
		if velocity.x == 0:
			recovery *= 2
		PlayerManager.stamina += recovery

func block_state():
	velocity.x = 0
	animation_player.play("block")
		
func block_state_physics_process(delta):
	if Input.is_action_just_released("block"):
		state = MOVE

func slide_state():
	animation_player.play("slide")
	await animation_player.animation_finished
	state = MOVE
	
func attack_state():
	animation_player.play("attack")
	velocity.x = 0
	damage_combo_mod = 1
	await animation_player.animation_finished
	if state == ATTACK:
		attack_freeze()
	state = MOVE
	
func attack_state_physics_process(delta):
	if Input.is_action_just_pressed("attack") and pre_attack(ATTACK2, true):
		state = ATTACK2
	
func attack2_state():
	animation_player.play("attack 2")
	damage_combo_mod = 1.2
	await animation_player.animation_finished
	state = MOVE
	
func attack2_state_physics_process(delta):
	if Input.is_action_just_pressed("attack") and pre_attack(ATTACK3, true):
		state = ATTACK3
	
func attack3_state():
	animation_player.play("attack 3")
	damage_combo_mod = 2
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

func recovery_state():
	velocity.x = 0
	animation_player.play("recovery")
	await animation_player.animation_finished
	PlayerManager.stamina += PlayerManager.recovery_speed * 3
	state = MOVE

func combo1():
	combo = true
	await animation_player.animation_finished
	combo = false
	
func pre_attack(next_attack_phase, in_combo = false):
	if in_combo && !combo:
		return false
	if attack_cooldown:
		return false
	if not spend_action_stamina(next_attack_phase):
		return false
	return true

func pre_run(delta):
	if no_run and PlayerManager.stamina < 30:
		return false
	if PlayerManager.stamina < 2:
		no_run = true
		return false
	else:
		no_run = false
	spend_stamina(PlayerManager.run_stamina_cost * delta)
	return true

func take_hit(damage):
	var stamina_reducement = 0
	if state == BLOCK:
		stamina_reducement = damage / PlayerManager.block_stamina_cost_div
		damage = damage / 4
	elif state == SLIDE:
		return
	PlayerManager.health -= damage
	if stamina_reducement > 0:
		PlayerManager.stamina -= stamina_reducement

func _on_hit_box_area_entered(area):
	var body = area.target_object
	if body.has_method("take_hit"):
		body.take_hit(PlayerManager.damage * damage_combo_mod)

func _on_player_hp_updated(hp, diff):
	if state != BLOCK and diff < 0:
		state = DAMAGE

func _on_player_no_health():
	state = DEATH

func _on_player_no_stamina():
	state = RECOVERY


func spend_action_stamina(action):
	match action:
		ATTACK:
			return spend_stamina(PlayerManager.attack_stamina_cost)
		ATTACK2:
			return spend_stamina(PlayerManager.attack_stamina_cost)
		ATTACK3:
			return spend_stamina(PlayerManager.attack_stamina_cost)
		SLIDE:
			return spend_stamina(PlayerManager.slide_stamina_cost)

func spend_stamina(amount):
	if PlayerManager.stamina < amount:
		return false
	else:
		PlayerManager.stamina -= amount
		return true

func _on_regen_active_state_physics_processing(delta):
	PlayerManager.health += 10 * delta 
	
	
