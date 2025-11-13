extends Node2D

@onready var dialogue_ui = $DialogueUI
@onready var player = $Player1
@onready var maestro_croaker: CharacterBody2D = $"Maestro Croaker"

@onready var melody_note_1 = $MelodyNote1
@onready var melody_note_2 = $MelodyNote2
@onready var melody_note_3 = $MelodyNote3

@onready var totem_bass = $Totem_Bass
@onready var totem_mid = $Totem_Mid
@onready var totem_treble = $Totem_Treble

@onready var grumble = $Grumble
@onready var lily = $"Lily frog"
@onready var twin_la = $"La frog"
@onready var twin_sol = $"Sol frog"
@onready var concert_pumpkin_drum = $Concert_PumpkinDrum

@onready var pos_grumble = $ConcertPos_Grumble
@onready var pos_lily = $ConcertPos_Lily
@onready var pos_la = $ConcertPos_La
@onready var pos_sol = $ConcertPos_Sol
@onready var pos_pumpkin = $ConcertPosPumpkin
@onready var concert_trigger = $ConcertTrigger

var quest_started := false
var notes_collected_count := 0
var totems_charged_count := 0
var puzzle_sequence = ["bass", "treble", "mid"] 
var player_input_sequence = []
var puzzle_is_active := false

func _ready():
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if spawn_point and has_node("Player1"):
		$Player1.global_position = spawn_point.global_position

	melody_note_1.note_collected.connect(_on_note_collected)
	melody_note_2.note_collected.connect(_on_note_collected)
	melody_note_3.note_collected.connect(_on_note_collected)
	
	totem_bass.totem_pressed.connect(_on_totem_pressed)
	totem_mid.totem_pressed.connect(_on_totem_pressed)
	totem_treble.totem_pressed.connect(_on_totem_pressed)
	
	check_overall_quest_completion()

func start_intro_cutscene():
	if quest_started: return
	quest_started = true
	player.set_physics_process(false)
	await dialogue_ui.start_dialogue(get_intro_dialogue())
	GameState.mist_marsh_quest_started = true
	player.set_physics_process(true)

func _on_note_collected():
	notes_collected_count += 1
	if notes_collected_count >= 3:
		GameState.melody_reconstructed = true
		check_overall_quest_completion()
		
func _on_totem_charged():
	totems_charged_count += 1
	if totems_charged_count >= 3:
		start_harmony_puzzle()

func _on_totem_pressed(note_type: String):
	if not puzzle_is_active: return
	player_input_sequence.append(note_type)
	if player_input_sequence.back() != puzzle_sequence[player_input_sequence.size() - 1]:
		player_input_sequence.clear()
		return
	if player_input_sequence.size() == puzzle_sequence.size():
		solve_harmony_puzzle()

func start_harmony_puzzle():
	await get_tree().create_timer(1.5).timeout
	await dialogue_ui.start_dialogue([{ "speaker": "Forest", "text": "The totems awaken... They show a sequence." }])
	for note in puzzle_sequence:
		if note == "bass": await totem_bass.play_note()
		elif note == "mid": await totem_mid.play_note()
		elif note == "treble": await totem_treble.play_note()
		await get_tree().create_timer(0.5).timeout
	totem_bass.set_puzzle_active(true)
	totem_mid.set_puzzle_active(true)
	totem_treble.set_puzzle_active(true)
	puzzle_is_active = true

func solve_harmony_puzzle():
	puzzle_is_active = false
	totem_bass.set_puzzle_active(false)
	totem_mid.set_puzzle_active(false)
	totem_treble.set_puzzle_active(false)
	GameState.harmony_note_found = true
	await get_tree().create_timer(1.0).timeout
	await dialogue_ui.start_dialogue([
		{ "speaker": "La", "text": "Do you hear that?.. The harmony..." },
		{ "speaker": "Sol", "text": "I hear it. I'm sorry I was so stubborn." },
		{ "speaker": "La", "text": "Thank you, Listener! You've returned our song. Take this for your kindness." }
	])
	GameState.add_item("harmony_shells")
	check_overall_quest_completion()

func check_overall_quest_completion():
	if GameState.mist_marsh_quest_completed:
		setup_peaceful_state()
	elif GameState.rhythm_note_found and GameState.melody_note_found and GameState.harmony_note_found:
		var maestro_interaction_area = maestro_croaker.get_node_or_null("InteractionArea")
		if is_instance_valid(maestro_interaction_area) and maestro_interaction_area.has_method("set_ready_for_concert"):
			maestro_interaction_area.set_ready_for_concert()

func prepare_for_concert():
	grumble.global_position = pos_grumble.global_position
	concert_pumpkin_drum.global_position = pos_pumpkin.global_position
	lily.global_position = pos_lily.global_position
	twin_la.global_position = pos_la.global_position
	twin_sol.global_position = pos_sol.global_position
	
	grumble.show()
	concert_pumpkin_drum.show()
	lily.show()
	twin_la.show()
	twin_sol.show()
	
	concert_trigger.monitoring = true
	concert_trigger.body_entered.connect(_on_concert_trigger_entered)

func _on_concert_trigger_entered(body):
	if body.name == "Player1":
		concert_trigger.set_deferred("monitoring", false)
		complete_marsh_quest()

func complete_marsh_quest():
	GameState.mist_marsh_quest_completed = true
	
	player.get_node("Player").play("default")
	player.set_physics_process(false)
	
	await dialogue_ui.start_dialogue([
		{ "speaker": "Maestro Croaker", "text": "They are all here. The Song is whole again. Listen..." }
	])
	
	maestro_croaker.get_node("AnimatedSprite2D").play("orchestrating")
	grumble.get_node("AnimatedSprite2D").play("play_drums")
	lily.get_node("AnimatedSprite2D").play("play_flute")
	twin_la.get_node("AnimatedSprite2D").play("singing")
	twin_sol.get_node("AnimatedSprite2D").play("singing")
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 4.0)
	
	await get_tree().create_timer(5.0).timeout
	
	var outro_dialogue = [
		{ "speaker": "Maestro Croaker", "text": "The music... it's back! You have a powerful gift, Listener." },
		{ "speaker": "Maestro Croaker", "text": "Take this. It is a piece of the old world. A memory of a song. Perhaps it will help you on your path." }
	]
	await dialogue_ui.start_dialogue(outro_dialogue)
	
	GameState.remove_item("rhythm_stone")
	GameState.remove_item("melody_feather")
	GameState.remove_item("harmony_shells")
	
	GameState.add_item("mirror_shard")
	print("Player received a Mirror Shard!")
	
	player.set_physics_process(true)
	setup_peaceful_state()

func setup_peaceful_state():
	grumble.global_position = pos_grumble.global_position
	concert_pumpkin_drum.global_position = pos_pumpkin.global_position
	lily.global_position = pos_lily.global_position
	twin_la.global_position = pos_la.global_position
	twin_sol.global_position = pos_sol.global_position
	
	grumble.show()
	lily.show()
	twin_la.show()
	twin_sol.show()
	concert_pumpkin_drum.show()
	
	maestro_croaker.get_node("AnimatedSprite2D").play("default")
	grumble.get_node("AnimatedSprite2D").play("default")
	lily.get_node("AnimatedSprite2D").play("default")
	twin_la.get_node("AnimatedSprite2D").play("default")
	twin_sol.get_node("AnimatedSprite2D").play("default")
	
	if is_instance_valid(concert_trigger):
		concert_trigger.monitoring = false
		concert_trigger.hide()
		
	self.modulate = Color.WHITE

func get_intro_dialogue():
	return [
		{ "speaker": "Maestro Croaker", "text": "Hmph. A traveler. We haven't had your kind disturbing our quiet decay for quite some time." },
		{ "speaker": "Maestro Croaker", "text": "Or perhaps... you are not merely a tourist? There is a resonance about you... faint, but familiar." },
		{ "speaker": "Player", "text": "This place... it's so quiet." },
		{ "speaker": "Maestro Croaker", "text": "An astute observation. 'Quiet' is a gentle word for it. We are muted. Silenced. The Great Song of the Marsh, the very pulse of this land, has fractured." },
		{ "speaker": "Maestro Croaker", "text": "It has split into its three core elements: Rhythm, Melody, and Harmony. My finest musicians, once proud, now languish in their homes, their instruments as silent as their spirits." },
		{ "speaker": "Maestro Croaker", "text": "Perhaps a Listener like yourself could coax the music from them once more. Find them. Help them remember their part in the symphony." },
		{ "speaker": "Maestro Croaker", "text": "Then, and only then, can we attempt to perform the Song of Awakening." }
	]
