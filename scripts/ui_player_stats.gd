extends CanvasLayer

@onready var health_bar = $HealthBar
@onready var stamina_bar = $StaminaBar

func _ready():
	PlayerManager.connect("hp_updated", Callable(self, "_on_player_hp_updated"))
	PlayerManager.connect("stamin_updated", Callable(self, "_on_player_stamin_updated"))
	
	_on_player_hp_updated(PlayerManager.health)
	_on_player_stamina_updated(PlayerManager.stamina)
	
	
func _on_player_hp_updated(hp):
	health_bar.value = PlayerManager.health
	
func _on_player_stamina_updated(stamina):
	stamina_bar.value = PlayerManager.stamina
