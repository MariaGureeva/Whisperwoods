# ParallaxCamera.gd
extends Camera2D

# Перетащите сюда вашего игрока в инспекторе
@export var target_node: Node2D

func _process(delta):
	# Каждый кадр просто копируем глобальную позицию игрока
	if is_instance_valid(target_node):
		self.global_position = target_node.global_position
