extends Area2D

@onready var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
@onready var controller = get_owner()

var is_ready_for_concert := false

func _ready():
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player1":
		start_dialogue()

func set_ready_for_concert():
	is_ready_for_concert = true

func start_dialogue():
	if is_ready_for_concert and not GameState.mist_marsh_quest_completed:
		self.monitoring = false # Отключаем, чтобы не запустить диалог снова
		await dialogue_ui.start_dialogue(get_concert_invitation_dialogue())
		if is_instance_valid(controller) and controller.has_method("prepare_for_concert"):
			controller.prepare_for_concert()
		is_ready_for_concert = false
	
	elif not GameState.mist_marsh_quest_started:
		self.monitoring = false
		JournalData.unlock_entry("creatures", "maestro_croaker")
		if is_instance_valid(controller) and controller.has_method("start_intro_cutscene"):
			controller.start_intro_cutscene()
		
	elif not is_ready_for_concert and not GameState.mist_marsh_quest_completed:
		# Этот диалог будет повторяться, если игрок подходит в середине квеста
		await dialogue_ui.start_dialogue(get_reminder_dialogue())

func get_concert_invitation_dialogue():
	return [
		{ "speaker": "Maestro Croaker", "text": "You've done it! I can feel all three parts of the Song resonating within you." },
		{ "speaker": "Maestro Croaker", "text": "The musicians have gathered by the Great Mushroom. Go there, Listener. It is time to awaken the marsh!" }
	]

func get_reminder_dialogue():
	return [
		{ "speaker": "Maestro Croaker", "text": "The musicians are still waiting for your help. Find them, and help them remember their song." }
	]
