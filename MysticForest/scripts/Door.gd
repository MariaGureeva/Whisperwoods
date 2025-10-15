extends Area2D

var is_locked := true

func _ready():
	# Подключаем сигнал к самому себе
	body_entered.connect(_on_body_entered)

func unlock():
	is_locked = false
	print("Door has been unlocked!")

func _on_body_entered(body):
	# Если дверь отперта и вошел игрок
	if not is_locked and body.name == "Player1":
		# Устанавливаем точку входа для следующей сцены
		GameState.entrance_name = "SpawnPoint_CabinExit"
		# Переходим в утренний лес
		get_tree().change_scene_to_file("res://MysticForest/scenes/world/ForestScene_Morning.tscn")
