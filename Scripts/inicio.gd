extends Control

func _on_button_pressed():
	# Tomamos el mundo y la batalla actuales del Global
	var mundo = Global.mundo_actual
	var batalla = Global.batalla_actual
	
	# Construimos la ruta de la escena
	# Por ejemplo: "res://Escenas/Mundo 1/Camino1.tscn"
	var ruta_escena = "res://Escenas/Mundo %d/Camino%d.tscn" % [mundo, batalla]
	
	# Cambiamos de escena
	get_tree().change_scene_to_file(ruta_escena)
	print("Cargando Mundo", mundo, "Batalla", batalla)

func _on_button_2_pressed() -> void:
	get_tree().quit()
