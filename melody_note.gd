extends Area2D

# Сигнал, который сообщит контроллеру, что нота поймана
signal note_collected

var is_collected := false

func _ready():
	# Изначально нота полностью невидима
	hide()
	# Подключаем сигнал для "ловли"
	body_entered.connect(_on_body_entered)

# Эта функция вызывается из скрипта игрока по call_group
func reveal(is_revealed: bool):
	if not is_collected:
		if is_revealed:
			show()
		else:
			hide()

func _on_body_entered(body):
	if not is_collected and body.name == "Player1":
		is_collected = true
		
		# "Выключаем" возможность повторного входа
		monitoring = false
		
		# Анимация "ловли" - светлячки всасываются в игрока
		var tween = create_tween()
		# Уменьшаем масштаб до нуля за полсекунды
		tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
		await tween.finished
		
		# Посылаем сигнал главному контроллеру
		emit_signal("note_collected")
		
		# Уничтожаем ноту навсегда
		queue_free()
