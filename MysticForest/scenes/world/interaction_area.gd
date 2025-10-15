extends Area2D

@onready var parent_npc = get_parent() 
# Ищем "соседа" - узел PromptLabel
@onready var prompt_label = get_parent().get_node("PromptLabel") 
# Ищем тыкву в сцене. get_owner() вернет корневой узел DrummersHouse
@onready var pumpkin_drum = get_owner().get_node("Pumpkin") 
@onready var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
@onready var controller = get_owner()


var player_in_area := false
var is_drum_healed := false

func _ready():
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)
	pumpkin_drum.drum_healed.connect(_on_drum_healed)
	prompt_label.hide()

func _unhandled_input(event):
	if player_in_area and event.is_action_pressed("ui_interact"):
		start_dialogue()

func _on_body_entered(body):
	if body.name == "Player1":
		player_in_area = true
		prompt_label.text = "!"
		prompt_label.show()

func _on_body_exited(body):
	if body.name == "Player1":
		player_in_area = false
		prompt_label.hide()

func _on_drum_healed():
	is_drum_healed = true

func start_dialogue():
	# --- ГЛАВНОЕ ИСПРАВЛЕНИЕ ---
	# Проверяем, встречали ли мы его раньше. Если нет - открываем запись.
	if not GameState.met_grumble:
		GameState.met_grumble = true
		JournalData.unlock_entry("creatures", "grumble")

	if not is_drum_healed:
		await dialogue_ui.start_dialogue(get_pre_quest_dialogue())
	else:
		if not GameState.rhythm_note_found:
			await dialogue_ui.start_dialogue(get_post_quest_dialogue())
			
			GameState.rhythm_note_found = true
			GameState.add_item("rhythm_stone")
			
			if is_instance_valid(controller) and controller.has_method("check_overall_quest_completion"):
				controller.check_overall_quest_completion()
		else:
			await dialogue_ui.start_dialogue(get_already_completed_dialogue())

func get_pre_quest_dialogue():
	return [
		{ "speaker": "Grumble", "text": "Hmph. Another visitor. Don't you see I'm grieving? My drum... the heart of our rhythm... it's cracked. Lost its voice." },
		{ "speaker": "Grumble", "text": "As long as it remains silent, so will I." }
	]

func get_post_quest_dialogue():
	return [
		{ "speaker": "Grumble", "text": "You... you fixed it! Do you hear that? That sound... it's the very heart of the marsh! I haven't heard it in so long." },
		{ "speaker": "Grumble", "text": "Thank you. Here, take this. It is the Rhythm Stone. You've earned it." }
	]

func get_already_completed_dialogue():
	return [{ "speaker": "Grumble", "text": "Thanks to you, the rhythm flows again." }]
