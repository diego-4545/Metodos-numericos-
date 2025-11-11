extends CharacterBody2D

const VELOCIDAD = 200
@onready var animj = $Jugador

func _physics_process(delta):
	var movimiento = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		movimiento.x += 1
		animj.play("MoverDerecha")
	elif Input.is_action_pressed("ui_left"):
		movimiento.x -= 1
		animj.play("MoverIzquierda")
	elif Input.is_action_pressed("ui_down"):
		movimiento.y += 1
		animj.play("MoverAbajo")
	elif Input.is_action_pressed("ui_up"):
		movimiento.y -= 1
		animj.play("MoverArriba")
	else:
		animj.play("default")

	velocity = movimiento.normalized() * VELOCIDAD
	move_and_slide()
