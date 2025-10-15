# ResonanceSource.gd
extends Area2D

func _ready():
	body_entered.connect(func(body):
		if body.name == "Player1" and GameState.attunement_unlocked:
			# Сообщаем игроку, что он вошел в зону силы
			body.is_in_power_zone = true
			print("Player entered a resonance source.")
	)

	body_exited.connect(func(body):
		if body.name == "Player1":
			# Сообщаем игроку, что он покинул зону
			body.is_in_power_zone = false
			print("Player left a resonance source.")
	)
	
