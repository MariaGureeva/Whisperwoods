extends Area2D

signal healed

@onready var prompt_label = $PromptLabel
@onready var wilted_sprite = $WiltedSprite
@onready var bloomed_sprite = $BloomedSprite

var is_healed := false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt_label.hide()
	
	if GameState.post_spring_dialogue_played:
		force_heal()

func _on_body_entered(body):
	if not is_healed and body.name == "Player1":
		body.attunement_target = self
		prompt_label.text = "PRESS E"
		prompt_label.show()

func _on_body_exited(body):
	if not is_healed and body.name == "Player1":
		body.attunement_target = null
		prompt_label.hide()

func heal():
	if is_healed:
		return
	
	force_heal()
	emit_signal("healed")
	
func force_heal():
	if is_healed:
		return
		
	is_healed = true
	wilted_sprite.hide()
	prompt_label.hide()
	bloomed_sprite.show()
	get_node("CollisionShape2D").disabled = true
	print("The flower is healed!")
	
