extends CharacterBody2D

@onready var anim = $AnimatedSprite2D

func _ready():
	anim.play("Idle")

func update_animation(current_velocity: Vector2):
	if not is_instance_valid(anim): return
	
	if current_velocity.length() > 0:
		if abs(current_velocity.x) > abs(current_velocity.y):
			if current_velocity.x > 0:
				anim.play("Walk right") # Имя с пробелом
			else:
				anim.play("Walk left") # Имя с пробелом
		else:
			if current_velocity.y > 0:
				# У вас нет анимации ходьбы вниз, используем Idle
				anim.play("Idle")
			else:
				anim.play("Up")
	else:
		anim.play("Idle")
