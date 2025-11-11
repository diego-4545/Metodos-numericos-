extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D):
	print("El jugador entró en la zona")



func _on_area_2d_area_exited(area: Area2D):
	print("El jugador salió de la zona")


func _on_button_pressed() -> void:
	var mundo = Global.mundo_actual
	var batalla = Global.batalla_actual
	var ruta_escena = "res://Escenas/Mundo %d/Batalla_%d.tscn" % [mundo, batalla]
	get_tree().change_scene_to_file(ruta_escena)
