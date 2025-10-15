extends Control

func _gui_input(event: InputEvent):
	if event is InputEventMouseMotion:
		print("Мышь сейчас над: ", self.name)
