extends Area2D

@onready var boton_nivel = $CanvasLayer/Button


func _on_body_entered(body: Node2D) -> void:
	print("El jugador entró en la zona")
	boton_nivel.visible = true


func _on_body_exited(body: Node2D) -> void:
	print("El jugador salio de la zona")
	boton_nivel.visible = false
