extends Area2D

# Сигнал, который сообщит Grumble, что барабан исцелен
signal drum_healed

@onready var prompt_label = $PromptLabel
@onready var cracked_sprite = $"Pumpkin broken"
@onready var fixed_sprite = $"Pumpkin healed"

var is_healed := false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt_label.hide()

func _on_body_entered(body):
	if not is_healed and body.name == "Player1":
		body.attunement_target = self # Сообщаем игроку, что мы - цель
		prompt_label.text = "PRESS E"
		prompt_label.show()

func _on_body_exited(body):
	if not is_healed and body.name == "Player1":
		body.attunement_target = null # Убираем цель
		prompt_label.hide()

func heal():
	if is_healed: return
	is_healed = true
	
	cracked_sprite.hide()
	fixed_sprite.show()
	prompt_label.hide()
	
	# Отключаем дальнейшее взаимодействие
	get_node("CollisionShape2D").disabled = true
	
	# Посылаем сигнал, что мы исцелены!
	emit_signal("drum_healed")
