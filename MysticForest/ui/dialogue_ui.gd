extends CanvasLayer

signal dialogue_action(action_name: String)
signal choice_made(choice_index)
signal dialogue_finished

@onready var text_box = $Panel/text_box
@onready var choice_box = $Panel/choice_box
@onready var buttons = [
	$Panel/choice_box/choice_1,
	$Panel/choice_box/choice_2,
	$Panel/choice_box/choice_3
]

var dialogue: Array = []
var current_index := 0

func _ready():
	hide()
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	for i in buttons.size():
		buttons[i].pressed.connect(_on_choice_pressed.bind(i))

# --- ГЛАВНАЯ ФУНКЦИЯ ---
# Она просто запускает диалог. Внешний код будет ждать сигнала.
func start_dialogue(dialogue_data: Array):
	# Защита от запуска, если узел уже "умирает"
	if not is_inside_tree():
		return

	dialogue = dialogue_data
	current_index = 0
	show()
	
	# Ставим игру на паузу
	get_tree().paused = true
	
	show_next()

func show_next(entry_override = null):
	if entry_override:
		dialogue.insert(current_index, entry_override.duplicate())

	if current_index >= dialogue.size():
		end_dialogue()
		return

	var entry = dialogue[current_index]
	current_index += 1

	if entry.has("action"):
		emit_signal("dialogue_action", entry.action)
		show_next()
		return

	if entry.has("player_choices"):
		text_box.text = entry.get("text", "Choose a response:")
		choice_box.show()
		for i in buttons.size():
			if i < entry.player_choices.size():
				buttons[i].text = entry.player_choices[i]
				buttons[i].show()
				buttons[i].disabled = false
			else:
				buttons[i].hide()
	elif entry.has("text") and entry.has("speaker"):
		text_box.text = "%s: %s" % [entry.speaker, entry.text]
		choice_box.hide()

func _on_choice_pressed(index: int):
	choice_box.hide()
	for b in buttons: b.disabled = true
	emit_signal("choice_made", index)

	var entry = dialogue[current_index - 1]
	if entry.has("responses") and index < entry.responses.size():
		show_next(entry.responses[index])
	else:
		show_next()

func _unhandled_input(event):
	if visible and not choice_box.visible and event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		show_next()

func end_dialogue():
	hide()
	# Снимаем игру с паузы
	if get_tree():
		get_tree().paused = false
	
	# Сообщаем миру, что диалог ЗАКОНЧЕН
	emit_signal("dialogue_finished")
