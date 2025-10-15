# Star.gd
extends Area2D

# Сигнал, который звезда пошлет, когда на нее кликнут
signal star_clicked(star_node)

@onready var sprite = $Sprite2D

# --- ВАШИ ТЕКСТУРЫ ---
# Загружаем заранее все три состояния
var texture_idle = preload("res://MysticForest/assets/UI/Star1.png")
var texture_hover = preload("res://MysticForest/assets/UI/Star2.png")
var texture_active = preload("res://MysticForest/assets/UI/Star3.png")

func _ready():
	# Подключаем встроенные сигналы Area2D
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	
	# Устанавливаем начальную текстуру
	sprite.texture = texture_idle

# Когда мышь наведена
func _on_mouse_entered():
	sprite.texture = texture_hover

# Когда мышь убрана
func _on_mouse_exited():
	# Возвращаем idle текстуру, ТОЛЬКО если звезда не "активна"
	if sprite.texture != texture_active:
		sprite.texture = texture_idle

# Когда происходит клик
func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		# Посылаем сигнал "наверх" контроллеру, передавая себя в качестве аргумента
		emit_signal("star_clicked", self)

# Эту функцию будет вызывать контроллер, чтобы менять состояние звезды
func set_active(is_active: bool):
	if is_active:
		sprite.texture = texture_active
	else:
		sprite.texture = texture_idle
