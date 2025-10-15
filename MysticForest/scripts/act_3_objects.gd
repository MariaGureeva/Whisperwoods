# Act3_Objects.gd  (главный узел сцены Act3_Objects)
extends Node2D

@onready var player = $"../Player1"                          # поправь путь, если надо
@onready var dialogue_ui = $"../DialogueUI"                  # тот же
@onready var spider = $InteractArea/WeaverSpider2
@onready var anchor_flower = $Anchor_Flower
@onready var anchor_branch = $Anchor_Branch
@onready var anchor_crystal = $Anchor_Crystal
@onready var spider_interaction_area = $InteractArea         # Area2D, содержащая паука/интеракт

# структура памяти — состояние каждой точки
var memories = {
	"flower": {
		"node": null, "is_unlocked": false, "is_healed": false,
		"dialogue": {
			"text": "*You feel a memory of helplessness... How do you respond to this fear?*",
			"player_choices": ["Project Strength", "Project Anger", "Project Sanctuary"],
			"correct_choice": 2
		}
	},
	"branch": {
		"node": null, "is_unlocked": false, "is_healed": false,
		"dialogue": {
			"text": "*You feel a memory of burning panic... How do you soothe this flame?*",
			"player_choices": ["Project Logic", "Project Calm", "Project Fear"],
			"correct_choice": 1
		}
	},
	"crystal": {
		"node": null, "is_unlocked": false, "is_healed": false,
		"dialogue": {
			"text": "*You feel a memory of profound loneliness... How do you fill this silence?*",
			"player_choices": ["Project Joy", "Share Presence", "Offer Pity"],
			"correct_choice": 1
		}
	}
}

func _ready():
	print("scene loaded: ", name)

	# инициализируем ноды в memories
	memories.flower.node = anchor_flower
	memories.branch.node = anchor_branch
	memories.crystal.node = anchor_crystal

	# Подключаем сигналы у каждого якоря (Area2D внутри Anchor_*):
	for key in memories.keys():
		var anchor = memories[key].node
		if anchor:
			# безопасное подключение — ищем Area2D внутри якоря, если он там
			var area = anchor if anchor is Area2D else anchor.get_node_or_null("Area2D")
			if area:
				area.body_entered.connect(Callable(self, "_on_anchor_entered").bind(key))
				area.body_exited.connect(Callable(self, "_on_anchor_exited").bind(key))
				anchor.set_meta("player_in_area", false)
			else:
				push_warning("Anchor %s has no Area2D child!" % [key])
		else:
			push_warning("Anchor node for %s is null!" % [key])

	# подключаем триггер паука
	if spider_interaction_area:
		spider_interaction_area.body_entered.connect(_on_spider_entered)
		print("spider_interaction_area.body_entered is connected to _on_spider_entered")
	else:
		push_warning("spider_interaction_area not found!")

	# показываем якоря (если нужно)
	if is_instance_valid(anchor_flower): anchor_flower.show()
	if is_instance_valid(anchor_branch): anchor_branch.show()
	if is_instance_valid(anchor_crystal): anchor_crystal.show()

	# стартовая анимация паука
	if is_instance_valid(spider):
		var spr = spider.get_node_or_null("AnimatedSprite2D")
		if spr:
			spr.play("sorrow")

	# отладочный сброс (можно убрать)
	

# ---------------- Input / interaction ----------------

func _unhandled_input(event):
	if event.is_action_pressed("ui_interact"):
		# пробегаем по якорям и если игрок в зоне — взаимодействуем
		for key in memories.keys():
			var anchor = memories[key].node
			if anchor and anchor.get_meta("player_in_area", false):
				handle_interaction(key)
				# break  # если хочешь одно взаимодействие за нажатие


# ---------------- Spider trigger ----------------

func _on_spider_entered(body):
	print("[SPIDER ENTERED] called for:", body.name)

	if not body: return
	# считаем игроком любой из группы "player" (на случай разных имен)
	if body.is_in_group("player"):
		print(">>> Starting spider intro dialogue")
		# временно отключаем monitoring (чтобы не среагировать повторно)
		spider_interaction_area.set_deferred("monitoring", false)
		await get_tree().create_timer(0.1).timeout
		start_weaver_intro_dialogue()
	elif body.is_in_group("player"): 
	
		print("Quest already started, skipping intro.")


# ---------------- Intro dialogue ----------------

func start_weaver_intro_dialogue():
	print("[START WEAVER DIALOGUE] called")
	if not is_instance_valid(dialogue_ui):
		push_warning("Dialogue UI not found!")
		return

	GameState.spider_quest_started = true
	JournalData.unlock_entry("creatures", "the_weaver")

	if is_instance_valid(player):
		player.set_process_input(false)
		player.set_physics_process(false)

	var dialogue = [
		{ "speaker": "The Weaver", "text": "*As you approach, a voice echoes in your mind, laced with ancient sorrow...*" },
		{ "speaker": "Player", "text": "Weaver? It's you. I freed you from the crystal." },
		{ "speaker": "The Weaver", "text": "Freedom... is not so simple. My body is free, but my mind is still a prisoner." },
		{ "speaker": "The Weaver", "text": "I was sent here, to these lands of mushrooms to... conquer Mycelians." },
		{ "speaker": "The Weaver", "text": "Prepare them for the Great Spider Lord. My people are eager to expand their holdings." },
		{ "speaker": "The Weaver", "text": "But I... I got lost." },
		{ "speaker": "The Weaver", "text": "Shadows... they twisted my path. They imprisoned me here, in this labyrinth." },
		{ "speaker": "The Weaver", "text": "Fear consumed me." },
		{ "speaker": "The Weaver", "text": "My pain has taken root in this place. It clings to the withered flower... the charred branch... the cracked crystal." },
		{ "speaker": "The Weaver", "text": "Soothe these memories for me. Listen to them. Understand them. Only then will I be truly free." }
	]

	# Показываем диалог (диалогный узел внутри сцены выдаст signal dialogue_finished)
	dialogue_ui.start_dialogue(dialogue)
	await dialogue_ui.dialogue_finished
	print("Intro dialogue finished.")
	if is_instance_valid(player):
		player.set_process_input(true)
		player.set_physics_process(true)


# ---------------- Anchor enter/exit ----------------

func _on_anchor_entered(body, key):
	if not body: return
	if body.is_in_group("player"):
		memories[key].node.set_meta("player_in_area", true)
		var prompt = memories[key].node.get_node_or_null("PromptLabel")
		if prompt: prompt.show()
		print("Player entered anchor:", key)

func _on_anchor_exited(body, key):
	if not body: return
	if body.is_in_group("player"):
		memories[key].node.set_meta("player_in_area", false)
		var prompt = memories[key].node.get_node_or_null("PromptLabel")
		if prompt: prompt.hide()
		if is_instance_valid(player):
			player.attunement_target = null
		print("Player exited anchor:", key)


# ---------------- Interaction / empathy ----------------

func handle_interaction(key):
	var memory = memories[key]
	if not memory:
		print("handle_interaction: unknown key", key)
		return

	# Если не разблокировано -> запускаем выбор (диалог с вариантами)
	if not memory.is_unlocked:
		print("handle_interaction: starting empathy dialogue for", key)
		start_empathy_dialogue(key)
		return

	# Если уже разблокировано, но не исцелено -> исцеляем прямо сейчас (для теста/упрощения)
	if memory.is_unlocked and not memory.is_healed:
		print("handle_interaction: healing", key, "directly (no mini-game)")
		await heal(key)
		return

	# Если уже исцелено:
	print("handle_interaction: memory already healed or no action", key)


func start_empathy_dialogue(key):
	var memory = memories[key]
	if not memory:
		return

	print("start_empathy_dialogue for", key)
	# показываем диалог с вариантами — диалогный узел эмитит choice_made
	dialogue_ui.start_dialogue([memory.dialogue])
	var choice = await dialogue_ui.choice_made
	print("player chose:", choice, "for", key)

	if choice == memory.dialogue.correct_choice:
		memory.is_unlocked = true
		# визуальные изменения
		var node = memory.node
		if is_instance_valid(node):
			node.get_node_or_null("Sprite_Withered").hide()
			node.get_node_or_null("Sprite_Glowing").show()

		# дополнительный короткий диалог
		dialogue_ui.start_dialogue([{ "speaker": "The Weaver", "text": "You understand. The memory softens." }])
		await dialogue_ui.dialogue_finished

		# после разблокировки — сразу исцеляем (для простоты)
		print("Unlocked memory", key, "— healing now")
		await heal(key)
	else:
		# неправильный выбор
		dialogue_ui.start_dialogue([{ "speaker": "The Weaver", "text": "No... that is not the way. The memory recoils." }])
		await dialogue_ui.dialogue_finished
		print("Wrong choice for", key)


# ---------------- Heal / completion ----------------

func heal(key) -> void:
	var memory = memories[key]
	if not memory:
		return
	if memory.is_healed:
		return

	# помечаем исцелённым
	memory.is_healed = true
	print("Healed memory:", key)

	# спрячем/анимируем узел
	var node = memory.node
	if is_instance_valid(node):
		node.hide()

	# даём небольшой таймаут для плавности
	await get_tree().create_timer(0.6).timeout

	# проверяем на завершение всех трёх
	check_overall_completion()


func check_overall_completion():
	var all_healed = memories.flower.is_healed and memories.branch.is_healed and memories.crystal.is_healed
	print("check_overall_completion ->", all_healed)
	if all_healed:
		play_final_cutscene()


func play_final_cutscene():
	print("play_final_cutscene called")
	# защита
	if not is_instance_valid(dialogue_ui):
		push_warning("Dialogue UI missing!")
		return

	if is_instance_valid(player):
		player.set_process_input(false)
		player.set_physics_process(false)

	# переключаем анимацию паука
	var spr = spider.get_node_or_null("AnimatedSprite2D")
	if spr:
		spr.play("healed")

	# маленькая пауза
	await get_tree().create_timer(1.0).timeout

	var final_dialogue = [
		{ "speaker": "The Weaver", "text": "The echoes are quiet. My mind is... still. You listened." },
		{ "speaker": "The Weaver", "text": "The wound of the past remains, but it no longer screams. For your empathy, take this. It remembers the mountains before the fear came." }
	]

	dialogue_ui.start_dialogue(final_dialogue)
	await dialogue_ui.dialogue_finished
	print("Final dialogue finished")

	# отметки прогресса
	GameState.spider_quest_completed = true
	GameState.add_item("mirror_shard")
	print("Player received the mirror shard")

	if is_instance_valid(player):
		player.set_process_input(true)
		player.set_physics_process(true)
