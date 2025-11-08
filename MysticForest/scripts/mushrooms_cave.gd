extends Node2D

const WeaverSpiderScene = preload("res://MysticForest/scenes/Characters/WeaverSpider.tscn")
@onready var dialogue_ui = $DialogueUI
@onready var player = $Player1
@onready var village_entry_trigger = $VillageEntryTrigger
@onready var reconciliation_trigger = $ReconciliationTrigger

@onready var withered_tree = $WillowDead 
@onready var restored_tree = $WillowAlive
@onready var grandma_npc = $MycellianGrandma
@onready var grandpa_npc = $MycellianGrandpa
@onready var child1_npc = $MycellianBoy
@onready var child2_npc = $MycellianGirl

@onready var player_meeting_point = $PlayerMeetingPoint
@onready var spider_meeting_point = $SpiderMeetingPoint

@onready var grandpa_spawn_point = $ReconciliationTrigger/GrandpaSpawnPoint
@onready var child1_spawn_point = $ReconciliationTrigger/Child1SpawnPoint
@onready var child2_spawn_point = $ReconciliationTrigger/Child2SpawnPoint

var spider_instance: CharacterBody2D = null

func _ready():
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if spawn_point:
		player.global_position = spawn_point.global_position

	# Сценарий 1: Катсцена с Ивой уже была
	if GameState.fungal_reach_final_cutscene_played:
		setup_restored_state()
		if GameState.spider_is_following:
			spider_instance = spawn_spider_follower()
			if not GameState.mycelian_reconciliation_played:
				reconciliation_trigger.body_entered.connect(_on_reconciliation_trigger_entered)
	
	# Сценарий 2: Готовность к катсцене с Ивой
	elif GameState.fungal_reach_quest_completed:
		setup_initial_state()
		village_entry_trigger.body_entered.connect(_on_village_entry)
	
	# Сценарий 3: Первый визит
	else:
		setup_initial_state()
		village_entry_trigger.body_entered.connect(_on_village_entry)

# --- 2. ФУНКЦИИ НАСТРОЙКИ И СПАВНА ---
func setup_initial_state():
	withered_tree.show()
	restored_tree.hide()
	grandma_npc.show()
	grandpa_npc.hide()
	child1_npc.hide()
	child2_npc.hide()

func setup_restored_state():
	withered_tree.hide()
	restored_tree.show()
	village_entry_trigger.monitoring = false
	grandma_npc.show()
	grandpa_npc.hide()
	child1_npc.hide()
	child2_npc.hide()

func spawn_spider_follower() -> CharacterBody2D:
	var spider_spawn_node = get_node_or_null("SpiderSpawnPoint")
	if not spider_spawn_node:
		push_warning("Точка спавна для паука 'SpiderSpawnPoint' не найдена!")
		return null
	
	var instance = WeaverSpiderScene.instantiate()
	add_child(instance)
	instance.global_position = spider_spawn_node.global_position
	
	if instance.has_method("enable_collision"):
		instance.enable_collision()
	if instance.has_method("start_following"):
		instance.start_following(player)
	
	return instance

# --- 3. ТРИГГЕРЫ И СТАРЫЕ КАТСЦЕНЫ ---
func _on_village_entry(body):
	if body != player: return

	if GameState.fungal_reach_quest_completed and not GameState.fungal_reach_final_cutscene_played:
		village_entry_trigger.monitoring = false
		play_final_cutscene()
	elif not GameState.fungal_reach_main_quest_started:
		village_entry_trigger.set_deferred("monitoring", false)
		start_mira_dialogue()

func start_mira_dialogue():
	GameState.fungal_reach_main_quest_started = true
	JournalData.unlock_entry("creatures", "myra")
	player.set_physics_process(false)
	dialogue_ui.start_dialogue(get_mira_dialogue())
	await dialogue_ui.dialogue_finished
	player.set_physics_process(true)

func play_final_cutscene():
	player.set_physics_process(false)
	GameState.fungal_reach_final_cutscene_played = true
	grandma_npc.show(); grandpa_npc.show(); child1_npc.show(); child2_npc.show()
	await get_tree().create_timer(1.0).timeout
	var dialogue = [
		{ "speaker": "Grandma Myra", "text": "<The darkness from the Crystal... it's gone. I can feel the roots breathing again.>" },
		{ "speaker": "Child Mushroom", "text": "<Look! The Great Willow! It's waking up!>" }
	]
	dialogue_ui.start_dialogue(dialogue)
	await dialogue_ui.dialogue_finished
	restored_tree.show(); restored_tree.modulate.a = 0.0
	var tween = create_tween().set_parallel()
	tween.tween_property(restored_tree, "modulate:a", 1.0, 4.0)
	tween.tween_property(withered_tree, "modulate:a", 0.0, 4.0)
	var faelights_node = restored_tree.get_node_or_null("Faelights")
	if faelights_node: tween.tween_callback(func(): faelights_node.emitting = true).set_delay(2.0)
	await tween.finished
	withered_tree.hide()
	var outro_dialogue = [
		{ "speaker": "Elder Spore", "text": "<You have cleansed the heart of our home, Listener. You reminded us that even in the deepest dark, a single light can restore life.>" },
		{ "speaker": "Myra", "text": "<The children feel it too. Their light returns. Take this, as a symbol of our gratitude.>" }
	]
	dialogue_ui.start_dialogue(outro_dialogue)
	await dialogue_ui.dialogue_finished
	GameState.add_item("mirror_shard_fungal")
	player.set_physics_process(true)

# --- 4. НОВАЯ КАТСЦЕНА ПРИМИРЕНИЯ И ЕЕ ЛОГИКА ---
func _on_reconciliation_trigger_entered(body):
	if body != player: return
	if GameState.spider_is_following and not GameState.mycelian_reconciliation_played:
		reconciliation_trigger.set_deferred("monitoring", false)
		play_reconciliation_cutscene()


func play_reconciliation_cutscene():
	player.set_physics_process(false)
	GameState.mycelian_reconciliation_played = true
	
	grandpa_npc.global_position = grandpa_spawn_point.global_position
	child1_npc.global_position = child1_spawn_point.global_position
	child2_npc.global_position = child2_spawn_point.global_position
	grandpa_npc.show(); child1_npc.show(); child2_npc.show()
	
	if is_instance_valid(spider_instance):
		spider_instance.is_in_cutscene = true

	await move_character_to_position(player, player_meeting_point.global_position)
	await move_character_to_position(spider_instance, spider_meeting_point.global_position, 0.9)

	var reconciliation_dialogue = [
		{ "speaker": "Child Mushroom", "text": "<Grandma! Look! The monster is back!>" },
		{ "speaker": "Grandma Myra", "text": "<Stay calm, little one... Listener, what is the meaning of this?>" },
		{ "speaker": "The Weaver", "text": "<I... I mean you no harm. My mind was clouded by fear, but this Listener... they showed me clarity.>" },
		{ "speaker": "The Weaver", "text": "<I cannot undo the terror I caused. I can only ask for your forgiveness.>" },
		{ "speaker": "Grandma Myra", "text": "<Words are easy, Weaver. The fear runs deep in our roots... Listener, you can hear the truth in all things. Show us. Show us what is in its heart.>" },
		{ "action": "show_empathy_flash" },
		{ "speaker": "Elder Spore", "text": "<I see... Not malice, but pain. A pain we all share.>" },
		{ "speaker": "Grandma Myra", "text": "<The Great Willow has been healed. Our children are safe. Perhaps... it is time for all roots to heal. We forgive you, Weaver.>" },
		{ "speaker": "The Weaver", "text": "<Thank you. In return, I shall guide the Listener to my home, Weaver's Den. My King must also learn this peace.>" },
		{ "speaker": "The Weaver", "text": "<Follow me, Listener. I will weave you a path.>" }
	]
	
	dialogue_ui.start_dialogue(reconciliation_dialogue)
	await dialogue_ui.dialogue_finished

	player.set_physics_process(true)
	
	if is_instance_valid(spider_instance):
		spider_instance.is_in_cutscene = false # Выключаем режим катсцены
		
		# 2. Устанавливаем глобальные флаги для путешествия
		GameState.spider_is_leading_to_den = true
		GameState.spider_leading_path_index = 0
		
		# 3. Собираем точки пути из этой сцены (у вас их 4: Point0, Point1, Point2, Point3)
		var path_node = get_node_or_null("SpiderPath")
		if path_node:
			var path_points = path_node.get_children()
			path_points.sort_custom(func(a, b): return a.name < b.name)
			
			# 4. Даем Пауку команду начать вести по этому пути
			spider_instance.start_leading_path(path_points, 0)
		else:
			push_warning("Узел 'SpiderPath' не найден в сцене деревни!")



# --- 5. УНИВЕРСАЛЬНАЯ ФУНКЦИЯ ДВИЖЕНИЯ (ИСПРАВЛЕНА) ---
func move_character_to_position(character: CharacterBody2D, target_pos: Vector2, speed_multiplier: float = 1.0):
	if not is_instance_valid(character): return

	var move_speed = 120.0 * speed_multiplier
	var anim_sprite = character.get_node_or_null("AnimatedSprite2D")

	if not is_instance_valid(anim_sprite):
		push_warning("Персонаж %s не имеет AnimatedSprite2D!" % character.name)
		return

	while character.global_position.distance_to(target_pos) > 10.0:
		var direction = character.global_position.direction_to(target_pos)
		character.velocity = direction * move_speed
		
		var walk_anim_name = ""
		# Логика для Паука с его уникальными анимациями
		if character.name == "WeaverSpider":
			if abs(direction.x) > 0.1:
				walk_anim_name = "walk right" if direction.x > 0 else "walk left"
			else: # Если движется вертикально, используем любую из анимаций ходьбы
				walk_anim_name = "walk right"
		# Логика для Игрока (и любых других) с отражением
		else:
			walk_anim_name = "walk"
			if direction.x > 0.05: anim_sprite.flip_h = false
			elif direction.x < -0.05: anim_sprite.flip_h = true
		
		if anim_sprite.sprite_frames.has_animation(walk_anim_name):
			anim_sprite.play(walk_anim_name)
		
		character.move_and_slide()
		await get_tree().physics_frame

	character.velocity = Vector2.ZERO
	character.move_and_slide()
	
	var idle_anim = "healed" if character.name == "WeaverSpider" else "default"
	if anim_sprite.sprite_frames.has_animation(idle_anim):
		anim_sprite.play(idle_anim)

# --- 6. ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (СТАРЫЕ) ---
func get_mira_dialogue():
	return [
		{ "speaker": "Myra (Elder Sp-re's wife)", "text": "<The Listener... The Elder told us you would come.>" },
		{ "speaker": "Myra", "text": "<Look at our grandchildren... their light fades. The Great Willow that sings them to sleep has lost its voice.>" },
		{ "speaker": "Myra", "text": "<The Lullaby is weak because its very heart, the Heart Crystal deep in the labyrinth, is shrouded in silence.>" },
		{ "speaker": "Myra", "text": "<We fear the Weaver-Spider guards it. Please, find the Crystal. Your gift is our only hope.>" }
	]

func stop_player_animation():
	var anim_player = player.get_node_or_null("AnimatedSprite2D")
	if is_instance_valid(anim_player):
		anim_player.play("idle")
