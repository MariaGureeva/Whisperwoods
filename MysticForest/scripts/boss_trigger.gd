extends Area2D

@export var spider: CharacterBody2D
@export var boss_crystal: Area2D
@export var tether1: Line2D
@export var tether2: Line2D
@export var tether3: Line2D

var has_triggered := false
var hits_needed = 3
var current_hits = 0

# --- НОВАЯ ПЕРЕМЕННАЯ ---
# Мы сохраним ссылку на игрока здесь, чтобы не искать его каждый раз
var player_node: CharacterBody2D = null

func _ready():
	if GameState.act_3_intro_played:
		# Просто выключаем себя и прекращаем работу.
		self.monitoring = false
		set_process(false)
		set_physics_process(false)
		set_process_unhandled_input(false)
		return # Выходим из _ready()

	body_entered.connect(_on_body_entered)
	if is_instance_valid(tether1): tether1.hide()
	if is_instance_valid(tether2): tether2.hide()
	if is_instance_valid(tether3): tether3.hide()

	if GameState.fungal_reach_quest_completed:
		if is_instance_valid(spider): spider.hide()
		if boss_crystal.has_method("force_cleanse"):
			boss_crystal.force_cleanse()

func _on_body_entered(body):
	if GameState.act_3_intro_played: return
	if not has_triggered and body.name == "Player1":
		has_triggered = true
		set_deferred("monitoring", false)
		
		# --- ИЗМЕНЕНИЕ ---
		# Сохраняем игрока, который вошел в триггер
		player_node = body
		start_rescue_cutscene()

func start_rescue_cutscene():
	player_node.set_physics_process(false)
	
	await spider.appear()
	
	if is_instance_valid(tether1): tether1.show()
	if is_instance_valid(tether2): tether2.show()
	if is_instance_valid(tether3): tether3.show()
	JournalData.unlock_entry("creatures", "the_weaver")
	
	var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
	await dialogue_ui.start_dialogue([
		{ "speaker": "The Weaver", "text": "*...a weak, desperate thought reaches you...*" },
		{ "speaker": "The Weaver", "text": "<This... Crystal... it traps me... Cleanse it... Free us...>" }
	])
	
	if boss_crystal.has_method("activate_for_battle"):
		boss_crystal.activate_for_battle()
	
	player_node.set_physics_process(true)
	set_process_unhandled_input(true)
	
func _unhandled_input(event):
	# Используем сохраненную ссылку на игрока
	if not is_instance_valid(player_node): return

	if player_node.attunement_target == boss_crystal and event.is_action_pressed("ui_interact"):
		if GameState.current_resonance >= 30:
			GameState.current_resonance -= 30
			_on_crystal_hit()
		else:
			print("Not enough resonance!")

func _on_crystal_hit():
	set_process_unhandled_input(false)
	player_node.set_physics_process(false)

	current_hits += 1
	print("Crystal was hit! Hits: ", current_hits, " of ", hits_needed)
	
	spider.take_hit()
	if boss_crystal.has_method("show_hit_feedback"):
		boss_crystal.show_hit_feedback()
	
	if current_hits == 1 and is_instance_valid(tether1):
		var tween = create_tween()
		tween.tween_property(tether1, "modulate:a", 0.0, 0.5)
	elif current_hits == 2 and is_instance_valid(tether2):
		var tween = create_tween()
		tween.tween_property(tether2, "modulate:a", 0.0, 0.5)
	
	if current_hits < hits_needed:
		var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
		await dialogue_ui.start_dialogue([
			{ "speaker": "The Weaver", "text": "<It hurts... but don't stop... You must continue!>" }
		])
		player_node.set_physics_process(true)
		set_process_unhandled_input(true)
	else:
		_on_crystal_cleansed()

func _on_crystal_cleansed():
	if is_instance_valid(tether3): tether3.hide()
	
	if boss_crystal.has_method("cleanse_and_light_up"):
		await boss_crystal.cleanse_and_light_up()
		
	spider.escape()
	
	var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
	await dialogue_ui.start_dialogue([
		{ "speaker": "The Weaver", "text": "<Thank you... Listener... The silence is broken...>" }
	])
	
	GameState.fungal_reach_quest_completed = true
	GameState.add_item("mirror_shard_fungal")
	print("Fungal Reach quest completed!")
	
	player_node.set_physics_process(true)
	set_process_unhandled_input(false)
