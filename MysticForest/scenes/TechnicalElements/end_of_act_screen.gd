# EndOfActScreen.gd
extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var label = $Label
# Мы больше НЕ ищем Тодлинга здесь, это ненадежно
# @onready var toadling: CharacterBody2D = $"../Toadling"

func _ready():
	color_rect.modulate.a = 0.0
	label.modulate.a = 0.0
	hide()

# --- ИСПРАВЛЕННАЯ УНИВЕРСАЛЬНАЯ ФУНКЦИЯ ---
# node_to_hide = null означает, что этот аргумент НЕОБЯЗАТЕЛЬНЫЙ
func show_and_fade(node_to_hide = null):
	show()
	
	var tween_in = create_tween().set_parallel()
	tween_in.tween_property(color_rect, "modulate:a", 1.0, 2.0)
	tween_in.tween_property(label, "modulate:a", 1.0, 2.0)
	await tween_in.finished
	
	# Если нам ПЕРЕДАЛИ какой-то узел, мы его прячем
	if is_instance_valid(node_to_hide):
		node_to_hide.hide()
	
	await get_tree().create_timer(4.0).timeout
	
	var tween_out = create_tween().set_parallel()
	tween_out.tween_property(color_rect, "modulate:a", 0.0, 2.0)
	tween_out.tween_property(label, "modulate:a", 0.0, 2.0)
	await tween_out.finished
	
	hide()
