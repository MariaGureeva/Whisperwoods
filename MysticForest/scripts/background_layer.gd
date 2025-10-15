# BackgroundLayer.gd
extends CanvasLayer

@onready var camera = get_viewport().get_camera_2d()

func _process(delta):
	# Если камера существует, синхронизируем смещение слоя с ее позицией
	if is_instance_valid(camera):
		offset = camera.get_screen_center_position()
