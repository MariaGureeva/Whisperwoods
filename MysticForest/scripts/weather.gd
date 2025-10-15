extends Node2D

# --- Переменные для хранения ссылок ---
@onready var weather_controller: AnimationPlayer = $WeatherController
@onready var rain_sound = $RainSound
@onready var rain_tint = $AtmosphereTint
@onready var rainfall = $Rainfall
@onready var weather_timer: Timer = $WeatherTimer

# Список "уличных" сцен, где может идти дождь
# УКАЖИТЕ ЗДЕСЬ ПРАВИЛЬНЫЕ ПУТИ К ВАШИМ СЦЕНАМ!
var outdoor_scenes = [
	"res://MysticForest/scenes/world/ForestScene_Morning.tscn",
	"res://MysticForest/scenes/world/ForestScene.tscn",
	"res://MysticForest/scenes/world/Mist_marsh.tscn",
	"res://MysticForest/scenes/world/The hollow tree.tscn",
]

var is_raining := false

func _ready():
	get_tree().tree_changed.connect(_on_scene_changed.bind(), CONNECT_DEFERRED)
	weather_timer.timeout.connect(_on_weather_timer_timeout)
	
	await get_tree().create_timer(0.1).timeout
	if not is_instance_valid(self): return
	
	_on_weather_timer_timeout()
	_on_scene_changed()

func _on_scene_changed():
	if not get_tree(): return
	await get_tree().process_frame
	if not get_tree(): return
	
	var current_scene = get_tree().current_scene
	if not is_instance_valid(current_scene): return

	if current_scene.scene_file_path in outdoor_scenes:
		show_rain_effects(is_raining)
	else:
		show_rain_effects(false)

# --- ОБНОВЛЕННАЯ ФУНКЦИЯ ---
func show_rain_effects(should_show: bool):
	if should_show:
		if is_instance_valid(rain_sound) and not rain_sound.playing:
			rain_sound.volume_db = 0
			rain_sound.play()
		if is_instance_valid(weather_controller):
			weather_controller.play("Raining")
	else:
		if is_instance_valid(weather_controller): weather_controller.stop()
		if is_instance_valid(rain_sound): rain_sound.stop()
		# Вместо изменения цвета, делаем подложку прозрачной
		if is_instance_valid(rain_tint): rain_tint.modulate.a = 0.0
		if is_instance_valid(rainfall): rainfall.emitting = false

func _on_weather_timer_timeout():
	var chance = randi() % 100
	if is_raining:
		if chance < 70: stop_rain()
		else: reset_timer()
	else:
		if chance < 15: start_rain()
		else: reset_timer()

func start_rain():
	if is_raining: return
	is_raining = true
	if get_tree().current_scene.scene_file_path in outdoor_scenes:
		weather_controller.play("Start_raining")
		await weather_controller.animation_finished
		weather_controller.play("Raining")
	reset_timer()
	
func stop_rain():
	if not is_raining: return
	is_raining = false
	if get_tree().current_scene.scene_file_path in outdoor_scenes:
		weather_controller.play("Stop_raining")
	reset_timer()

func reset_timer():
	if not is_instance_valid(weather_timer): return
	weather_timer.wait_time = randi_range(60, 180)
	weather_timer.start()
