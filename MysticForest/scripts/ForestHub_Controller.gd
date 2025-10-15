# ForestHub_Controller.gd
extends Node2D

@export var is_morning_scene: bool = false

@onready var toadling_seed_quest: CharacterBody2D = $Toadling

func _ready():
	print("--- ForestHubController ЗАПУЩЕН ---")
	
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if spawn_point and has_node("Player1"):
		$Player1.global_position = spawn_point.global_position
		
	if not is_instance_valid(toadling_seed_quest):
		print("!!! ОШИБКА: Узел 'Toadling' не найден. !!!")
		return

	if is_morning_scene:
		print("Это утренняя сцена. Проверяем GameState...")
		
		# --- ГЛАВНАЯ ПРОВЕРКА ---
		# Если Акт I УЖЕ ПОЛНОСТЬЮ ЗАВЕРШЕН...
		if GameState.post_spring_dialogue_played:
			# ...тогда этот Тодлинг здесь больше НИКОГДА не появится.
			print("РЕШЕНИЕ: Акт II начался. Тодлинг для квеста с семенами здесь больше не нужен.")
			activate_toadling(false)
			return # Важно: выходим из функции, чтобы код ниже не сработал

		# --- СТАРАЯ ЛОГИКА (сработает, только если Акт I НЕ завершен) ---
		print("GameState.toadling_met_morning = ", GameState.toadling_met_morning)
		if not GameState.toadling_met_morning:
			print("РЕШЕНИЕ: Показать Тодлинга для квеста с семенами.")
			activate_toadling(true)
		else:
			print("РЕШЕНИЕ: Спрятать Тодлинга, так как квест уже выполнен.")
			activate_toadling(false)
	else:
		# --- ЛОГИКА ДЛЯ НОЧНОЙ СЦЕНЫ ---
		print("Это ночная сцена. Сбрасываем GameState и прячем Тодлинга.")
		GameState.reset_for_new_game()
		activate_toadling(false)

func activate_toadling(is_active: bool):
	if not is_instance_valid(toadling_seed_quest):
		return

	if is_active:
		toadling_seed_quest.set_process(true)
		toadling_seed_quest.set_physics_process(true)
		if toadling_seed_quest.has_node("Area2D"):
			toadling_seed_quest.get_node("Area2D").monitoring = true
		toadling_seed_quest.show()
	else:
		toadling_seed_quest.set_process(false)
		toadling_seed_quest.set_physics_process(false)
		if toadling_seed_quest.has_node("Area2D"):
			toadling_seed_quest.get_node("Area2D").monitoring = false
		toadling_seed_quest.hide()

func _unhandled_input(event):
	if event.is_action_pressed("debug_skip_to_act2"):
		print("!!! DEBUG: SKIPPING TO ACT II !!!")
		
		GameState.reset_for_new_game()
		GameState.spring_healed = true
		GameState.sleep_cutscene_played = true
		GameState.toadling_met_morning = true
		GameState.seeds_found = true
		GameState.attunement_unlocked = true
		GameState.post_spring_dialogue_played = true
		
		get_tree().change_scene_to_file("res://MysticForest/scenes/world/CabinInside.tscn")
	
	if event.is_action_pressed("debug_skip_to_mirror"):
		print("!!! DEBUG: SKIPPING TO MIRROR CUTSCENE !!!")
		GameState.reset_for_new_game()
		
		# --- ПРОПУСКАЕМ ВЕСЬ АКТ I ---
		GameState.spring_healed = true
		GameState.sleep_cutscene_played = true
		GameState.toadling_met_morning = true
		GameState.seeds_found = true
		GameState.attunement_unlocked = true
		GameState.post_spring_dialogue_played = true
		
		# --- "ПРОХОДИМ" ОБА КВЕСТА АКТА II ---
		# Квест Болот
		GameState.mist_marsh_quest_started = true
		GameState.rhythm_note_found = true
		GameState.melody_reconstructed = true
		GameState.melody_note_found = true
		GameState.harmony_note_found = true
		GameState.mist_marsh_quest_completed = true
		
		# Квест Пещер
		GameState.fungal_reach_quest_started = true
		GameState.fungal_reach_path_unlocked = true # <-- ВАЖНЫЙ ФЛАГ
		GameState.fungal_reach_main_quest_started = true
		GameState.fungal_reach_quest_completed = true
		GameState.fungal_reach_final_cutscene_played = true
		
		# Добавляем осколки в инвентарь
		GameState.add_item("mirror_shard", 2)
		
		# Перемещаемся в хижину
		get_tree().change_scene_to_file("res://MysticForest/scenes/world/CabinInside.tscn")

	if event.is_action_pressed("debug_skip_to_spider"):
		print("!!! DEBUG: SKIPPING TO SPIDER QUEST (ACT III) !!!")
		GameState.reset_for_new_game()
		
		# --- Пропускаем Акт I ---
		GameState.spring_healed = true
		GameState.sleep_cutscene_played = true
		GameState.toadling_met_morning = true
		GameState.seeds_found = true
		GameState.attunement_unlocked = true
		GameState.post_spring_dialogue_played = true
		
		# --- Пропускаем Акт II ---
		GameState.mist_marsh_quest_completed = true
		GameState.fungal_reach_quest_completed = true
		GameState.add_item("mirror_shard", 2)
		GameState.mirror_partially_fixed = true
		GameState.moon_lake_path_unlocked = true
		GameState.act_2_completed = true
		
		# --- "Проходим" квест Совы в Акте III ---
		GameState.act_3_intro_played = true
		GameState.owl_quest_started = true
		GameState.owl_puzzle_solved = true
		GameState.owl_quest_completed = true
		GameState.add_item("mirror_shard") # Выдаем награду от Совы
		
		# --- Перемещаемся прямо в Лабиринт ---
		GameState.entrance_name = "Spawn_From_Caves" # Имя точки спавна в Лабиринте
		get_tree().change_scene_to_file("res://MysticForest/scenes/world/LabyrinthOfShadows.tscn")
