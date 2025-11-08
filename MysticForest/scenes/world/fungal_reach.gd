extends Node2D

@onready var dialogue_ui = $DialogueUI
@onready var player = $Player1
@onready var elder_spore = $MycellianGrandpa

@onready var spiderweb_1 = $Spiderweb1
@onready var spiderweb_2 = $Spiderweb2
@onready var spiderweb_3 = $Spiderweb3
@onready var portal_to_village = $Area2dPortalToVillage
@onready var portal_web_barrier = $SpiderwebForTheCaveEntrance

@onready var after_collapse_layer = $AfterCollapse

var webs_cleared_count := 0
const WeaverSpiderScene = preload("res://MysticForest/scenes/Characters/WeaverSpider.tscn")

func _ready():
	# --- 1. Установка позиции игрока (как было) ---
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if spawn_point:
		player.global_position = spawn_point.global_position

	# --- 2. ВОЗВРАЩАЕМ ВАШУ ИЗНАЧАЛЬНУЮ РАБОЧУЮ ЛОГИКУ ---
	# Этот блок отвечает за квест 2-го акта с паутиной.
	if GameState.fungal_reach_path_unlocked:
		# Если путь уже открыт, просто прячем все препятствия.
		if is_instance_valid(portal_to_village): portal_to_village.monitoring = true
		if is_instance_valid(portal_web_barrier): portal_web_barrier.hide()
		if is_instance_valid(spiderweb_1): spiderweb_1.hide()
		if is_instance_valid(spiderweb_2): spiderweb_2.hide()
		if is_instance_valid(spiderweb_3): spiderweb_3.hide()
	else:
		# Если путь еще не открыт, включаем квест с паутиной.
		spiderweb_1.web_cleared.connect(_on_web_cleared)
		spiderweb_2.web_cleared.connect(_on_web_cleared)
		spiderweb_3.web_cleared.connect(_on_web_cleared)
		if is_instance_valid(portal_to_village): portal_to_village.monitoring = false
		if is_instance_valid(portal_web_barrier): portal_web_barrier.show()

	# Этот блок отвечает за визуал после землетрясения в Акте 3.
	if is_instance_valid(after_collapse_layer):
		after_collapse_layer.visible = GameState.act_3_intro_played
	
	# --- 3. НОВЫЙ ИЗОЛИРОВАННЫЙ БЛОК ДЛЯ ПАУКА ---
	# Этот код выполняется ПОСЛЕ всей основной логики и не мешает ей.
	if GameState.spider_is_leading_to_den:
		var path_node = get_node_or_null("SpiderPath")
		if path_node:
			var local_points = path_node.get_children()
			local_points.sort_custom(func(a, b): return a.name < b.name)
			
			var start_index = GameState.spider_leading_path_index
			
			if start_index < local_points.size():
				var spider = spawn_spider_follower()
				spider.start_leading_path(local_points, start_index)


# --- Новые функции для спавна и пути ---
func spawn_spider_follower() -> CharacterBody2D:
	# Паук всегда спавнится рядом с точкой входа игрока.
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if not spawn_point:
		push_warning("Точка входа игрока для спавна паука не найдена!")
		return null
		
	var instance = WeaverSpiderScene.instantiate()
	add_child(instance)
	# Ставим паука немного позади игрока, чтобы они не застряли друг в друге
	instance.global_position = spawn_point.global_position - Vector2(80, 0)
	
	if instance.has_method("enable_collision"): 
		instance.enable_collision()
		
	return instance


func get_path_start_index_for_this_scene() -> int:
	# Пещеры - первая локация, путь всегда начинается с глобального индекса 0.
	return 2

func _on_web_cleared():
	webs_cleared_count += 1
	if webs_cleared_count >= 3:
		unlock_path()

func unlock_path():
	portal_to_village.monitoring = true
	GameState.fungal_reach_path_unlocked = true
	
	var tween = create_tween()
	tween.tween_property(portal_web_barrier, "modulate:a", 0.0, 1.5)
	await tween.finished
	
	dialogue_ui.start_dialogue([
		{ "speaker": "Mycelial Network", "text": "<The path is clear... We can feel our kin ahead.>" }
	])

func start_intro_cutscene():
	if GameState.fungal_reach_quest_started: return
	GameState.fungal_reach_quest_started = true
	
	player.set_physics_process(false)
	await dialogue_ui.start_dialogue(get_intro_dialogue())
	player.set_physics_process(true)

func get_intro_dialogue():
	return [
		{ "speaker": "Elder Spore", "text": "<A Listener... Welcome.>" },
		{ "speaker": "Elder Spore", "text": "<A strange silence chokes the roots ahead. It blocks the way to our kin.>" },
		{ "speaker": "Elder Spore", "text": "<The three Resonance Crystals are shrouded. Cleanse them with your light, and the path may open.>" }
	]
