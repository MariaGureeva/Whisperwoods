extends Area2D

@export var target_scene : String
@export var entrance_name : String = "default"

func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.name == "Player1":
		GameState.entrance_name = "Spawn_point_from the cave"
		get_tree().change_scene_to_file("res://MysticForest/scenes/world/Fungal_reach.tscn")
