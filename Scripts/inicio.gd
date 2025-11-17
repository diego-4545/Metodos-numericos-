extends Control

@onready var boton_nivel = $HBoxContainer/Button3


func _ready():
	Global.cargar_juego()
	PauseMenu.visible = false
	if Global.mundo_actual != 1 or Global.batalla_actual != 1:
		boton_nivel.visible = true
	else:
		boton_nivel.visible = false

func _on_button_pressed():
	Global.mundo_actual = 1
	Global.batalla_actual = 1
	Global.guardar_juego()

	var mundo = Global.mundo_actual
	var batalla = Global.batalla_actual
	
	var ruta_escena = "res://Escenas/Mundo %d/Camino%d.tscn" % [mundo, batalla]
	
	get_tree().change_scene_to_file(ruta_escena)
	print("Cargando Mundo", mundo, "Batalla", batalla)

func _on_button_2_pressed() -> void:
	get_tree().quit()

func _on_button_3_pressed():
	var mundo = Global.mundo_actual
	var batalla = Global.batalla_actual
	
	var ruta_escena = "res://Escenas/Mundo %d/Camino%d.tscn" % [mundo, batalla]
	
	get_tree().change_scene_to_file(ruta_escena)
	print("Cargando Mundo", mundo, "Batalla", batalla)
