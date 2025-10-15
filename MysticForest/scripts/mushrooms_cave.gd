extends Node2D

@onready var dialogue_ui = $DialogueUI
@onready var player = $Player1
@onready var village_entry_trigger = $VillageEntryTrigger

@onready var withered_tree = $WillowDead 
@onready var restored_tree = $WillowAlive
@onready var grandma_npc = $MycellianGrandma
@onready var grandpa_npc = $MycellianGrandpa
@onready var child1_npc = $MycellianBoy
@onready var child2_npc = $MycellianGirl

func _ready():
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if spawn_point and has_node("Player1"):
		$Player1.global_position = spawn_point.global_position

	# --- ИСПРАВЛЕННАЯ ЛОГИКА ---
	# Теперь мы всегда подключаем сигнал, а функция сама решит, что делать
	if is_instance_valid(village_entry_trigger):
		village_entry_trigger.body_entered.connect(_on_village_entry)

	if GameState.fungal_reach_final_cutscene_played:
		setup_restored_state()
	else:
		setup_initial_state()

func setup_restored_state():
	withered_tree.hide()
	restored_tree.show()
	village_entry_trigger.monitoring = false # Отключаем триггер
	grandma_npc.show()
	grandpa_npc.hide()
	child1_npc.hide()
	child2_npc.hide()

# Эта функция больше не нужна, т.к. _on_village_entry теперь умнее
# func setup_pre_cutscene_state():

func setup_initial_state():
	withered_tree.show()
	restored_tree.hide()
	grandpa_npc.hide()
	child1_npc.hide()
	child2_npc.hide()

# --- ОБНОВЛЕННАЯ "УМНАЯ" ФУНКЦИЯ-ТРИГГЕР ---
func _on_village_entry(body):
	if body.name != "Player1": return

	# Если квест с пауком выполнен, но катсцена еще не была...
	if GameState.fungal_reach_quest_completed and not GameState.fungal_reach_final_cutscene_played:
		village_entry_trigger.monitoring = false
		play_final_cutscene()
	# Если это самый первый вход в деревню...
	elif not GameState.fungal_reach_main_quest_started:
		village_entry_trigger.set_deferred("monitoring", false)
		start_mira_dialogue()

func stop_player_animation():
	if player.has_node("Player"): # Проверяем имя вашего AnimatedSprite2D
		player.get_node("Player").play("default")

func start_mira_dialogue():
	GameState.fungal_reach_main_quest_started = true
	JournalData.unlock_entry("creatures", "myra")
	stop_player_animation() # Останавливаем анимацию
	player.set_physics_process(false)
	await dialogue_ui.start_dialogue(get_mira_dialogue())
	player.set_physics_process(true)

func get_mira_dialogue():
	return [
		{ "speaker": "Myra (Elder Sp-re's wife)", "text": "<The Listener... The Elder told us you would come.>" },
		{ "speaker": "Myra", "text": "<Look at our grandchildren... their light fades. The Great Willow that sings them to sleep has lost its voice.>" },
		{ "speaker": "Myra", "text": "<The Lullaby is weak because its very heart, the Heart Crystal deep in the labyrinth, is shrouded in silence.>" },
		{ "speaker": "Myra", "text": "<We fear the Weaver-Spider guards it. Please, find the Crystal. Your gift is our only hope.>" }
	]
	
func play_final_cutscene():
	stop_player_animation() # Останавливаем анимацию
	player.set_physics_process(false)
	GameState.fungal_reach_final_cutscene_played = true

	grandma_npc.show()
	grandpa_npc.show()
	child1_npc.show()
	child2_npc.show()
	
	await get_tree().create_timer(1.0).timeout

	var dialogue = [
		{ "speaker": "Grandma Myra", "text": "<The darkness from the Crystal... it's gone. I can feel the roots breathing again.>" },
		{ "speaker": "Child Mushroom", "text": "<Look! The Great Willow! It's waking up!>" }
	]
	await dialogue_ui.start_dialogue(dialogue)

	restored_tree.show()
	restored_tree.modulate.a = 0.0

	var tween = create_tween().set_parallel()
	tween.tween_property(restored_tree, "modulate:a", 1.0, 4.0)
	tween.tween_property(withered_tree, "modulate:a", 0.0, 4.0)

	var faelights_node = restored_tree.get_node_or_null("Faelights")
	if is_instance_valid(faelights_node):
		tween.tween_callback(func(): faelights_node.emitting = true).set_delay(2.0)
	
	await tween.finished
	
	withered_tree.hide()

	var outro_dialogue = [
		{ "speaker": "Elder Spore", "text": "<You have cleansed the heart of our home, Listener. You reminded us that even in the deepest dark, a single light can restore life.>" },
		{ "speaker": "Myra", "text": "<The children feel it too. Their light returns. Take this, as a symbol of our gratitude.>" }
	]
	await dialogue_ui.start_dialogue(outro_dialogue)
	
	GameState.add_item("mirror_shard")
	print("Игрок получил Осколок Зеркала!")
	
	player.set_physics_process(true)
