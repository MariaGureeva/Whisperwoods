# MoonReflection_Controller.gd
extends Sprite2D

# --- ССЫЛКА НА САМ PARALLAXBACKGROUND ---
# Мы будем "подслушивать" его смещение
@onready var parallax_bg = get_tree().get_first_node_in_group("main_parallax_bg")

# --- ССЫЛКА НА НАСТОЯЩУЮ ЛУНУ ---
@onready var moon_to_follow = get_tree().get_first_node_in_group("moon_sprite_group")

@export var ripple_strength: float = 5.0
@export var ripple_speed: float = 2.0

var initial_x_offset: float
var initial_y_position: float

func _ready():
	initial_y_position = self.position.y
	# Запоминаем изначальное смещение между луной и отражением
	if is_instance_valid(moon_to_follow):
		initial_x_offset = self.global_position.x - moon_to_follow.global_position.x

func _process(delta):
	# Если мы успешно нашли Parallax Background...
	if is_instance_valid(parallax_bg) and is_instance_valid(moon_to_follow):
		# --- ГЛАВНОЕ ИСПРАВЛЕНИЕ ---
		# Мы не просто копируем позицию луны, а вычисляем свою на основе
		# смещения всего параллакса, что гораздо точнее и быстрее.
		var moon_layer_scale = moon_to_follow.get_parent().motion_scale.x
		self.global_position.x = parallax_bg.scroll_offset.x * moon_layer_scale + initial_x_offset
	
	# Эффект колыхания остается тем же
	self.position.y = initial_y_position + sin(Time.get_ticks_msec() * 0.001 * ripple_speed) * ripple_strength
