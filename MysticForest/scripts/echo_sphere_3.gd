# EchoSphere.gd
extends Area2D

signal echo_collected

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player1":
		emit_signal("echo_collected")
		queue_free()
