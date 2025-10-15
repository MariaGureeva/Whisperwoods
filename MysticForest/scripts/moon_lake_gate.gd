# MoonLakeGate.gd
extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var portal = $Portal
@onready var vine_animation_sprite = $GateToTheMoonLake
@onready var collider = $Collider


func _ready():
	if GameState.mirror_partially_fixed:
		open_gate()
	else:
		close_gate()

func open_gate():
	print("Открываю ворота к Лунному Озеру...")
	vine_animation_sprite.show()
	animation_player.play("vines_crawl")
	await animation_player.animation_finished
	
	# После анимации можно скрыть спрайт, т.к. лоз больше нет
	collider.queue_free()
	portal.monitoring = true
	print("Портал к Лунному Озеру активен.")

func close_gate():
	# Показываем спрайт и устанавливаем его на первый кадр (закрытые ворота)
	vine_animation_sprite.show()
	vine_animation_sprite.frame = 0
	collider.show()
	portal.monitoring = false
