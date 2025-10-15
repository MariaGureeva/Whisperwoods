extends ColorRect

@onready var icon_texture = $Icon
@onready var quantity_label = $QuantityLabel

var display_name: String = ""

func _ready():
	mouse_filter = MOUSE_FILTER_STOP
	
func set_item(item_data: Dictionary):
	self.display_name = item_data.get("name", "")
	
	icon_texture.texture = item_data.get("texture", null)
	icon_texture.show()
	
	var quantity = item_data.get("quantity", 1)
	if quantity > 1:
		quantity_label.text = str(quantity)
		quantity_label.show()
	else:
		quantity_label.hide()
	
func clear_slot():
	self.display_name = ""
	icon_texture.texture = null
	icon_texture.hide()
	quantity_label.hide()

func _get_tooltip(at_position: Vector2) -> String:
	# Этот шпион сработает, как только мышь окажется над слотом
	print("Проверка подсказки для слота. Предмет: '", display_name, "'")
	
	if not display_name.is_empty():
		return display_name
	else:
		return ""
