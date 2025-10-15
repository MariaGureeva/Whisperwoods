extends Node2D

@export var is_morning_scene: bool = false
@onready var toadling_seed_quest: CharacterBody2D = $Toadling
@onready var portal_to_glade: Area2D = $Portal_to_MurmuringGlade


func _ready():
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if spawn_point and has_node("Player1"):
		$Player1.global_position = spawn_point.global_position
		
	# --- MAIN STATE LOGIC ---
	if is_morning_scene:
	
		if not GameState.toadling_met_morning:
		
			toadling_seed_quest.set_process(true)
			toadling_seed_quest.set_physics_process(true)
			if toadling_seed_quest.has_node("Area2D"):
				toadling_seed_quest.get_node("Area2D").monitoring = true
			toadling_seed_quest.show()
		else:
			toadling_seed_quest.set_process(false)
			toadling_seed_quest.set_physics_process(false)
			if toadling_seed_quest.has_node("Area2D"):
				toadling_seed_quest.get_node("Area2D").monitoring = false
			toadling_seed_quest.hide()

		if GameState.post_spring_dialogue_played:
			pass
		else:
			pass

	else:
		toadling_seed_quest.set_process(false)
		toadling_seed_quest.set_physics_process(false)
		if toadling_seed_quest.has_node("Area2D"):
			toadling_seed_quest.get_node("Area2D").monitoring = false
		toadling_seed_quest.hide()
		

func _unhandled_input(event):
	# Debug key to skip to Act II
	if event.is_action_pressed("debug_skip_to_act2"):
		print("!!! DEBUG: SKIPPING TO ACT II !!!")
		
		# Set all flags as if Act I was completed
		GameState.spring_healed = true
		GameState.sleep_cutscene_played = true
		GameState.toadling_met_morning = true
		GameState.seeds_found = true
		GameState.attunement_unlocked = true
		GameState.post_spring_dialogue_played = true
		
		# Teleport to the cabin to start Act II
		get_tree().change_scene_to_file("res://MysticForest/scenes/world/CabinInside.tscn")
