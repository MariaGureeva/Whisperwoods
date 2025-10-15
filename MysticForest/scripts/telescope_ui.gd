extends CanvasLayer

signal puzzle_solved

@onready var constellations_node = $Eyepiece/Constellations
@onready var line_container = $Eyepiece/LineContainer

var solution_sequence = ["Star1", "Star2", "Star3"]

var player_input_sequence = []
var last_clicked_star = null
var constellations_solved = 0

func _ready():
	hide()
	for star in constellations_node.get_children():
		if star.has_signal("star_clicked"):
			star.star_clicked.connect(_on_star_clicked)
	
	line_container.width = 2
	line_container.default_color = Color.WHITE

func show_minigame():
	show()
	get_tree().paused = true
	reset_puzzle()

func hide_minigame():
	hide()
	get_tree().paused = false

func _on_star_clicked(star_node):
	if last_clicked_star == null:
		reset_puzzle()
		line_container.add_point(star_node.position)
	else:
		line_container.add_point(star_node.position)
	
	last_clicked_star = star_node
	player_input_sequence.append(star_node.name)
	star_node.set_active(true)
	
	check_player_step()

func check_player_step():
	var current_step_index = player_input_sequence.size() - 1
	
	if current_step_index >= solution_sequence.size() or player_input_sequence[current_step_index] != solution_sequence[current_step_index]:
		reset_puzzle()
		return

	if player_input_sequence.size() == solution_sequence.size():
		print("Созвездие решено!")
		constellations_solved += 1
		
		# --- ГЛАВНОЕ ИСПРАВЛЕНИЕ ---
		# "Говорим" всей игре, что мы решили головоломку
		GameState.owl_puzzle_solved = true
		
		emit_signal("puzzle_solved")
		hide_minigame()

func reset_puzzle():
	player_input_sequence.clear()
	last_clicked_star = null
	
	line_container.clear_points()
		
	for star in constellations_node.get_children():
		if star.has_method("set_active"):
			star.set_active(false)
