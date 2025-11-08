# ForestHub_Controller.gd
extends Node2D

@export var is_morning_scene: bool = false
@onready var toadling_seed_quest: CharacterBody2D = $Toadling
@onready var player = $Player1
const WeaverSpiderScene = preload("res://MysticForest/scenes/Characters/WeaverSpider.tscn")

func _ready():
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if spawn_point and has_node("Player1"):
		player.global_position = spawn_point.global_position
		
	# --- 2. Логика для Тодлинга (квест 1-го акта) ---
	if is_instance_valid(toadling_seed_quest):
		if is_morning_scene:
			# Если Акт 1 уже пройден ИЛИ Тодлинга уже встречали утром, он не нужен.
			if GameState.post_spring_dialogue_played or GameState.toadling_met_morning:
				print("РЕШЕНИЕ: Прячем Тодлинга, его квест завершен.")
				activate_toadling(false)
			else:
				print("РЕШЕНИЕ: Показываем Тодлинга для квеста с семенами.")
				activate_toadling(true)
		else: # Если это ночная сцена (самый старт игры)
			print("Это ночная сцена, Тодлинг не нужен.")
			activate_toadling(false)
	else:
		print("!!! ВНИМАНИЕ: Узел 'Toadling' не найден в сцене Леса. !!!")
	
	# --- 3. Логика для Паука (квест 3-го акта) ---
	# Этот блок теперь ГАРАНТИРОВАННО выполняется после логики Тодлинга.
	if GameState.spider_is_leading_to_den:
		print("Обнаружено путешествие с Пауком!")
		var path_node = get_node_or_null("SpiderPath")
		if path_node:
			var local_points = path_node.get_children()
			local_points.sort_custom(func(a, b): return a.name < b.name)
			
			var global_index = GameState.spider_leading_path_index
			var path_start_offset = get_path_start_index_for_this_scene()
			var start_index_in_this_scene = global_index - path_start_offset
			
			print("Глобальный индекс: %d, Смещение для сцены: %d, Стартовый локальный индекс: %d" % [global_index, path_start_offset, start_index_in_this_scene])
			
			if start_index_in_this_scene >= 0 and start_index_in_this_scene < local_points.size():
				var spider = spawn_spider_follower()
				if is_instance_valid(spider):
					spider.start_leading_path(local_points, start_index_in_this_scene)
			else:
				print("Путь для этой сцены уже пройден или еще не начался.")


func spawn_spider_follower() -> CharacterBody2D:
	var instance = WeaverSpiderScene.instantiate()
	add_child(instance)
	instance.global_position = player.global_position - Vector2(80, 0) # Чуть позади игрока
	if instance.has_method("enable_collision"): instance.enable_collision()
	return instance

func get_path_start_index_for_this_scene() -> int:
	return 2


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
		GameState.spring_healed = true
		GameState.post_spring_dialogue_played = true
		
		# --- Пропускаем Акт II ---
		GameState.mist_marsh_quest_completed = true
		GameState.fungal_reach_quest_started = true
		GameState.fungal_reach_path_unlocked = true
		GameState.fungal_reach_main_quest_started = true
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
		GameState.spider_quest_started = true
		GameState.spider_quest_completed = true
		GameState.spider_is_following = true
		
		
		# --- Перемещаемся прямо в Лабиринт ---
		GameState.entrance_name = "Spawn_From_Caves" # Имя точки спавна в Лабиринте
		get_tree().change_scene_to_file("res://MysticForest/scenes/world/mushrooms_cave.tscn")
