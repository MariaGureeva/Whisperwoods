extends Area2D

@onready var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
@onready var controller = get_owner()

var player_in_area := false

func _ready():
	if GameState.owl_quest_completed and not GameState.spider_quest_started:
		get_parent().show()
	elif not GameState.fungal_reach_quest_completed:
		get_parent().show()
	else:
		get_parent().hide()
		return
		
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player1":
		player_in_area = true
		
		# --- ГЛАВНОЕ ИСПРАВЛЕНИЕ ---
		# Если это САМАЯ ПЕРВАЯ встреча (для квеста Акта II)
		if not GameState.fungal_reach_quest_started:
			# Сразу запускаем диалог АВТОМАТИЧЕСКИ
			start_dialogue()
		# Если это встреча для квеста Акта III
		elif GameState.owl_quest_completed and not GameState.spider_quest_started:
			# Тоже запускаем диалог АВТОМАТИЧЕСКИ
			start_dialogue()
		else:
			# Во всех остальных случаях просто показываем подсказку "!"
			# (если у вас есть PromptLabel)
			# get_parent().get_node("PromptLabel").show()
			pass

func _on_body_exited(body):
	if body.name == "Player1":
		player_in_area = false
		# get_parent().get_node("PromptLabel").hide()

func _unhandled_input(event):
	# Взаимодействие по 'E' сработает, ТОЛЬКО если игрок уже говорил с ним хотя бы раз
	if player_in_area and GameState.fungal_reach_quest_started and event.is_action_pressed("ui_interact"):
		start_dialogue()

func start_dialogue():
	# Сценарий 1: Акт III, выдача квеста на Паука
	if GameState.owl_quest_completed and not GameState.spider_quest_started:
		self.monitoring = false # Отключаем, чтобы не повторялось автоматически
		GameState.spider_quest_started = true
		await dialogue_ui.start_dialogue(get_spider_quest_dialogue())
		get_parent().hide()
	
	# Сценарий 2: Акт II, самый первый диалог
	elif not GameState.fungal_reach_quest_started:
		self.monitoring = false # Отключаем, чтобы не повторялось автоматически
		JournalData.unlock_entry("creatures", "elder_spore")
		if is_instance_valid(controller) and controller.has_method("start_intro_cutscene"):
			controller.start_intro_cutscene()
			
	# Сценарий 3: Если игрок говорит с ним в середине Акта II
	else:
		await dialogue_ui.start_dialogue(get_reminder_dialogue())

func get_spider_quest_dialogue():
	return [
		{ "speaker": "Elder Spore", "text": "<The Owl Guardian sent you... I feel it. The roots tremble.>" },
		{ "speaker": "Elder Spore", "text": "<The tremor you felt... it was not a rockfall. It was a memory, breaking free.>" },
		{ "speaker": "Elder Spore", "text": "<The Weaver-Spider is trapped in the Labyrinth of Shadows, not by stone, but by its own sorrow.>" },
		{ "speaker": "Elder Spore", "text": "<Go, Listener. Don't fight the darkness. Listen to it.>" }
	]

func get_reminder_dialogue():
	return [{ "speaker": "Elder Spore", "text": "<The path to our kin is still blocked. Cleanse the Resonance Crystals.>" }]
