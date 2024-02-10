extends Node2D

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

var time_of_day = DAY
var day_count = 1
@onready var sun_light = $Light/DirectionalLight2D
@onready var point_light_1 = $Light/PointLight2D2
@onready var point_light_2 = $Light/PointLight2D3
@onready var day_text = $CanvasLayer/DayText
@onready var canvas_player = $CanvasLayer/AnimationPlayer
@onready var hp_progress_bar = $CanvasLayer/HPProgressBar
@onready var player = $Player/Player

const HP_OK_COLOR = Color("16db27")
const HP_BAD_COLOR = Color("db1616")

func _ready():
	announce_day()
	hp_progress_bar.max_value = player.max_health
	hp_progress_bar.value = player.health
	hp_progress_bar.tint_progress = HP_OK_COLOR

func _on_day_night_timeout():
	var tween = get_tree().create_tween().set_parallel(true)
	match time_of_day:
		MORNING:
			tween.tween_property(sun_light, "energy", 0.0, 5)
			tween.tween_property(sun_light, "color", Color(1, 1, 1), 5)
			tween.tween_property(point_light_1, "energy", 0, 2)
			tween.tween_property(point_light_1, "energy", 0, 2)	
			announce_day()
			time_of_day = DAY
		DAY:
			tween.tween_property(sun_light, "energy", 0.5, 5)
			tween.tween_property(sun_light, "color", Color(1, 1, 0.8), 5)
			tween.tween_property(point_light_1, "energy", 1.3, 2)			
			tween.tween_property(point_light_1, "energy", 1.3, 2)
			time_of_day = EVENING
		EVENING:
			tween.tween_property(sun_light, "energy", 0.9, 5)
			tween.tween_property(sun_light, "color", Color(1, 1, 0.7), 5)
			time_of_day = NIGHT
		NIGHT:
			tween.tween_property(sun_light, "energy", 0.3, 5)
			tween.tween_property(sun_light, "color", Color(0.8, 0.8, 1), 5)
			day_count += 1
			time_of_day = MORNING

func announce_day():
	day_text.text = "DAY " + str(day_count)
	day_text.show()
	canvas_player.play("day_text_announce")
	await canvas_player.animation_finished
	day_text.hide()
	


func _on_player_health_changed(hp):
	if not hp_progress_bar:
		return	
		
	hp_progress_bar.value = hp

	var amount = 1 - hp_progress_bar.value / hp_progress_bar.max_value
	hp_progress_bar.tint_progress = HP_OK_COLOR.lerp(HP_BAD_COLOR, amount)	

