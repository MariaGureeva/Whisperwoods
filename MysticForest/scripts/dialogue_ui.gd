extends CanvasLayer

signal dialogue_action(action_name)

@onready var text_box = $Panel/text_box

var dialogue = []
var current_index = 0
var dialogue_done := false

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_dialogue(dialogue_data: Array) -> void:
	if not is_inside_tree():
		return
	dialogue = dialogue_data
	current_index = 0
	dialogue_done = false
	show()
	get_tree().paused = true
	show_next()

	# Ждём завершения диалога
	while not dialogue_done:
		if not is_inside_tree():
			dialogue_done = true
		else:
			await get_tree().process_frame

func show_next():
	if not is_inside_tree():
		return
	if current_index >= dialogue.size():
		dialogue_done = true
		hide()
		if get_tree():
			get_tree().paused = false
		return

	var entry = dialogue[current_index]
	current_index += 1

	if entry.has("action"):
		dialogue_action.emit(entry["action"])
		show_next()
		return

	if entry.has("text") and entry.has("speaker"):
		text_box.text = entry.speaker + ": " + entry.text

func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_accept"):
		show_next()
		
