# HeartCrystal.gd
extends Area2D

# Сигналы для "режиссера"
signal boss_hit
signal crystal_cleansed

@onready var web_sprite = $WebSprite
@onready var crystal_sprite = $CrystalSprite
@onready var prompt_label = $PromptLabel
@onready var point_light = $PointLight2D

var is_cleansed := false
var is_active := false

func _ready():
	if GameState.fungal_reach_quest_completed:
		force_cleanse()
	else:
		if is_instance_valid(crystal_sprite): crystal_sprite.hide()
		if is_instance_valid(web_sprite): web_sprite.show()

func activate_for_battle():
	if is_cleansed: return
	is_active = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if is_active and body.name == "Player1":
		body.attunement_target = self
		if is_instance_valid(prompt_label): prompt_label.show()

func _on_body_exited(body):
	if is_active and body.name == "Player1":
		body.attunement_target = null
		if is_instance_valid(prompt_label): prompt_label.hide()

func show_hit_feedback():
	if not is_instance_valid(web_sprite): return
	var tween = create_tween()
	tween.tween_property(web_sprite, "modulate", Color(2,2,2), 0.2)
	tween.tween_property(web_sprite, "modulate", Color.WHITE, 0.3)

func cleanse_and_light_up():
	if is_cleansed: return
	is_cleansed = true
	monitoring = false
	if is_instance_valid(prompt_label): prompt_label.hide()
	
	if is_instance_valid(web_sprite):
		var tween_web = create_tween()
		tween_web.tween_property(web_sprite, "modulate:a", 0.0, 1.0)
		await tween_web.finished
		web_sprite.hide()
	
	if is_instance_valid(crystal_sprite):
		crystal_sprite.show()
		var tween_crystal = create_tween()
		tween_crystal.tween_property(crystal_sprite, "modulate", Color(2.5, 2.5, 2.5), 0.2)
		tween_crystal.tween_property(crystal_sprite, "modulate", Color.WHITE, 0.4)
	
	if is_instance_valid(point_light):
		point_light.energy = 1.5
		point_light.enabled = true
	
	emit_signal("crystal_cleansed")

func force_cleanse():
	is_cleansed = true
	monitoring = false
	if is_instance_valid(web_sprite): web_sprite.hide()
	if is_instance_valid(crystal_sprite): crystal_sprite.show()
	if is_instance_valid(prompt_label): prompt_label.hide()
	if is_instance_valid(crystal_sprite): crystal_sprite.modulate = Color.WHITE
	if is_instance_valid(point_light):
		point_light.energy = 1.5
		point_light.enabled = true
		point_light.show()
