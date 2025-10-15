# Labyrinth_Controller.gd
extends Node2D

@onready var act2_objects = $Act2_Objects
@onready var act3_objects = $Act3_Objects

func _ready():
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if spawn_point and has_node("Player1"):
		$Player1.global_position = spawn_point.global_position

	if GameState.owl_quest_started:
		act2_objects.hide()
		act3_objects.show()
	else:
		act2_objects.show()
		act3_objects.hide()
