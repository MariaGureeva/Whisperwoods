extends Area2D

@export_file("*.tscn") var target_scene_path: String
@export var target_spawn_point_name: String



func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Проверяем, что в портал вошел именно игрок
	if body.name == "Player1":
		# 1. Проверяем, что разработчик не забыл настроить портал
		if target_scene_path.is_empty() or target_spawn_point_name.is_empty():
			print("!!! ОШИБКА: Портал не настроен! Укажите Target Scene Path и Target Spawn Point Name в инспекторе. !!!")
			return
			
		print("Переход в сцену: ", target_scene_path)
		print("Игрок появится в точке: ", target_spawn_point_name)
		
		# 2. Используем переменные из Инспектора, а не жестко заданные строки
		GameState.entrance_name = target_spawn_point_name
		get_tree().change_scene_to_file(target_scene_path)
