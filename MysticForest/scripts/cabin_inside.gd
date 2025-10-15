extends Node2D

@onready var dialogue_ui = $DialogueUI
@onready var player = $Player1
@onready var toadling = $Toadling
@onready var mirror = $Mirror
@onready var bed = $Bed
@onready var door = $Door
@onready var screen_fader: CanvasLayer = $ScreenFader
@onready var wilted_flower = $WiltedFlower
@onready var EndOfActScreen = $EndOfActScreen

var mirror_seen = false

var post_spring_dialogue = [
	{ "speaker": "Toadling", "text": "I knew you could do it. I felt the forest take a deep breath for the first time in years." },
	{ "speaker": "Toadling", "text": "But seeing you... hear the Faelights... that confirms it. You are a Listener." },
	{ "speaker": "Player", "text": "A Listener? Toadling, what is this place? What's happening?" },
	{ "speaker": "Toadling", "text": "This is the heart of the old world. A place of magic. It has existed for eons, connected to your world by something called the Mirror Path." },
	{ "speaker": "Toadling", "text": "That path was a bridge, kept strong by belief. By stories. By attention." },
	{ "speaker": "Toadling", "text": "But people... they stopped believing. They forgot. And when they forgot, the path shattered. The magic began to fade." },
	{ "speaker": "Toadling", "text": "The forest is dying because it has been forgotten." },
	{ "speaker": "Toadling", "text": "The last Guardian, Echo, gave everything he had just to keep it breathing, hoping someone like you would find their way here." },
	{ "speaker": "Player", "text": "Echo... I think I saw that name. In a vision." },
	{ "speaker": "Toadling", "text": "He's the one who called you. That broken mirror in this cabin... it's a piece of the old Path. Your task is to find the other pieces." },
	{ "speaker": "Toadling", "text": "By restoring the sacred places, like the spring, you can mend the Path. Maybe... you can even save this world." },
	{ "speaker": "Toadling", "text": "This cabin is your base now. You can rest here when you need to. The forest will be waiting." }
]

func _ready():
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if spawn_point and has_node("Player1"):
		$Player1.global_position = spawn_point.global_position
		
	var fader = get_tree().root.get_node_or_null("SceneTransitionFader")
	if is_instance_valid(fader):
		fader.fade_in_and_destroy()

	if GameState.seeds_found:
		var seed_node = find_child("SeedItem", true, false)
		if is_instance_valid(seed_node):
			seed_node.queue_free()

	if GameState.act_2_completed and not GameState.act_3_intro_played:
		start_act3_intro()
	elif GameState.mirror_partially_fixed:
		setup_act3_state()
	elif GameState.post_spring_dialogue_played:
		setup_act2_state()
	elif GameState.spring_healed:
		start_post_spring_cutscene()
	else:
		setup_first_visit()

func start_act3_intro():
	GameState.act_3_intro_played = true
	await get_tree().create_timer(2.5).timeout
	var camera = player.get_node_or_null("Camera2D")
	if is_instance_valid(camera):
		var tween = create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property(camera, "offset:x", 10.0, 0.1)
		tween.tween_property(camera, "offset:x", -10.0, 0.1)
		tween.tween_property(camera, "offset:x", 10.0, 0.1)
		tween.tween_property(camera, "offset:x", 0.0, 0.1)
		await tween.finished
	
	await dialogue_ui.start_dialogue([
		{ "speaker": "Player", "text": "What was that? It felt... deep. Like something shifted in the caves." }
	])
	
	JournalData.unlock_entry("echos_diary", "path_of_fear")
	setup_act3_state()

func setup_act3_state():
	toadling.hide()
	GameState.attunement_unlocked = true
	mirror.monitoring = true
	bed.monitoring = false
	door.unlock()
	if GameState.seeds_found:
		var seed_node = find_child("SeedItem", true, false)
		if is_instance_valid(seed_node):
			seed_node.queue_free()

func setup_act2_state():
	toadling.hide()
	GameState.attunement_unlocked = true
	mirror.monitoring = true
	bed.monitoring = false
	door.unlock()
	if GameState.seeds_found:
		var seed_node = find_child("SeedItem", true, false)
		if is_instance_valid(seed_node):
			seed_node.queue_free()
	
func start_post_spring_cutscene():
	bed.monitoring = false
	door.monitoring = false
	toadling.show()
	player.set_physics_process(false)
	
	await dialogue_ui.start_dialogue(post_spring_dialogue)
	
	var tutorial_dialogue = [
		{ "speaker": "Toadling", "text": "Ok, now, look at that poor flower. It's fading, just like the rest of the forest." },
		{ "speaker": "Toadling", "text": "But you can help it. Stand near the mirror... the heart of this cabin. Try to 'listen' to its energy." },
		{ "speaker": "Toadling", "text": "(Hint: Stand still and hold Q)" }
	]
	await dialogue_ui.start_dialogue(tutorial_dialogue)
	
	mirror.monitoring = true 
	GameState.attunement_unlocked = true
	player.set_physics_process(true)

	await wilted_flower.healed

	player.set_physics_process(false)

	var final_dialogue = [
		{ "speaker": "Toadling", "text": "You see? This is your gift. You gather the Resonance of the world and share it where it's needed." },
		{ "speaker": "Toadling", "text": "There are many things in this forest that need your help. I will help you to explore it." }
	]
	await dialogue_ui.start_dialogue(final_dialogue)
	
	var act_2_intro_dialogue = [
		{ "speaker": "Toadling", "text": "So... the path forward is not simple. The way to Echo's Grove is overgrown and forgotten." },
		{ "speaker": "Toadling", "text": "But the other forest folk might remember pieces of it. Their memories are older than mine." },
		{
			"speaker": "Player", "text": "...",
			"player_choices": ["What kind of folk?", "So I just... ask them?", "I'm ready. Where do I go?"],
			"responses": [
				{ "speaker": "Toadling", "text": "There are the musical Frogfolk in the Mist Marsh, and the ancient Mycellians deep within the Fungal Reach. Both hold secrets." },
				{ "speaker": "Toadling", "text": "Not just ask. You'll need to help them. The fading affects everyone. Show them you're a friend, and they will help you in return." },
				{ "speaker": "Toadling", "text": "There are two paths from the glade outside. One leads to the swamp, the other to the mushroom caves. The choice is yours." }
			]
		},
		{ "speaker": "Toadling", "text": "Be careful. Not all creatures in the deep woods are as friendly as I am. But don't lose heart. You are the Listener. You belong here now." }
	]
	
	await dialogue_ui.start_dialogue(act_2_intro_dialogue)
	
	GameState.post_spring_dialogue_played = true
	
	dialogue_ui.hide()
	player.set_physics_process(false)
	await $EndOfActScreen.show_and_fade(toadling)
	player.set_physics_process(true)
	
func setup_first_visit():
	toadling.hide()
	GameState.attunement_unlocked = false
	if GameState.sleep_cutscene_played:
		door.unlock()
	else:
		door.body_entered.connect(_on_door_body_entered)

func trigger_mirror_dialogue():
	if not mirror_seen and not GameState.sleep_cutscene_played:
		mirror_seen = true
		mirror.set_deferred("monitoring", false)
		start_mirror_dialogue()

func _on_door_body_entered(body):
	if body.name == "Player1" and mirror_seen:
		door.monitoring = false
		start_door_dialogue_and_sleep()

func start_mirror_dialogue():
	var dialogue = [
		{"speaker": "Player", "text": "Hmm... There's something strange about this mirror."},
		{"speaker": "Player", "text": "It looks like some pieces are missing... I need to find them."}
	]
	await dialogue_ui.start_dialogue(dialogue)

func start_door_dialogue_and_sleep():
	var door_dialogue = [
		{"speaker": "Player", "text": "Huh? Why won’t the door open?"},
		{"speaker": "Player", "text": "What's going on?"}
	]
	await dialogue_ui.start_dialogue(door_dialogue)
	start_sleep_cutscene()
	
func start_sleep_cutscene():
	player.set_physics_process(false)
	
	var sleepy_dialogue = [
		{"speaker": "Player", "text": "I feel... so sleepy... I need to lie down..."},
	]
	await dialogue_ui.start_dialogue(sleepy_dialogue)
	
	# --- ИЗМЕНЕНИЕ ЗДЕСЬ ---
	var target_position = bed.global_position + Vector2(0, -10)
	var speed = 150.0 # Медленная, "сонная" скорость
	var direction = (target_position - player.global_position).normalized()
	
	if player.has_method("update_animation"):
		player.update_animation(direction * speed)
	
	var tween = create_tween()
	tween.tween_property(player, "global_position", target_position, 2.0)
	await tween.finished
	
	if player.has_method("update_animation"):
		player.update_animation(Vector2.ZERO)
	# --- КОНЕЦ ИЗМЕНЕНИЯ ---
	
	await screen_fader.fade_out()
	await get_tree().create_timer(2.0).timeout
	
	GameState.sleep_cutscene_played = true
	door.unlock()
	
	await screen_fader.fade_in()
	player.set_physics_process(true)
