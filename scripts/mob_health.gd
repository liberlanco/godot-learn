extends Node2D

signal no_health
signal damaged(hp)

@onready var health_bar = $HealthBar
@onready var damage_text = $DamageText

var max_health = 100
var health = 0:
	set(value):
		health_bar.value = value
		health = value

func _ready():
	health = max_health
	damage_text.hide()
	health_bar.hide()

func take_hit(damage):
	health -= damage
	health_bar.show()
	if health <= 0:
		health = 0
		no_health.emit()
		health_bar.hide()
	else:
		damaged.emit(health)
	show_damage(damage)
	
func show_damage(damage):
	var new_txt = damage_text.duplicate()
	add_child(new_txt)
	new_txt.text = str(damage)
	new_txt.show()
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(new_txt, "position", new_txt.position - Vector2(0, 300), 0.5)
	tween.tween_property(new_txt, "modulate:a", 0, 0.5)
	await tween.finished
	new_txt.queue_free()
