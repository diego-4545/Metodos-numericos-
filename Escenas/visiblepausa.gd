extends CanvasLayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		visible = not visible
		get_tree().paused = visible

func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menú de inicio (2).tscn")

func _on_button_2_pressed() -> void:
	get_tree().quit()
