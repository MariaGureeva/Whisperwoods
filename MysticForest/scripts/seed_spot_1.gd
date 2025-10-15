extends Area2D
signal seed_planted

var is_planted := false
@onready var planting_marker = $PlantingMarker
@onready var plant_sprite = $PlantSprite
@onready var animation_player = $AnimationPlayer

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	
	planting_marker.hide()
	plant_sprite.hide()

func activate_spot():
	if not is_planted:
		planting_marker.show()

func set_highlight(active: bool):
	if not is_planted:
		planting_marker.modulate.a = 1.0 if active else 0.5

func _on_body_entered(body):
	if is_planted or body.name != "Player1": return
	body.register_seed_spot(self)

func _on_body_exited(body):
	if is_planted or body.name != "Player1": return
	body.unregister_seed_spot(self)

func plant():
	if is_planted: return
	is_planted = true
	
	planting_marker.hide()
	plant_sprite.show()
	
	# Grow animation
	animation_player.play("grow")
	await animation_player.animation_finished
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
