extends Control

func _on_button_pressed():
	var mundo = Global.mundo_actual
	var batalla = Global.batalla_actual
	
	var ruta_escena = "res://Escenas/Mundo %d/Camino%d.tscn" % [mundo, batalla]
	
	get_tree().change_scene_to_file(ruta_escena)
	print("Cargando Mundo", mundo, "Batalla", batalla)

func _on_button_2_pressed() -> void:
	get_tree().quit()
