extends CharacterBody2D

@onready var interaction_area = $InteractionArea
@onready var prompt_label = $PromptLabel
@onready var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
@onready var anim = $AnimatedSprite2D

var player_in_area := false

func _ready():
	anim.play("Idle")
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	
	prompt_label.hide()
	
	self.visible = GameState.post_spring_dialogue_played

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
		
func update_quest_icon():
	if GameState.post_spring_dialogue_played and not GameState.act2_quest_started:
		# $QuestIcon.show()
		print("Toadling_Guide: Показываю иконку квеста '!'")
	else:
		# $QuestIcon.hide()
		print("Toadling_Guide: Прячу иконку квеста '!'")

func start_dialogue():
	if GameState.mirror_partially_fixed:
		dialogue_ui.start_dialogue(get_moon_lake_dialogue())
	# Если Акт I пройден, но квест на Акт II еще не взят
	elif GameState.post_spring_dialogue_played and not GameState.act2_quest_started:
		GameState.act2_quest_started = true
		dialogue_ui.start_dialogue(get_act2_intro_dialogue())
	# Если квест уже взят
	elif GameState.act2_quest_started:
		dialogue_ui.start_dialogue(get_act2_reminder_dialogue())
		

# --- (Библиотека диалогов будет ниже) ---
func get_moon_lake_dialogue():
	return [
		{ "speaker": "Toadling", "text": "The mirror... it showed you, didn't it? The Moon Lake. It is a place of great power, and a gateway." },
		{ "speaker": "Toadling", "text": "The path was sealed long ago. But the mirror's light has awakened it. Look, over there!" }
	]

func get_act2_intro_dialogue():
	return [
		{ "speaker": "Toadling", "text": "There you are. I was beginning to wonder. The air feels... clearer, doesn't it? That was your doing." },
		{ "speaker": "Toadling", "text": "But healing the spring was just the first step. The heart of the forest, Echo's Grove, is still silent. The path to it is lost." },
		{
			"speaker": "Player",
			"text": "...",
			"player_choices": [
				"Lost? How can a path be lost?",
				"What's so important about this Grove?",
				"So what's the plan?"
			],
			"responses": [
				{ "speaker": "Toadling", "text": "It was woven from memories and magic, not cut from the earth. When memories fade, so does the path. We must find those who still remember." },
				{ "speaker": "Toadling", "text": "It is the source of all life in this wood. The place where Echo... gave himself to the forest. If we can't reach it, the fading will eventually return." },
				{ "speaker": "Toadling", "text": "The plan is to earn the trust of the Old Folk. Their roots run deeper than any tree's. Their memories hold the keys to the path." }
			]
		},
		{ "speaker": "Toadling", "text": "There are two ancient communities nearby. The musical Frogfolk of the Mist Marsh, who sing the songs of the water..." },
		{ "speaker": "Toadling", "text": "...and the silent Mycellians of the Fungal Reach, who speak to the very roots of the world." },
		{ "speaker": "Toadling", "text": "Both are afflicted by the fading. Help them, and they may share their memories with you. Where will you go first?" }
	]

func get_act2_reminder_dialogue():
	# --- Улучшенный диалог-напоминание ---
	
	# (В будущем здесь можно добавить проверку, помогли ли вы уже одной из фракций)
	# if GameState.helped_frogfolk:
	#	return [{ "speaker": "Toadling", "text": "The Mycellians are still waiting for you." }]
	
	return [
		{ "speaker": "Player", "text": "...",
		  "player_choices": [
			"Tell me about the Mist Marsh again.",
			"Tell me about the Fungal Reach again.",
			"I'm on my way."
		  ],
		  "responses": [
			{ "speaker": "Toadling", "text": "The Mist Marsh is home to the Frogfolk. Their songs shape the waters, but a strange silence has fallen upon them. They need a Listener to hear their troubles." },
			{ "speaker": "Toadling", "text": "The Fungal Reach is a network of deep caves. The Mycellians there are wise, but they are plagued by fearful creatures. They need a protector to calm the darkness." },
			{ "speaker": "Toadling", "text": "Good. The forest is counting on you." }
		  ]
		}
	]
