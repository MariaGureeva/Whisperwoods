extends Area2D

@onready var dialogue_ui = get_tree().current_scene.get_node("DialogueUI")
@onready var scene_root = get_tree().current_scene
@onready var anim_player = $AnimationPlayer

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	# Using groups is safer, but we'll stick to names as you requested.
	if body.name != "Player1":
		return

	# --- THE FIX IS HERE ---
	# We now use the correct item name "whisper_seed" and the has_item function.
	if GameState.has_item("whisper_seed") and not GameState.second_dialogue_played:
		GameState.second_dialogue_played = true
		dialogue_ui.dialogue_action.connect(_on_dialogue_action)
		dialogue_ui.start_dialogue([
			{ "speaker": "Toadling", "text": "Great, you found them!" },
			{ "speaker": "Toadling", "text": "Now let's go, follow me." },
			{ "action": "toadling_leads" } # This action name is fine
		])
	elif not GameState.talked_to_toadling_once:
		GameState.talked_to_toadling_once = true
		JournalData.unlock_entry("creatures", "toadling")
		dialogue_ui.start_dialogue(get_first_dialogue())
	else:
		# This part is correct. It runs if you have talked before but don't have seeds.
		dialogue_ui.start_dialogue([
			{ "speaker": "Toadling", "text": "You still need to find the seeds!" }
		])

func _on_dialogue_action(action_name: String):
	if action_name == "toadling_leads":
		dialogue_ui.dialogue_action.disconnect(_on_dialogue_action)

		await get_tree().create_timer(0.5).timeout

		if anim_player:
			anim_player.play("walk_out")
			await anim_player.animation_finished

		scene_root.get_node("Player1").set_physics_process(true)
		get_tree().change_scene_to_file("res://MysticForest/scenes/world/MurmuringGlade.tscn")

func get_first_dialogue():
	# This dialogue is already in English and looks perfect.
	return [
		{ "speaker": "Toadling", "text": "Whoa! You're not what I expected..." },
		{
			"player_choices": [
				"Who are you?",
				"Keeper of what?",
				"Wrong person?"
			],
			"responses": [
				{ "speaker": "Toadling", "text": "I'm just a humble toad." },
				{ "speaker": "Toadling", "text": "Of the Cabin, obviously!" },
				{ "speaker": "Toadling", "text": "Oops, my bad!" }
			]
		},
		{ "speaker": "Toadling", "text": "Well, whoever you are, you just woke the Cabin." },
		{ "speaker": "Toadling", "text": "Okay, no time for speaking, follow me. BTW, call me Toadling." },
		{ "speaker": "Toadling", "text": "Just before we leave, take some seeds from the Cabin." },
		{ "speaker": "Toadling", "text": "They're somewhere on the bookshelf." }
	]
