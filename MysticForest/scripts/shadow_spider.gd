extends Area2D

@onready var timer = $Timer
@onready var anim = $AnimatedSprite2D
var player_in_area: CharacterBody2D = null

# Статическая переменная, общая для ВСЕХ пауков этого типа
static var journal_entry_unlocked := false

func _ready():
	# --- ДОБАВЬТЕ ЭТОТ БЛОК ---
	# Если запись в дневнике еще не была открыта...
	if not journal_entry_unlocked:
		# ...открываем ее...
		JournalData.unlock_entry("creatures", "spider_warrior")
		# ...и устанавливаем флаг, чтобы другие пауки этого не делали.
		journal_entry_unlocked = true
	
	anim.play("Idle")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	timer.timeout.connect(_on_timer_timeout)

func _on_body_entered(body):
	if body.name == "Player1":
		player_in_area = body
		timer.start(1.0) 

func _on_body_exited(body):
	if body.name == "Player1":
		player_in_area = null
		timer.stop()

func _on_timer_timeout():
	if is_instance_valid(player_in_area):
		var drain_amount = 10.0
		GameState.current_resonance = max(GameState.current_resonance - drain_amount, 0)
