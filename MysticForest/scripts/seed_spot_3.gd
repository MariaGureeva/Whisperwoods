extends Area2D
signal seed_planted

var is_planted := false
@onready var planting_marker = $PlantingMarker3
@onready var plant_sprite = $PlantSprite3
@onready var animation_player = $AnimationPlayer3

func _ready():
	# Подключаем сигналы входа и выхода из зоны
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	
	# Изначально все скрыто
	planting_marker.hide()
	plant_sprite.hide()

# Эта функция будет вызываться из основного скрипта, чтобы показать, что здесь можно сажать
func activate_spot():
	if not is_planted:
		planting_marker.show()

# Подсвечиваем метку, когда игрок рядом
func set_highlight(active: bool):
	if not is_planted:
		# Делаем метку ярче или меняем цвет, чтобы показать возможность взаимодействия
		planting_marker.modulate.a = 1.0 if active else 0.5

func _on_body_entered(body):
	if is_planted or body.name != "Player1": return
	# Сообщаем игроку, что он рядом с этим конкретным местом
	body.register_seed_spot(self)

func _on_body_exited(body):
	if is_planted or body.name != "Player1": return
	# Сообщаем игроку, что он отошел
	body.unregister_seed_spot(self)

# Главная функция, запускающая весь процесс
func plant():
	if is_planted: return
	is_planted = true
	
	# Скрываем метку
	planting_marker.hide()
	# Показываем спрайт растения (он пока на первом кадре)
	plant_sprite.show()
	
	# Проигрываем анимацию роста
	animation_player.play("grow")
	# ЖДЕМ, пока анимация роста не завершится
	await animation_player.animation_finished
	
	# Только ПОСЛЕ анимации сообщаем главной сцене, что семя посажено
	emit_signal("seed_planted")
	
func force_heal():
	if is_planted: return
	is_planted = true
	
	# Скрываем метку на земле
	planting_marker.hide()
	# Показываем спрайт растения
	plant_sprite.show()
	
	# Вместо проигрывания анимации, сразу переключаем на последний кадр
	if plant_sprite is AnimatedSprite2D:
		# Убедитесь, что 'default' - имя вашей анимации в SpriteFrames
		var frame_count = plant_sprite.sprite_frames.get_frame_count("default")
		if frame_count > 0:
			plant_sprite.frame = frame_count
