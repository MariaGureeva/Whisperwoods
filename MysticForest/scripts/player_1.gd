extends CharacterBody2D

signal damaged

@export var speed = 1000
@export var dash_speed = 600

@onready var animated_sprite = $Player
@onready var attunement_overlay: CanvasLayer = $Attunement_Overlay
@onready var dash_timer = $DashTimer
@onready var dash_cooldown = $DashCooldown

var nearby_totem = null
var is_in_power_zone := false
var attunement_target = null
var can_plant_seeds := false
var nearby_seed_spot: Area2D = null
var is_attuning := false
var is_dashing = false
var can_dash = true

func _physics_process(delta):
	if is_attuning and is_in_power_zone:
		GameState.current_resonance = min(GameState.current_resonance + 25 * delta, GameState.max_resonance)
	
	if not is_dashing:
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
		update_animation(velocity)
	
	move_and_slide()

func _unhandled_input(event):
	if event.is_action_pressed("ui_interact") and is_instance_valid(nearby_totem):
		nearby_totem.emit_signal("activated", nearby_totem)

	if event.is_action_pressed("dodge") and can_dash and not is_dashing:
		start_dash()

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

func start_dash():
	var dash_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if dash_direction == Vector2.ZERO:
		var animation_name = animated_sprite.animation
		if "down" in animation_name: dash_direction = Vector2.DOWN
		elif "up" in animation_name: dash_direction = Vector2.UP
		elif "left" in animation_name: dash_direction = Vector2.LEFT
		elif "right" in animation_name: dash_direction = Vector2.RIGHT
		else: return
		
	can_dash = false
	is_dashing = true
	velocity = dash_direction.normalized() * dash_speed
	set_collision_mask_value(2, false)
	dash_timer.start()
	dash_cooldown.start()

func _on_dash_timer_timeout():
	is_dashing = false
	set_collision_mask_value(2, true)

func _on_dash_cooldown_timeout():
	can_dash = true

func register_seed_spot(spot: Area2D):
	nearby_seed_spot = spot
	spot.set_highlight(true)

func unregister_seed_spot(spot: Area2D):
	if nearby_seed_spot == spot:
		spot.set_highlight(false)
		nearby_seed_spot = null

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("totems"):
		nearby_totem = area
	if area.name == "WhisperSeed":
		GameState.add_item("whisper_seed")
		GameState.seeds_found = true
		area.queue_free()
		print("✅ picked: whisper_seed")

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area == nearby_totem:
		nearby_totem = null

func try_plant_seed():
	if not can_plant_seeds or not nearby_seed_spot or nearby_seed_spot.is_planted:
		return
	if GameState.has_item("whisper_seed"):
		GameState.remove_item("whisper_seed")
		nearby_seed_spot.plant()
		unregister_seed_spot(nearby_seed_spot)

func take_damage():
	print("3. Игрок получил урон! Посылаю сигнал 'damaged'.")
	emit_signal("damaged")
