# ParallaxController.gd
extends ParallaxBackground

@onready var camera = get_viewport().get_camera_2d()

func _process(delta):
	# Вручную устанавливаем смещение параллакса равным позиции камеры
	if is_instance_valid(camera):
		scroll_offset = camera.get_screen_center_position()
