extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var chase = false
var alive = true
const SPEED = 100.0
@onready var anim = $AnimatedSprite2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	var player = $"../../Player2/Player"
	var direction = (player.position - self.position).normalized()
	
	if alive == false:
		move_and_slide()
		return
	
	if chase == true:
		velocity.x = direction.x * SPEED
		#$Label.text = "^_+ TE6E XaHA :)"
		#$Label.visible = true
		if velocity.y == 0:
			anim.play("run")
	else:
		#$Label.text = "CTON! Tb| KYDA?"
		#$Label.visible = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			anim.play("idle") # ^_+ тебе хана
		
	if direction.x < 0:
		anim.flip_h = true
	elif direction.x > 0:
		anim.flip_h = false
	
	move_and_slide()

func _on_detector_body_entered(body):
	if body.name == "Player":
		chase = true	


func _on_detector_body_exited(body):
	if body.name == "Player" and alive:
		chase = false


func _on_death_body_entered(body):
	if body.name == "Player" and alive:
		body.velocity.y -= 300
		death()

func _on_hit_and_death_body_entered(body):
	if body.name == "Player" and alive:
		body.health -= 40
		death()

func death():
	alive = false
	anim.play("death")
	await anim.animation_finished
	queue_free()


