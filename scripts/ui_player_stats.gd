extends CanvasLayer

@onready var health_bar = $HealthBar
@onready var stamina_bar = $StaminaBar

func _ready():
	PlayerManager.connect("hp_updated", Callable(self, "_on_player_hp_updated"))
	PlayerManager.connect("stamina_updated", Callable(self, "_on_player_stamina_updated"))
	
	_on_player_hp_updated(PlayerManager.health, 0)
	_on_player_stamina_updated(PlayerManager.stamina, 0)
	
	
func _on_player_hp_updated(hp, diff):
	health_bar.value = PlayerManager.health
	
func _on_player_stamina_updated(stamina, diff):
	stamina_bar.value = PlayerManager.stamina
