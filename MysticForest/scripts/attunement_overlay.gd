extends CanvasLayer

@onready var fader_container = $FaderContainer

func _ready():
	fader_container.modulate.a = 0.0

func show_effect():
	print("Vignette effect STARTED!") 
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(fader_container, "modulate:a", 1.0, 0.5)

func hide_effect():
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.tween_property(fader_container, "modulate:a", 0.0, 0.3)
