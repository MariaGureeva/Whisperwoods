# TwinFrog_Interaction.gd (рекомендую переименовать файл для ясности)
extends Area2D

# --- Ссылки на другие узлы ---
# Ищем "соседа" - узел PromptLabel
@onready var prompt_label = get_parent().get_node("PromptLabel") 
@onready var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")

var player_in_area := false

func _ready():
	# Подключаем сигнал к самому себе
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)
	
	prompt_label.hide()

func _unhandled_input(event):
	if player_in_area and event.is_action_pressed("ui_interact"):
		start_dialogue()

func _on_body_entered(body):
	if body.name == "Player1":
		player_in_area = true
		prompt_label.text = "!"
		prompt_label.show()
		JournalData.unlock_entry("creatures", "la_sol")

func _on_body_exited(body):
	if body.name == "Player1":
		player_in_area = false
		prompt_label.hide()

func start_dialogue():
	if GameState.harmony_note_found:
		dialogue_ui.start_dialogue(get_post_quest_dialogue())
	else:
		dialogue_ui.start_dialogue(get_pre_quest_dialogue())
	
# --- БИБЛИОТЕКА ДИАЛОГОВ ---

func get_pre_quest_dialogue():
	return [
		{ "speaker": "La", "text": "Hmph. Don't talk to me. We've lost our harmony." },
		{ "speaker": "La", "text": "The Singing Totems around the pond are silent... There can be no song without them." }
	]

func get_post_quest_dialogue():
	return [
		{ "speaker": "La", "text": "The pond sings again! Thank you, Listener!" }
	]
