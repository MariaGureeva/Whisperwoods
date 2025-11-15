extends Area2D

signal activated(totem_node)

@onready var light = $PointLight2D
var active_tween: Tween

func _ready():
	add_to_group("totems")

func glow():
	if active_tween and active_tween.is_running():
		active_tween.kill()
	
	active_tween = create_tween()
	active_tween.tween_property(light, "energy", 2.0, 0.4).set_trans(Tween.TRANS_SINE)
	active_tween.tween_property(light, "energy", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
	# await active_tween.finished - УБРАЛИ ЭТУ СТРОКУ

func activate_permanently():
	if active_tween and active_tween.is_running():
		active_tween.kill()
		
	active_tween = create_tween()
	active_tween.tween_property(light, "energy", 1.5, 0.5) 
