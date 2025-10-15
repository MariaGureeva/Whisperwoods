extends Node2D

@onready var player = $Player1
@onready var toadling = $Toadling
@onready var dialogue_ui = $DialogueUI
@onready var seed_spots = [$SeedSpot1, $SeedSpot2, $SeedSpot3]
@onready var spring_before = $SpringBefore
@onready var spring_after = $SpringAfter
@onready var faelights = $SpringAfter/Faelights

var cutscene_started = false
var second_phase_started = false
var seeds_planted = 0

func _ready():
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if spawn_point:
		player.global_position = spawn_point.global_position

	if GameState.spring_healed:
		setup_healed_state()
	else:
		setup_pre_healed_state()

func setup_healed_state():
	spring_before.hide()
	spring_after.show()
	spring_after.play("default")
	faelights.emitting = true
	
	for spot in seed_spots:
		if spot.has_method("force_heal"):
			spot.force_heal()
		spot.monitoring = false
	
	toadling.hide()
	player.set_physics_process(true)

func setup_pre_healed_state():
	spring_before.show()
	spring_after.hide()
	for spot in seed_spots:
		spot.connect("seed_planted", _on_seed_planted)

	if GameState.entrance_name == "SpawnPoint_CabinExit":
		start_second_cutscene()
	else:
		start_cutscene()

func start_cutscene():
	if cutscene_started: return
	cutscene_started = true
	player.set_physics_process(false)
	toadling.set_physics_process(false)
	await move_characters_simultaneously()
	await dialogue_ui.start_dialogue([
		{ "speaker": "Toadling", "text": "This is the source... or what remains of it." },
		{ "speaker": "Toadling", "text": "It used to flow with life, but now it’s dry." },
		{ "speaker": "Toadling", "text": "We must revive it. The seeds from the cabin will help." },
		{ "speaker": "Toadling", "text": "Plant 3 Whisper Seeds around the spring, then focus your energy to awaken the magic. Let's get back to the Cabin." }
	])
	start_planting_phase()

func start_second_cutscene():
	if second_phase_started: return
	second_phase_started = true
	player.set_physics_process(false)
	toadling.set_physics_process(false)
	await move_characters_simultaneously()
	await dialogue_ui.start_dialogue([
		{ "speaker": "Toadling", "text": "Now, plant the Whisper Seeds around the spring." }
	])
	start_planting_phase()

func start_planting_phase():
	player.set_physics_process(true)
	toadling.set_physics_process(false)
	seeds_planted = 0
	player.can_plant_seeds = true
	for spot in seed_spots:
		if spot.has_method("activate_spot"):
			spot.activate_spot()

func _on_seed_planted():
	seeds_planted += 1
	if seeds_planted == 3:
		await dialogue_ui.start_dialogue([
			{ "speaker": "Toadling", "text": "You’ve done it. The source can feel the magic returning..." }
		])
		spring_before.hide() 
		spring_after.show()
		spring_after.play("default")
		faelights.emitting = true
		await get_tree().create_timer(5.0).timeout
		faelights.emitting = false
		await dialogue_ui.start_dialogue([
			{ "speaker": "Toadling", "text": "Wait... you heard their whispers, didn't you? The Faelights from the spring..." },
			{ "speaker": "Toadling", "text": "It's true then. The forest chose you." },
			{ "speaker": "Toadling", "text": "This is... a lot to take in. Let's go back to the cabin. We need to think." }
		])
		_go_to_cabin()

func _go_to_cabin():
	GameState.spring_healed = true 
	get_tree().change_scene_to_file("res://MysticForest/scenes/world/CabinInside.tscn")

func move_characters_simultaneously():
	var source_position = Vector2(2000, -450)
	var player_target_position = source_position + Vector2(-50, 0)
	var speed = 300.0 
	
	var player_direction = (player_target_position - player.global_position).normalized()
	var toadling_direction = (source_position - toadling.global_position).normalized()
	
	if player.has_method("update_animation"):
		player.update_animation(player_direction * speed)
	if toadling.has_method("update_animation"):
		toadling.update_animation(toadling_direction * speed)
	
	var toadling_duration = toadling.global_position.distance_to(source_position) / speed
	var player_duration = player.global_position.distance_to(player_target_position) / speed
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(toadling, "global_position", source_position, toadling_duration)
	tween.tween_property(player, "global_position", player_target_position, player_duration)
	
	await tween.finished
	
	if player.has_method("update_animation"):
		player.update_animation(Vector2.ZERO)
	if toadling.has_method("update_animation"):
		toadling.update_animation(Vector2.ZERO)
