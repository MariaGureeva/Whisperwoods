extends CharacterBody2D

@export var speed = 1000
@onready var animated_sprite = $Player
@onready var attunement_overlay: CanvasLayer = $Attunement_Overlay

var is_in_power_zone := false
var attunement_target = null
var can_plant_seeds := false
var nearby_seed_spot: Area2D = null
var is_attuning := false

func update_animation(current_velocity: Vector2):
	if not is_instance_valid(animated_sprite): return

	if current_velocity.length() > 0:
		if abs(current_velocity.x) > abs(current_velocity.y):
			if current_velocity.x > 0:
				animated_sprite.play("walk_right")
			else:
				animated_sprite.play("walk_left")
		else:
			if current_velocity.y > 0:
				animated_sprite.play("walk_down")
			else:
				animated_sprite.play("walk_up")
	else:
		animated_sprite.play("default")

func _physics_process(delta):
	if is_attuning and is_in_power_zone:
		GameState.current_resonance = min(GameState.current_resonance + 25 * delta, GameState.max_resonance)
	
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	velocity = direction.normalized() * speed
	move_and_slide()
	
	update_animation(velocity)
		
func _unhandled_input(event):
	if event.is_action_pressed("ui_interact") and nearby_seed_spot:
		try_plant_seed()
	
	if event.is_action_pressed("ui_interact") and is_instance_valid(attunement_target):
		if attunement_target.has_method("heal"):
			if GameState.current_resonance >= 25:
				GameState.current_resonance -= 25
				attunement_target.heal()
				attunement_target = null
			else:
				print("Not enough resonance!")
	
	if event.is_action_pressed("attunement"):
		if not is_attuning: 
			is_attuning = true
			attunement_overlay.show_effect()
			get_tree().call_group("attunement_listeners", "on_attunement_started")
			get_tree().call_group("echo_objects", "reveal", true)

	if event.is_action_released("attunement"):
		if is_attuning: 
			is_attuning = false
			attunement_overlay.hide_effect()
			get_tree().call_group("attunement_listeners", "on_attunement_stopped")
			get_tree().call_group("echo_objects", "reveal", false)

func register_seed_spot(spot: Area2D):
	nearby_seed_spot = spot
	spot.set_highlight(true)

func unregister_seed_spot(spot: Area2D):
	if nearby_seed_spot == spot:
		spot.set_highlight(false)
		nearby_seed_spot = null

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "WhisperSeed":
		GameState.add_item("whisper_seed")
		GameState.seeds_found = true
		area.queue_free()
		print("✅ picked: whisper_seed")

func try_plant_seed():
	if not can_plant_seeds or not nearby_seed_spot or nearby_seed_spot.is_planted:
		return
	if GameState.has_item("whisper_seed"):
		GameState.remove_item("whisper_seed")
		nearby_seed_spot.plant()
		unregister_seed_spot(nearby_seed_spot)
