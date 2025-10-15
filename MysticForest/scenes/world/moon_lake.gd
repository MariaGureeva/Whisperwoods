extends Node2D

@onready var player = $Player1
@onready var dialogue_ui = $DialogueUI
@onready var ritual_trigger = $RitualTrigger
@onready var moon_reflection = $MoonReflection
@onready var echo_sprite = $EchoSprite

# --- МЫ БОЛЬШЕ НЕ ИСПОЛЬЗУЕМ @ONREADY ЗДЕСЬ ---
# @onready var end_of_act_screen = $EndOfActScreen

func _ready():
	var spawn_point = get_node_or_null(GameState.entrance_name)
	if spawn_point:
		$Player1.global_position = spawn_point.global_position
	
	ritual_trigger.body_entered.connect(_on_ritual_trigger_entered)
	echo_sprite.hide()

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
