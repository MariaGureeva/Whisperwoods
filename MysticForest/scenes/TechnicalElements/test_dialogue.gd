# TestDialogue.gd
extends Node2D

@onready var dialogue_ui = $DialogueUI

func _ready():
	# Диалог с выбором для теста
	var test_dialogue = [
		{
			"speaker": "TEST",
			"text": "Нажми на кнопку",
			"player_choices": ["Кнопка 1", "Кнопка 2", "Кнопка 3"],
			"responses": [
				{ "speaker": "SYSTEM", "text": "Вы нажали кнопку 1" },
				{ "speaker": "SYSTEM", "text": "Вы нажали кнопку 2" },
				{ "speaker": "SYSTEM", "text": "Вы нажали кнопку 3" }
			]
		}
	]
	
	# Запускаем диалог сразу же
	dialogue_ui.start_dialogue(test_dialogue)
