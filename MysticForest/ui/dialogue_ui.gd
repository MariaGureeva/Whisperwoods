extends CanvasLayer

signal dialogue_action(action_name: String)
signal choice_made(choice_index)
signal dialogue_finished

# --- ССЫЛКИ НА УЗЛЫ ---
@onready var portrait_animation = $Panel/Portrait/PortraitAnimation
@onready var text_box = $Panel/text_box
@onready var choice_box = $Panel/choice_box
@onready var buttons = [
	$Panel/choice_box/choice_1,
	$Panel/choice_box/choice_2,
	$Panel/choice_box/choice_3
]
@onready var name_box = $Panel/NameBox
@onready var name_label = $Panel/NameBox/NameLabel

const CHARACTERS = {
	"Toadling": {
		"animations": preload("res://MysticForest/assets/UI/Toadling Talking/ToadlingTalking.tres")
	},
	"Player": { 
		"animations": preload("res://MysticForest/assets/UI/Player talking/PlayerTalking.tres")
	},
	"Maestro Croaker": {
		"animations": preload("res://MysticForest/assets/UI/Maestro talking/MaestroTalking.tres")
	},
	"Lily": {
		"animations": preload("res://MysticForest/assets/UI/Lily talking/Lily talking.tres")
	}
}

var dialogue: Array = []
var current_index := 0
var text_tween: Tween 

func _ready():
	hide()
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	for i in buttons.size():
		buttons[i].pressed.connect(_on_choice_pressed.bind(i))

# --- ОСНОВНЫЕ ФУНКЦИИ ДИАЛОГА ---
func start_dialogue(dialogue_data: Array):
	if not is_inside_tree():
		return

	dialogue = dialogue_data
	current_index = 0
	show()
	get_tree().paused = true
	show_next()

func show_next(entry_override = null):
	kill_text_tween() 
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
		portrait_animation.play("idle")
		text_box.text = entry.get("text", "Choose a response:")
		text_box.visible_ratio = 1.0 # Показываем весь текст сразу
		choice_box.show()
		for i in buttons.size():
			if i < entry.player_choices.size():
				buttons[i].text = entry.player_choices[i]
				buttons[i].show()
				buttons[i].disabled = false
			else:
				buttons[i].hide()
	elif entry.has("text"):
		var speaker_name = entry.get("speaker", null)
		
		# Проверяем, есть ли говорящий и есть ли для него анимации
		if speaker_name and CHARACTERS.has(speaker_name) and CHARACTERS[speaker_name].has("animations"):
			var char_data = CHARACTERS[speaker_name]
			portrait_animation.sprite_frames = char_data.animations
			portrait_animation.show()
			portrait_animation.play("talking") # Начинаем анимацию разговора
			name_box.show()
			name_label.text = speaker_name
		else:
			# Если говорящего нет или для него нет анимаций, скрываем портрет
			portrait_animation.hide()
			name_box.hide()

		# Эта часть теперь выполняется всегда для реплик с текстом
		display_text_animated(entry.text)
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
		
		# Если текст еще печатается - показать его полностью
		if text_box.visible_ratio < 1.0:
			kill_text_tween() # Убиваем анимацию, чтобы она не завершилась сама
			text_box.visible_ratio = 1.0
			_on_text_animation_finished() # Вызываем вручную, чтобы остановить анимацию портрета
		# Если текст уже показан - перейти к следующей реплике
		else:
			show_next()

func end_dialogue():
	hide()
	if get_tree():
		get_tree().paused = false
	emit_signal("dialogue_finished")


# --- НОВЫЕ ФУНКЦИИ ДЛЯ АНИМАЦИИ ТЕКСТА И ПОРТРЕТОВ ---

# Запускает эффект "пишущей машинки"
func display_text_animated(full_text: String):
	text_box.text = full_text
	text_box.visible_ratio = 0.0
	
	kill_text_tween() # Убеждаемся, что предыдущий твин мертв
	
	# Создаем новый Tween для анимации свойства visible_ratio
	text_tween = create_tween()
	# Чем длиннее текст, тем дольше он печатается. Можешь поменять 0.05 на свой вкус.
	text_tween.tween_property(text_box, "visible_ratio", 1.0, full_text.length() * 0.05)
	
	# Когда анимация текста ЗАКОНЧИТСЯ, вызываем функцию, которая сменит анимацию портрета
	text_tween.finished.connect(_on_text_animation_finished)

# Вызывается, когда текст полностью напечатан
func _on_text_animation_finished():
	# Если портрет видим, переключаем его анимацию на "idle" (покой)
	if portrait_animation.visible:
		portrait_animation.play("idle")

# Вспомогательная функция для безопасной остановки анимации текста
func kill_text_tween():
	if text_tween and text_tween.is_valid():
		text_tween.kill()
