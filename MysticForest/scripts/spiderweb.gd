# ClearableWeb.gd
extends Sprite2D

# Сигнал, который сообщит контроллеру, что эта паутина очищена
signal web_cleared

# Ссылка на дочернюю зону взаимодействия
@onready var interaction_area = $InteractionArea

var is_cleared := false

func _ready():
	# Подключаемся к сигналам от нашей же зоны взаимодействия
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if not is_cleared and body.name == "Player1":
		# Сообщаем игроку, что мы - цель для Attunement
		body.attunement_target = self

func _on_body_exited(body):
	if body.name != "Player1":
		return
	if body.attunement_target == self:
		body.attunement_target = null

# Эту функцию вызывает игрок
func heal():
	if is_cleared: return
	is_cleared = true
	
	# Отключаем дальнейшее взаимодействие
	interaction_area.monitoring = false
	
	# Красивая анимация исчезновения паутины
	var tween = create_tween()
	# Меняем прозрачность от 1 (видимый) до 0 (невидимый) за 1 секунду
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await tween.finished
	
	# Посылаем сигнал, что мы очищены
	emit_signal("web_cleared")
