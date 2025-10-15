extends Node2D


func _ready():
	GameState.reset_for_new_game()
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if spawn_point and has_node("Player1"):
		$Player1.global_position = spawn_point.global_position
		
		

func _unhandled_input(event):
	if event.is_action_pressed("debug_skip_to_act2"):
		print("!!! ACT 2 STARTING !!!")
		GameState.spring_healed = true
		GameState.sleep_cutscene_played = true
		GameState.toadling_met_morning = true
		GameState.attunement_unlocked = true
		GameState.post_spring_dialogue_played = true
		get_tree().change_scene_to_file("res://MysticForest/scenes/world/CabinInside.tscn")
