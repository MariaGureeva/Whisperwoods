extends Area2D

@onready var prompt_label = get_parent().get_node("PromptLabel") 
@onready var controller = get_owner() 
@onready var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")

var player_in_area := false

func _ready():
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

func _on_body_exited(body):
	if body.name == "Player1":
		player_in_area = false
		prompt_label.hide()

func start_dialogue():
	# --- ГЛАВНОЕ ИСПРАВЛЕНИЕ ---
	if not GameState.met_lily:
		GameState.met_lily = true
		JournalData.unlock_entry("creatures", "lily")

	if GameState.melody_note_found:
		await dialogue_ui.start_dialogue([
			{ "speaker": "Lily", "text": "The melody is so beautiful now, thank you again." }
		])
	elif GameState.melody_reconstructed:
		await dialogue_ui.start_dialogue([
			{ "speaker": "Lily", "text": "You... you did it! You gathered the lights! I can feel the whole song in my heart again!" },
			{ "speaker": "Lily", "text": "Thank you. Here, take this. It is the Melody Feather. It's yours now." }
		])
		
		GameState.melody_note_found = true
		GameState.add_item("melody_feather")
		
		if is_instance_valid(controller) and controller.has_method("check_overall_quest_completion"):
			controller.check_overall_quest_completion()
	else:
		await dialogue_ui.start_dialogue([
			{ "speaker": "Lily", "text": "Hello... My music... it's gone. The melody scattered into faint lights across the marsh." },
			{ "speaker": "Lily", "text": "If only someone could gather those lost lights..." }
		])
