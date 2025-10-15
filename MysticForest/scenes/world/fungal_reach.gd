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

func _ready():
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if spawn_point and has_node("Player1"):
		$Player1.global_position = spawn_point.global_position
	
	# --- НОВАЯ, БОЛЕЕ ПРОСТАЯ ЛОГИКА ---
	# Скрипт самого Дедушки решит, когда ему быть видимым
	
	# Логика для пути в деревню
	if GameState.fungal_reach_path_unlocked:
		if is_instance_valid(portal_to_village): portal_to_village.monitoring = true
		if is_instance_valid(portal_web_barrier): portal_web_barrier.hide()
		if is_instance_valid(spiderweb_1): spiderweb_1.hide()
		if is_instance_valid(spiderweb_2): spiderweb_2.hide()
		if is_instance_valid(spiderweb_3): spiderweb_3.hide()
	else:
		spiderweb_1.web_cleared.connect(_on_web_cleared)
		spiderweb_2.web_cleared.connect(_on_web_cleared)
		spiderweb_3.web_cleared.connect(_on_web_cleared)
		if is_instance_valid(portal_to_village): portal_to_village.monitoring = false
		if is_instance_valid(portal_web_barrier): portal_web_barrier.show()

	# Логика для пути в Библиотеку
	if is_instance_valid(after_collapse_layer):
		after_collapse_layer.visible = GameState.act_3_intro_played

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
