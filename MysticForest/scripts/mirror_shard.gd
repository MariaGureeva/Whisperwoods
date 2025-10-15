extends Area2D

@onready var dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
@onready var cabin_controller = get_owner()
@onready var cutscene_position_marker = $CutscenePosition


var player_in_area := false
var player_node: CharacterBody2D = null

func _unhandled_input(event):
	if player_in_area and event.is_action_pressed("ui_interact") and GameState.post_spring_dialogue_played:
		if not GameState.mirror_partially_fixed:
			if GameState.inventory.get("mirror_shard", 0) >= 2:
				start_fix_cutscene()

func _on_body_entered(body):
	if body.name == "Player1":
		player_in_area = true
		player_node = body
		if GameState.attunement_unlocked:
			body.is_in_power_zone = true
		if is_instance_valid(cabin_controller) and cabin_controller.has_method("trigger_mirror_dialogue"):
			cabin_controller.trigger_mirror_dialogue()

func _on_body_exited(body):
	if body.name == "Player1":
		player_in_area = false
		player_node = null
		body.is_in_power_zone = false

func start_fix_cutscene():
	if GameState.mirror_partially_fixed: return
	GameState.mirror_partially_fixed = true
	
	if not is_instance_valid(player_node):
		print("ERROR: Player node not found for mirror cutscene.")
		return
	
	self.set_deferred("monitoring", false)
	player_node.set_physics_process(false)
	
	await get_tree().create_timer(1.0).timeout
	
	var tween = create_tween()
	tween.tween_property(player_node, "global_position", cutscene_position_marker.global_position, 2.0)
	await tween.finished
	
	if player_node.has_node("Player"):
		player_node.get_node("Player").play("default")
	
	# --- ИЗМЕНЕНИЕ ЗДЕСЬ ---
	# Забираем 2 осколка
	GameState.remove_item("mirror_shard")
	GameState.remove_item("mirror_shard")
	
	self.modulate = Color.WHITE
	var mirror_tween = create_tween()
	mirror_tween.tween_property(self, "modulate", Color(5, 5, 5), 0.5)
	mirror_tween.tween_property(self, "modulate", Color.WHITE, 1.0)
	await mirror_tween.finished
	
	await dialogue_ui.start_dialogue([
		{ "speaker": "Echo", "text": "<The path remembers... The water reflects what is hidden...>" },
		{ "speaker": "Echo", "text": "<Find the Moon Lake. It is the gate.>" }
	])
	
	player_node.set_physics_process(true)
	self.set_deferred("monitoring", true)
