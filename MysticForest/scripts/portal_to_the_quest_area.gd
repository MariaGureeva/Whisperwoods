extends Area2D

@export_file("*.tscn") var target_scene_path: String
@export var target_spawn_point_name: String

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player1":
		if target_scene_path.is_empty() or target_spawn_point_name.is_empty():
			print("!!! PORTAL ERROR: Portal in scene '", get_tree().current_scene.scene_file_path, "' is not configured! !!!")
			return
			
		print("--- PORTAL ACTIVATED ---")
		print("Current Scene: ", get_tree().current_scene.scene_file_path)
		print("Target Scene: ", target_scene_path)
		print("Spawn Point Name to be set in GameState: '", target_spawn_point_name, "'")
		
		GameState.entrance_name = target_spawn_point_name
		
		print("Check. Name in GameState is now: '", GameState.entrance_name, "'")
		
		get_tree().change_scene_to_file(target_scene_path)
