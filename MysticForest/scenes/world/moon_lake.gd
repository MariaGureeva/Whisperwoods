extends Node2D

@onready var player = $Player1
@onready var dialogue_ui = $DialogueUI
@onready var ritual_trigger = $RitualTrigger
@onready var moon_reflection = $MoonReflection
@onready var echo_sprite = $EchoSprite
const WeaverSpiderScene = preload("res://MysticForest/scenes/Characters/WeaverSpider.tscn")
@onready var portal_to_weavers_passage = $"Portal to the path to spiders"
@onready var portal_barrier = $Barrier


func _ready():
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if spawn_point:
		$Player1.global_position = spawn_point.global_position
	
	ritual_trigger.body_entered.connect(_on_ritual_trigger_entered)
	echo_sprite.hide()
	
	if GameState.spider_quest_completed:
		print("Квест паука завершен. Путь к Тропе Пауков открыт.")
		portal_to_weavers_passage.monitoring = true
		portal_barrier.get_node("CollisionShape2D").disabled = true
		portal_barrier.hide()
	else:
		print("Квест паука еще не завершен. Путь к Тропе Пауков закрыт.")
		portal_to_weavers_passage.monitoring = false
		portal_barrier.get_node("CollisionShape2D").disabled = false
		portal_barrier.show() 

	
	if GameState.spider_is_leading_to_den:
		var path_node = get_node_or_null("SpiderPath")
		if path_node:
			var local_points = path_node.get_children()
			local_points.sort_custom(func(a, b): return a.name < b.name)
			
			var global_index = GameState.spider_leading_path_index
			var start_index_in_this_scene = global_index - get_path_start_index_for_this_scene()
			
			if start_index_in_this_scene >= 0 and start_index_in_this_scene < local_points.size():
				var spider = spawn_spider_follower()
				spider.start_leading_path(local_points, start_index_in_this_scene)


func spawn_spider_follower() -> CharacterBody2D:
	var instance = WeaverSpiderScene.instantiate()
	add_child(instance)
	instance.global_position = player.global_position - Vector2(80, 0)
	if instance.has_method("enable_collision"): instance.enable_collision()
	return instance

func get_path_start_index_for_this_scene() -> int:
	return 4

func _on_ritual_trigger_entered(body):
	if body.name == "Player1" and not GameState.act_2_completed:
		ritual_trigger.set_deferred("monitoring", false)
		play_final_act2_cutscene()



func play_final_act2_cutscene():
	GameState.act_2_completed = true
	player.set_physics_process(false)
	player.get_node("Player").play("default")
	
	var reflection_tween = create_tween()
	reflection_tween.tween_property(moon_reflection, "modulate", Color(3, 3, 3), 2.0)
	
	echo_sprite.show()
	echo_sprite.modulate.a = 0.0
	var echo_tween = create_tween()
	echo_tween.tween_property(echo_sprite, "modulate:a", 1.0, 2.0)
	
	var dialogue = [
		{ "speaker": "Echo", "text": "You... hear me so clearly. You have come far, Listener." },
		{ "speaker": "Echo", "text": "You healed the wounds of forgetfulness. But to fully restore the Path, you must now heal the wounds of fear." },
		{ "speaker": "Echo", "text": "Two great spirits, older than I, guard the final fragments of the Mirror. Their hearts are clouded by sorrow from your world." },
		{ "speaker": "Echo", "text": "Seek the **Hollow Tree Library**, where the **Owl Guardian** sleeps, dreaming of a silent sky. Wake him, and learn." },
		{ "speaker": "Echo", "text": "Then, seek the deep caves where the **Weaver-Spider** spins her web of fright. Soothe her, and understand." },
		{ "speaker": "Echo", "text": "Only when both trust you, will the way to my Grove be revealed." }
	]
	
	await dialogue_ui.start_dialogue(dialogue)
	
	echo_tween.tween_property(echo_sprite, "modulate:a", 0.0, 2.0)
	await echo_tween.finished
	echo_sprite.hide()
	
	var reflection_fade_tween = create_tween()
	reflection_fade_tween.tween_property(moon_reflection, "modulate", Color.WHITE, 2.0)
	
	# --- ГЛАВНОЕ ИСПРАВЛЕНИЕ ---
	# 1. Находим узел по его скрипту, а не по имени
	var end_of_act_screen = get_tree().get_first_node_in_group("end_of_act_screen_group")
	
	# 2. Добавляем проверку на случай, если он не найден
	if not is_instance_valid(end_of_act_screen):
		print("!!! КРИТИЧЕСКАЯ ОШИБКА: Не могу найти EndOfActScreen! !!!")
		# В этом случае просто телепортируемся, чтобы игра не зависла
		GameState.entrance_name = "SpawnPoint_Bed"
		get_tree().change_scene_to_file("res://MysticForest/scenes/world/CabinInside.tscn")
		return

	# 3. Запускаем катсцену
	await end_of_act_screen.fade_to_black_and_hold()
	
	end_of_act_screen.reparent(get_tree().root)
	
	GameState.entrance_name = "SpawnPoint_Bed"
	get_tree().change_scene_to_file("res://MysticForest/scenes/world/CabinInside.tscn")
