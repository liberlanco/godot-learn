extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var chase = false
const SPEED = 100.0

@onready var anim = $AnimatedSprite2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	var player = $"../../Player2/Player"
	var direction = (player.position - self.position).normalized()
	
	if chase == true:
		velocity.x = direction.x * SPEED
		if velocity.y == 0:
			anim.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			anim.play("idle")
		
	if direction.x < 0:
		anim.flip_h = true
	elif direction.x > 0:
		anim.flip_h = false
	
	move_and_slide()

func _on_detector_body_entered(body):
	if body.name == "Player":
		chase = true	


func _on_detector_body_exited(body):
	if body.name == "Player":
		chase = false
