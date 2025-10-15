extends Area2D

signal totem_pressed(note_type)

@export var note_type: String = "treble"

@onready var sprite = $Sprite2D
@onready var audio_player = $AudioStreamPlayer2D
@onready var light = $PointLight2D
@onready var prompt_label = $PromptLabel
@onready var controller = get_owner()

var is_charged := false
var is_active_in_puzzle := false
var player_in_area := false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	prompt_label.hide()
	light.enabled = false
	sprite.modulate = Color.GRAY

func _unhandled_input(event):
	if player_in_area and is_active_in_puzzle and event.is_action_pressed("ui_interact"):
		emit_signal("totem_pressed", note_type)
		play_note()

func _on_body_entered(body):
	if body.name == "Player1":
		player_in_area = true
		if not is_charged:
			body.attunement_target = self
			prompt_label.text = "PRESS E"
			prompt_label.show()
		elif is_active_in_puzzle:
			prompt_label.text = "PRESS E"
			prompt_label.show()

func _on_body_exited(body):
	if body.name == "Player1":
		player_in_area = false
		prompt_label.hide()
		if body.attunement_target == self:
			body.attunement_target = null

func heal():
	if is_charged: return
	is_charged = true
	prompt_label.hide()
	
	sprite.modulate = Color.WHITE
	
	# --- ИЗМЕНЕНИЕ ЗДЕСЬ ---
	# Принудительно делаем свет ярким при зарядке
	light.energy = 1.5 
	light.enabled = true
	
	print("Тотем '", note_type, "' заряжен!")
	if controller.has_method("_on_totem_charged"):
		controller._on_totem_charged()

func play_note():
	var was_lit_before = light.enabled
	
	# --- ИЗМЕНЕНИЕ ЗДЕСЬ ---
	# Принудительно делаем свет ОЧЕНЬ ярким на время ноты
	light.energy = 2.5 
	light.enabled = true
	
	if is_instance_valid(audio_player):
		audio_player.play()
		await audio_player.finished
	else:
		await get_tree().create_timer(0.5).timeout
	
	# Возвращаем свет в исходное состояние (яркий, если заряжен)
	light.energy = 1.5 
	light.enabled = was_lit_before

func set_puzzle_active(active: bool):
	is_active_in_puzzle = active
