extends Node

signal no_health()
signal hp_updated(hp)

signal no_stamina()
signal stamina_updated(stamina)

signal position_updated(position)

var position:
	set(value):
		position = value
		position_updated.emit(value)

var speed = 150.0
var jump_velocity = -400.0
var attack_stamina_cost = 10
var block_stamina_cost_div = 1
var slide_stamina_cost = 20
var run_stamina_cost = 5

var max_health = 100
var health = 100:
	set(value):
		health = max(0, min(value, max_health))
		print(health)
		if health <= 0:
			no_health.emit()
		else:
			hp_updated.emit(health)

var max_stamina = 100
var recovery_speed = 10
var stamina = 100:
	set(value):
		stamina = max(0, min(value, max_stamina))
		if stamina <= 0:
			no_stamina.emit()
		else:
			stamina_updated.emit(stamina)

var base_damage = 10
var damage = 0:
	get:
		return base_damage

var gold = 0


