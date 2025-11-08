extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var player = $"../Player1"
var move_speed: float = 700      # Скорость паука, можете настроить по вкусу.
var stop_distance: float = 200   # Дистанция, на которой паук останавливается у цели.
var wait_for_player_distance: float = 500   

var is_following: bool = false
var target: Node2D = null
var is_in_cutscene: bool = false

var is_leading: bool = false
var leading_path: Array = []
var current_path_target_index: int = 0
var is_waiting_for_player: bool = false


func _ready():
	disable_collision()

func enable_collision():
	if is_instance_valid(collision_shape):
		collision_shape.disabled = false

func disable_collision():
	if is_instance_valid(collision_shape):
		collision_shape.disabled = true

func appear():
	self.show()
	if is_instance_valid(animated_sprite):
		animated_sprite.play("appear")
		await animated_sprite.animation_finished

func take_hit():
	if is_instance_valid(animated_sprite):
		animated_sprite.play("hurt")
		await animated_sprite.animation_finished

func escape():
	if is_instance_valid(animated_sprite):
		animated_sprite.play("escape")
		await animated_sprite.animation_finished
	self.hide()
	
func start_following(new_target: Node2D):
	is_leading = false 
	is_following = true
	target = new_target

func start_leading_path(path_nodes: Array, start_index: int):
	is_following = false # Выключаем обычное следование
	is_leading = true
	is_waiting_for_player = false
	leading_path = path_nodes
	current_path_target_index = start_index
	print("Паук начал вести по пути, начиная с точки ", start_index)

func _physics_process(delta):
	if is_in_cutscene: return

	if is_leading:
		process_leading(delta)
	elif is_following:
		process_following(delta)

func process_following(delta):
	if not is_instance_valid(target): return
	var direction = global_position.direction_to(target.global_position)
	var distance = global_position.distance_to(target.global_position)
	if distance > stop_distance:
		velocity = direction * move_speed * 0.8 # В режиме следования он чуть медленнее
		move_and_animate(direction)
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("standing")
	move_and_slide()

func process_leading(delta):
	if not is_instance_valid(player): return

	# Если мы в режиме ожидания игрока
	if is_waiting_for_player:
		velocity = Vector2.ZERO
		animated_sprite.play("standing")
		# Если игрок подошел достаточно близко, продолжаем путь
		if global_position.distance_to(player.global_position) < wait_for_player_distance:
			is_waiting_for_player = false
		move_and_slide()
		return

	# Если путь закончился, просто ждем
	if current_path_target_index >= leading_path.size():
		velocity = Vector2.ZERO
		animated_sprite.play("standing")
		move_and_slide()
		return
	
	var target_point = leading_path[current_path_target_index]
	var direction = global_position.direction_to(target_point.global_position)
	var distance = global_position.distance_to(target_point.global_position)

	if distance > 15.0: # Двигаемся к точке
		velocity = direction * move_speed
		move_and_animate(direction)
	else: # Мы достигли точки
		velocity = Vector2.ZERO
		is_waiting_for_player = true # Включаем режим ожидания
		# Увеличиваем ГЛОБАЛЬНЫЙ индекс, чтобы следующая сцена знала, откуда начинать
		GameState.spider_leading_path_index += 1
		current_path_target_index += 1
		print("Паук достиг точки. Глобальный индекс: ", GameState.spider_leading_path_index)
	
	move_and_slide()

# Вспомогательная функция для анимации
func move_and_animate(direction: Vector2):
	if abs(direction.x) > 0.1:
		animated_sprite.play("walking right" if direction.x > 0 else "walking left")
	else:
		animated_sprite.play("walking right")
