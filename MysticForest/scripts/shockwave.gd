extends Area2D

func _on_body_entered(body):
	print("1. Волна с чем-то столкнулась!")
	if body.is_in_group("player") and body.has_method("take_damage"):
		print("2. Это игрок! Вызываю take_damage().")
		body.take_damage()

func _ready():
	# Строка body_entered.connect(...) УДАЛЕНА
	var tween = create_tween()
	scale = Vector2.ZERO
	tween.tween_property(self, "scale", Vector2(10, 10), 2.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.finished.connect(queue_free)
