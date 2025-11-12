extends Control

func _on_button_pressed() -> void:
	Global.batalla_actual = 1
	Global.player_hp = 100

	var mundo = Global.mundo_actual
	var batalla = Global.batalla_actual

	
	var ruta_escena = "res://Escenas/Mundo %d/Camino%d.tscn" % [mundo, batalla]
	
	
	Global.guardar_global()
	
	get_tree().change_scene_to_file(ruta_escena)
	print("Cargando Mundo", mundo, "Batalla", batalla)

func _on_button_2_pressed() -> void:
	Global.batalla_actual = 1
	Global.player_hp = 100

	Global.guardar_global()
	get_tree().quit()

	print("Batalla actual incrementada a", Global.batalla_actual)
