extends Area2D

@export_file("*.tscn") var target_scene_path: String
@export var target_spawn_point_name: String

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player1":
		if target_scene_path.is_empty() or target_spawn_point_name.is_empty():
			print("!!! ОШИБКА ПОРТАЛА: Портал в сцене '", get_tree().current_scene.scene_file_path, "' не настроен! !!!")
			return
			
		print("--- ПОРТАЛ АКТИВИРОВАН ---")
		print("Текущая сцена: ", get_tree().current_scene.scene_file_path)
		print("Целевая сцена: ", target_scene_path)
		print("Имя точки спавна, которое будет записано в GameState: '", target_spawn_point_name, "'")
		
		# --- ГЛАВНЫЙ МОМЕНТ ---
		# Устанавливаем НОВОЕ имя точки спавна
		GameState.entrance_name = target_spawn_point_name
		
		# Делаем финальную проверку
		print("Проверка. Имя в GameState теперь: '", GameState.entrance_name, "'")
		
		# Переходим в новую сцену
		get_tree().change_scene_to_file(target_scene_path)
