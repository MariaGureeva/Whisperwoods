extends Node2D

const WeaverSpiderScene = preload("res://MysticForest/scenes/Characters/WeaverSpider.tscn")

@onready var player = $Player1
@onready var spider_run_start = $SpiderRunStart
@onready var spider_run_end = $SpiderRunEnd

func _ready():
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if spawn_point:
		player.global_position = spawn_point.global_position
	
	if GameState.spider_is_leading_to_den and not GameState.spider_passage_cutscene_played:
		play_spider_run_cutscene()

func play_spider_run_cutscene():
	player.set_physics_process(true)
	
	GameState.spider_passage_cutscene_played = true
	
	var spider = WeaverSpiderScene.instantiate()
	add_child(spider)
	spider.global_position = spider_run_start.global_position
	if spider.has_method("enable_collision"):
		spider.enable_collision()

	await move_character_to_position(spider, spider_run_end.global_position, 1.2) 
	
	spider.queue_free()
	
	GameState.spider_is_leading_to_den = false 
	print("Путешествие с Пауком завершено!")
	player.set_physics_process(true)

func move_character_to_position(character: CharacterBody2D, target_pos: Vector2, speed_multiplier: float = 1.0):
	if not is_instance_valid(character): return

	var move_speed = 700.0 * speed_multiplier
	var anim_sprite = character.get_node_or_null("AnimatedSprite2D")

	if not is_instance_valid(anim_sprite):
		push_warning("Персонаж %s не имеет AnimatedSprite2D!" % character.name)
		return

	while character.global_position.distance_to(target_pos) > 15.0:
		var direction = character.global_position.direction_to(target_pos)
		character.velocity = direction * move_speed
		
		var walk_anim_name = ""
		if "Weaver" in character.name:
			if abs(direction.x) > 0.1:
				walk_anim_name = "walking right" if direction.x > 0 else "walking left"
			else:
				walk_anim_name = "walking right"
		else: 
			walk_anim_name = "walk"
			if direction.x > 0.05: anim_sprite.flip_h = false
			elif direction.x < -0.05: anim_sprite.flip_h = true
		
		if anim_sprite.sprite_frames.has_animation(walk_anim_name):
			anim_sprite.play(walk_anim_name)
		
		character.move_and_slide()
		await get_tree().physics_frame

	character.velocity = Vector2.ZERO
	character.move_and_slide()
