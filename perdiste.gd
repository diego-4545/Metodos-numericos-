extends Control

func _on_button_pressed() -> void:
	# Aumentamos la batalla actual para la próxima vez
	Global.batalla_actual = 1
	Global.player_hp = 100

	var mundo = Global.mundo_actual
	var batalla = Global.batalla_actual

	
	# Construimos la ruta de la escena
	var ruta_escena = "res://Escenas/Mundo %d/Camino%d.tscn" % [mundo, batalla]
	
	
	# Guardamos el progreso
	Global.guardar_global()
	
	# Cambiamos de escena
	get_tree().change_scene_to_file(ruta_escena)
	print("Cargando Mundo", mundo, "Batalla", batalla)

func _on_button_2_pressed() -> void:
	# Botón "Salir" → solo aumentamos la batalla actual
	Global.batalla_actual = 1
	Global.player_hp = 100

	# Guardamos el progreso
	Global.guardar_global()
	get_tree().quit()

	print("Batalla actual incrementada a", Global.batalla_actual)
