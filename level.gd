extends Node2D

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

var time_of_day = MORNING
var day_count = 1
@onready var sun_light = $Light/DirectionalLight2D
@onready var point_light_1 = $Light/PointLight2D2
@onready var point_light_2 = $Light/PointLight2D3
@onready var day_text = $CanvasLayer/DayText
@onready var canvas_player = $CanvasLayer/AnimationPlayer
@onready var player = $Player/Player
@onready var daytime_animation_player = $Light/DaytimeAnimationPlayer
@onready var state_chart_debugger = $CanvasLayer/StateChartDebugger

const HP_OK_COLOR = Color("16db27")
const HP_BAD_COLOR = Color("db1616")

func _ready():
	exec_time_of_day()

	#hp_progress_bar.max_value = player.max_health
	#hp_progress_bar.value = player.health
	#hp_progress_bar.tint_progress = HP_OK_COLOR

func _on_day_night_timeout():
	transit_time_of_day()
	exec_time_of_day()

func transit_time_of_day():
	time_of_day += 1
	if time_of_day > NIGHT:
		time_of_day = MORNING
	
func exec_time_of_day():
	day_text.text = "DAY " + str(day_count)
	match time_of_day:
		MORNING:
			print("morning")
			day_count += 1
			daytime_animation_player.play("to_morning")
		DAY:
			daytime_animation_player.play("to_day")
		EVENING:
			daytime_animation_player.play("to_evening")
		NIGHT:
			daytime_animation_player.play("to_night")




#func _on_player_health_changed(hp):
	#if not hp_progress_bar:
		#return	
		#
	#hp_progress_bar.value = hp
#
	#var amount = 1 - hp_progress_bar.value / hp_progress_bar.max_value
	#hp_progress_bar.tint_progress = HP_OK_COLOR.lerp(HP_BAD_COLOR, amount)	

