# CrystalLantern.gd
extends Area2D

@onready var sprite = $Sprite2D
@onready var light = $PointLight2D
@onready var timer = $Timer

# Сколько секунд кристалл будет гореть
@export var burn_duration: float = 45.0

var is_lit := false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	timer.timeout.connect(_on_timer_timeout)
	light.enabled = false
	# Делаем кристалл тусклым по умолчанию
	sprite.modulate = Color(0.5, 0.5, 0.5)

func _on_body_entered(body):
	if not is_lit and body.name == "Player1":
		body.attunement_target = self

func _on_body_exited(body):
	if body.attunement_target == self:
		body.attunement_target = null

# Эту функцию вызывает игрок
func heal():
	if is_lit: return
	is_lit = true
	
	# Делаем кристалл ярким и включаем свет
	sprite.modulate = Color.WHITE
	light.enabled = true
	
	# Запускаем таймер
	timer.start(burn_duration)
	
	# Убираем себя из целей игрока
	var player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player) and player.attunement_target == self:
		player.attunement_target = null

# Когда таймер заканчивается
func _on_timer_timeout():
	is_lit = false
	sprite.modulate = Color(0.5, 0.5, 0.5) # Снова делаем тусклым
	light.enabled = false
