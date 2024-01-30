extends CharacterBody2D

var damage = 50

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	print(1)
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()


func _on_attack_range_body_entered(body):
	if body.has_method("take_hit"):
		body.take_hit(damage)
