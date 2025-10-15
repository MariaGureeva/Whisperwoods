extends Node2D

@onready var dialogue_ui = $DialogueUI
@onready var player = $Player1
@onready var owl_guardian = $Owl
@onready var barrier = $Owl/Barrier
@onready var portal_to_observatory = $PortalToObservatory

# --- НОВЫЕ ССЫЛКИ НА СПРАЙТЫ ВНУТРИ СОВЫ ---
@onready var owl_sprite_sleeping = $Owl/Sprite_Sleeping
@onready var owl_sprite_awake = $Owl/Sprite_Awake

func _ready():
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if spawn_point:
		$Player1.global_position = spawn_point.global_position
	
	if GameState.owl_quest_completed:
		setup_completed_state()
	elif GameState.owl_puzzle_solved and not GameState.owl_quest_completed:
		trigger_final_cutscene()
	elif GameState.owl_quest_started:
		setup_quest_in_progress_state()
	else:
		setup_initial_state()

func setup_completed_state():
	barrier.hide()
	portal_to_observatory.monitoring = true
	# Сразу показываем проснувшуюся сову
	if is_instance_valid(owl_sprite_sleeping): owl_sprite_sleeping.hide()
	if is_instance_valid(owl_sprite_awake): owl_sprite_awake.show()

func setup_quest_in_progress_state():
	barrier.show()
	portal_to_observatory.monitoring = true
	# Убеждаемся, что сова "спит"
	if is_instance_valid(owl_sprite_sleeping): owl_sprite_sleeping.show()
	if is_instance_valid(owl_sprite_awake): owl_sprite_awake.hide()

func setup_initial_state():
	barrier.show()
	portal_to_observatory.monitoring = false
	# Убеждаемся, что сова "спит"
	if is_instance_valid(owl_sprite_sleeping): owl_sprite_sleeping.show()
	if is_instance_valid(owl_sprite_awake): owl_sprite_awake.hide()
	
func start_intro_dialogue():
	if GameState.owl_quest_started: return
	GameState.owl_quest_started = true
	JournalData.unlock_entry("creatures", "owl_guardian")
	
	player.set_physics_process(false)
	var dialogue = [
		{ "speaker": "Player", "text": "This great owl... It's so still. It's like it's listening to something far away." },
		{ "speaker": "Forest", "text": "*A faint, sorrowful whisper echoes in your mind...*" },
		{ "speaker": "Owl Guardian (dream)", "text": "<...the stars... they've lost their voice... The observatory is dark...>" },
		{ "speaker": "Player", "text": "The observatory... It must be upstairs. I need to see what it sees." }
	]
	await dialogue_ui.start_dialogue(dialogue)
	
	unlock_observatory_path()
	player.set_physics_process(true)
	
func unlock_observatory_path():
	portal_to_observatory.monitoring = true

func trigger_final_cutscene():
	if GameState.owl_quest_completed: return
	play_final_owl_cutscene()

func play_final_owl_cutscene():
	player.set_physics_process(false)
	
	var tween = create_tween()
	tween.tween_property(barrier, "modulate:a", 0.0, 1.5)
	await tween.finished
	barrier.hide()
	
	# "Пробуждаем" сову, меняя спрайты
	if is_instance_valid(owl_sprite_sleeping): owl_sprite_sleeping.hide()
	if is_instance_valid(owl_sprite_awake): owl_sprite_awake.show()
	
	var awake_tween = create_tween()
	awake_tween.tween_property(owl_sprite_awake, "modulate", Color(2,2,2), 0.2)
	awake_tween.tween_property(owl_sprite_awake, "modulate", Color.WHITE, 0.3)
	
	await get_tree().create_timer(1.0).timeout
	
	var dialogue = [
		{ "speaker": "Owl Guardian", "text": "The stars... they sing again. You have a quiet heart, Listener. Thank you." },
		{ "speaker": "Owl Guardian", "text": "I have guarded this fragment from the encroaching silence. You have proven worthy. Take it. It is the Heart of the Forest." },
		{ "speaker": "Owl Guardian", "text": "When you woke me, I felt a tremor in the roots of the world. The earth shifted deep within the Fungal Reach." },
		{ "speaker": "Owl Guardian", "text": "The Mycelian Elder, Spore, will know more. Go to him. I feel... a great sorrow stirring in the deep places." },
		{ "speaker": "Owl Guardian", "text": "I have guarded this fragment. You have proven worthy. Take it. It is the Heart of the Forest." }
	]
	
	await dialogue_ui.start_dialogue(dialogue)
	
	GameState.owl_quest_completed = true
	GameState.add_item("mirror_shard") # Убедитесь, что такой предмет есть в "библиотеках" UI
	print("Player received the Forest Heart Shard!")
	
	player.set_physics_process(true)
