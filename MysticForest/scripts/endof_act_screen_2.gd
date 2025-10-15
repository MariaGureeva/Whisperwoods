extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var label = $Label

func _ready():
	self.name = "SceneTransitionFader"
	color_rect.modulate.a = 0.0
	label.modulate.a = 0.0
	hide()

func show_and_fade(node_to_hide = null):
	show()
	var tween_in = create_tween().set_parallel()
	tween_in.tween_property(color_rect, "modulate:a", 1.0, 2.0)
	tween_in.tween_property(label, "modulate:a", 1.0, 2.0)
	await tween_in.finished
	
	if is_instance_valid(node_to_hide):
		node_to_hide.hide()
	
	await get_tree().create_timer(4.0).timeout
	
	var tween_out = create_tween().set_parallel()
	tween_out.tween_property(color_rect, "modulate:a", 0.0, 2.0)
	tween_out.tween_property(label, "modulate:a", 0.0, 2.0)
	await tween_out.finished
	
	hide()

func fade_to_black_and_hold():
	show()
	var tween_in = create_tween().set_parallel()
	tween_in.tween_property(color_rect, "modulate:a", 1.0, 2.0)
	tween_in.tween_property(label, "modulate:a", 1.0, 2.0)
	await tween_in.finished
	
# --- ИСПРАВЛЕННАЯ ФУНКЦИЯ ---
func fade_in_and_destroy():
	# Создаем Tween, который будет анимировать фон и текст ОДНОВРЕМЕННО
	var tween_out = create_tween().set_parallel()
	
	# Анимируем прозрачность черного фона (ColorRect)
	tween_out.tween_property(color_rect, "modulate:a", 0.0, 2.0)
	
	# Анимируем прозрачность текста (Label)
	tween_out.tween_property(label, "modulate:a", 0.0, 2.0)
	
	# Ждем, пока ОБЕ анимации не завершатся
	await tween_out.finished
	
	# Уничтожаем себя после завершения
	queue_free()
