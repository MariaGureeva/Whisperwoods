extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	var collision_shape = find_child("CollisionShape2D", true, false)
	
	if is_instance_valid(collision_shape):
		collision_shape.disabled = true

func appear():
	self.show()
	if is_instance_valid(animated_sprite):
		animated_sprite.play("appear")
		await animated_sprite.animation_finished

func take_hit():
	if is_instance_valid(animated_sprite):
		animated_sprite.play("hurt")
		await animated_sprite.animation_finished

func escape():
	if is_instance_valid(animated_sprite):
		animated_sprite.play("escape")
		await animated_sprite.animation_finished
	self.hide()
