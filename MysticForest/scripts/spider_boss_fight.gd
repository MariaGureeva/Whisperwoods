extends Node2D

@onready var player = $Player1
@onready var hearts_ui = $CanvasLayer/VBoxContainer/HeartsUI
@onready var rage_bar = $CanvasLayer/VBoxContainer/RageBar
@onready var dialogue_ui = $DialogueUI
@onready var spider_king = $"Spider King"
@onready var wave_timer = $WaveTimer
@onready var phase1_objects = $Phase1_Objects

enum Phases { PHASE1, PHASE2, PHASE3, DEFEATED, NONE }
var current_phase = Phases.NONE
var player_lives = 3
var king_rage = 100.0

var phase1_sequence = []
var player_input_sequence = []
var showing_sequence = false
var sequence_length = 3
var rounds_won = 0

func _ready():
	hearts_ui.hide()
	rage_bar.hide()
	phase1_objects.hide()
	start_fight()

func start_fight():
	var intro_dialogue = [
		{ "speaker": "Spider King", "text": "You think that you can heal my hurt with your stupid harmony" },
		{ "speaker": "Spider King", "text": "Then listen to the song of my despair! Drown in it!" }
	]
	await dialogue_ui.start_dialogue(intro_dialogue)

	player.damaged.connect(on_player_damage)
	
	player_lives = 3
	update_hearts_ui()
	hearts_ui.show()
	
	king_rage = 100.0
	rage_bar.max_value = king_rage
	rage_bar.value = king_rage
	rage_bar.show()
	
	change_phase(Phases.PHASE1)

func update_hearts_ui():
	var hearts = hearts_ui.get_children()
	for i in hearts.size():
		if i < player_lives:
			hearts[i].show()
		else:
			hearts[i].hide()

func on_player_damage():
	print("4. Сцена боя получила сигнал! Отнимаю сердце.")
	player_lives -= 1
	update_hearts_ui()
	if player_lives <= 0:
		print("Игрок проиграл!")
		get_tree().reload_current_scene()

func change_phase(new_phase):
	if current_phase == new_phase: return
	current_phase = new_phase
	
	match current_phase:
		Phases.PHASE1:
			start_phase_1()
		Phases.PHASE2:
			start_phase_2()
		Phases.PHASE3:
			start_phase_3()

func start_phase_1():
	phase1_objects.show()
	
	var totems = phase1_objects.get_children()
	for i in totems.size():
		if not totems[i].activated.is_connected(on_totem_activated):
			totems[i].activated.connect(on_totem_activated.bind(i))
	
	wave_timer.start()
	
	sequence_length = 3
	rounds_won = 0
	
	await get_tree().create_timer(1.0).timeout
	generate_next_sequence()

func start_phase_2():
	print("Начало Фазы 2: Сеть Мицелиан")
	phase1_objects.hide()
	wave_timer.stop()

func start_phase_3():
	print("Начало Фазы 3: Взгляд Филина")

func generate_next_sequence():
	player_input_sequence.clear()
	phase1_sequence.clear()
	
	for i in range(sequence_length):
		phase1_sequence.append(randi_range(0, 2))
		
	print("Новая мелодия: ", phase1_sequence)
	show_sequence()

func show_sequence():
	showing_sequence = true
	var totems = phase1_objects.get_children()
	
	await get_tree().create_timer(0.5).timeout
	
	for totem_index in phase1_sequence:
		var totem_to_glow = totems[totem_index]
		totem_to_glow.glow()
		# ИСПРАВЛЕНИЕ: Ждем здесь, а не в коде тотема
		await get_tree().create_timer(1.0).timeout
	
	showing_sequence = false

func on_totem_activated(totem_node):
	if showing_sequence: return

	var totems = phase1_objects.get_children()
	var totem_index = totems.find(totem_node)

	totem_node.glow()
	
	player_input_sequence.append(totem_index)
	
	var current_step = player_input_sequence.size() - 1
	
	if player_input_sequence[current_step] != phase1_sequence[current_step]:
		print("ОШИБКА! Мелодия сброшена.")
		on_player_damage()
		showing_sequence = true
		await get_tree().create_timer(1.0).timeout
		player_input_sequence.clear()
		show_sequence()
		return
	
	if player_input_sequence.size() == phase1_sequence.size():
		print("Мелодия верна!")
		rounds_won += 1
		king_rage -= 10
		rage_bar.value = king_rage
		
		if rounds_won >= 3:
			change_phase(Phases.PHASE2)
		else:
			sequence_length += 1
			await get_tree().create_timer(1.0).timeout
			generate_next_sequence()

func _on_wave_timer_timeout():
	var warning_sprite = Sprite2D.new()
	warning_sprite.texture = preload("res://MysticForest/assets/UI/exclamation.png")
	warning_sprite.global_position = spider_king.global_position
	add_child(warning_sprite)
	
	var tween = create_tween()
	tween.tween_property(warning_sprite, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	await tween.finished
	warning_sprite.queue_free()
	
	var shockwave_scene = preload("res://MysticForest/scenes/TechnicalElements/shockwave.tscn") 
	var new_wave = shockwave_scene.instantiate()
	new_wave.global_position = spider_king.global_position
	add_child(new_wave)
