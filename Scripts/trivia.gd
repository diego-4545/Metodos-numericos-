extends Control

@onready var label_problema = $ProblemaLabel
@onready var boton1 = $HBoxContainer/Opcion1
@onready var boton2 = $HBoxContainer/Opcion2
@onready var boton3 = $HBoxContainer/Opcion3
@onready var boton4 = $HBoxContainer/Opcion4
@onready var label_tiempo = $TiempoLabel

var metodo_actual = ""
var x_tabla = []
var y_tabla = []
var valor_a_interpolar = 0
var respuesta_correcta = 0
var respuesta_comprobacion = 0
var opciones = []
var tiempo_restante = 1800 # 30 minutos
var etapa = 1 # 1 = primera pregunta, 2 = comprobación

func _ready():
	randomize()
	generar_trivia()
	iniciar_temporizador()

# ----------------- UTILIDADES -----------------
func formatear_tabla(valor):
	var s = str(round(valor*100)/100.0)
	while s.length() < 10:
		s += " "
	return s

func redondeo_preciso(valor):
	return round(valor*1e9)/1e9

func xs_text():
	var s = "x:       "
	for i in range(x_tabla.size()):
		s += formatear_tabla(x_tabla[i])
	return s

func ys_text():
	var s = "f(x):    "
	for i in range(y_tabla.size()):
		s += formatear_tabla(y_tabla[i])
	return s

# ----------------- GENERAR TRIVIA -----------------
func generar_trivia():
	metodo_actual = Global.obtener_metodo_sin_repetir("Interpolacion")
	etapa = 1
	
	match metodo_actual:
		"Lineal":
			var x0 = 2 + randf()*3
			var x1 = x0 + 1 + randf()*2
			x_tabla = [x0, x1]
			y_tabla = [log(x0), log(x1)]
			valor_a_interpolar = x0 + randf()*(x1-x0)
			respuesta_correcta = redondeo_preciso(interpolacion_lineal(x0, y_tabla[0], x1, y_tabla[1], valor_a_interpolar))
			respuesta_comprobacion = redondeo_preciso(log(valor_a_interpolar) - respuesta_correcta)
		"NewtonAdelante":
			x_tabla = [1,2,3,4]
			y_tabla = [2+randf()*2, 5+randf()*2, 8+randf()*3, 12+randf()*4]
			valor_a_interpolar = x_tabla[0] + randf()*(x_tabla[-1]-x_tabla[0])
			respuesta_correcta = redondeo_preciso(interpolacion_newton_adelante(x_tabla, y_tabla, valor_a_interpolar))
			respuesta_comprobacion = redondeo_preciso((valor_a_interpolar - x_tabla[0])/(x_tabla[1]-x_tabla[0]))
		"NewtonAtras":
			x_tabla = [3,4,5,6]
			y_tabla = [10+randf()*5, 16+randf()*6, 23+randf()*7, 31+randf()*9]
			valor_a_interpolar = x_tabla[0] + randf()*(x_tabla[-1]-x_tabla[0])
			respuesta_correcta = redondeo_preciso(interpolacion_newton_atras(x_tabla, y_tabla, valor_a_interpolar))
			respuesta_comprobacion = redondeo_preciso((valor_a_interpolar - x_tabla[-1])/(x_tabla[1]-x_tabla[0]))
		"DiferenciasDivididas":
			x_tabla = [2,4,7]
			y_tabla = [2+randf()*3, 7+randf()*5, 15+randf()*10]
			valor_a_interpolar = x_tabla[0] + randf()*(x_tabla[-1]-x_tabla[0])
			respuesta_correcta = redondeo_preciso(interpolacion_diferencias_divididas(x_tabla, y_tabla, valor_a_interpolar))
			respuesta_comprobacion = redondeo_preciso((y_tabla[1]-y_tabla[0])/(x_tabla[1]-x_tabla[0]))
		"Lagrange":
			x_tabla = [2,3,6]
			y_tabla = [3+randf()*3, 5+randf()*5, 15+randf()*10]
			valor_a_interpolar = x_tabla[0] + randf()*(x_tabla[-1]-x_tabla[0])
			respuesta_correcta = redondeo_preciso(interpolacion_lagrange(x_tabla, y_tabla, valor_a_interpolar))
			respuesta_comprobacion = redondeo_preciso(y_tabla[1])

	preparar_opciones(respuesta_correcta)

# ----------------- PREPARAR OPCIONES -----------------
func preparar_opciones(valor):
	opciones = [valor]
	while opciones.size() < 4:
		var falsa = redondeo_preciso(valor + randf()*6 - 3)
		falsa = max(falsa, 0.0) # Evita valores negativos
		if !opciones.has(falsa):
			opciones.append(falsa)
	opciones.shuffle()

	if etapa == 1:
		label_problema.text = "Método: %s\nInterpolar f(%.2f)\n%s\n%s" % [metodo_actual, round(valor_a_interpolar*100)/100.0, xs_text(), ys_text()]
	else:
		match metodo_actual:
			"Lineal":
				label_problema.text = "Método: Lineal\nIngresa el margen de error"
			"NewtonAdelante", "NewtonAtras":
				label_problema.text = "Método: %s\nIngresa s" % metodo_actual
			"Lagrange":
				label_problema.text = "Método: Lagrange\nIngresa el valor cuando evaluas\nla primera parte de la fórmula"
			"DiferenciasDivididas":
				label_problema.text = "Método: Diferencias Divididas\nIngresa d11"

	mostrar_opciones()

# ----------------- MOSTRAR OPCIONES -----------------
func mostrar_opciones():
	boton1.text = str(opciones[0])
	boton2.text = str(opciones[1])
	boton3.text = str(opciones[2])
	boton4.text = str(opciones[3])

# ----------------- TEMPORIZADOR -----------------
func iniciar_temporizador():
	actualizar_tiempo_label()
	temporizador_tick()

func temporizador_tick():
	await get_tree().create_timer(1.0).timeout
	tiempo_restante -= 1
	actualizar_tiempo_label()
	if tiempo_restante > 0:
		temporizador_tick()
	else:
		Global.trivia_exito = false
		_regresar_a_batalla()

func actualizar_tiempo_label():
	var minutos = int(tiempo_restante / 60)
	var segundos = int(tiempo_restante % 60)
	label_tiempo.text = "Tiempo: %02d:%02d" % [minutos, segundos]

# ----------------- INTERPOLACIONES -----------------
func interpolacion_lineal(x0,y0,x1,y1,x):
	return y0 + (y1-y0)*(x-x0)/(x1-x0)

func interpolacion_newton_adelante(xs, ys, x):
	var n = xs.size()
	var dif = []
	for i in range(n):
		dif.append([ys[i]])
	for j in range(1,n):
		for i in range(n-j):
			dif[i].append(dif[i+1][j-1]-dif[i][j-1])
	var h = xs[1]-xs[0]
	var u = (x-xs[0])/h
	var result = ys[0]
	var mult = 1.0
	for i in range(1,n):
		mult *= (u-(i-1))
		result += (mult * dif[0][i]) / factorial(i)
	return result

func interpolacion_newton_atras(xs, ys, x):
	var n = xs.size()
	var dif = []
	for i in range(n):
		dif.append([ys[i]])
	for j in range(1,n):
		for i in range(n-j):
			dif[i].append(dif[i+1][j-1]-dif[i][j-1])
	var h = xs[1]-xs[0]
	var u = (x-xs[-1])/h
	var result = ys[-1]
	var mult = 1.0
	for i in range(1,n):
		mult *= (u+(i-1))
		result += (mult * dif[n-i-1][i]) / factorial(i)
	return result

func interpolacion_diferencias_divididas(xs, ys, x):
	var n = xs.size()
	var dif = []
	for i in range(n):
		dif.append([ys[i]])
	for j in range(1,n):
		for i in range(n-j):
			dif[i].append((dif[i+1][j-1]-dif[i][j-1])/(xs[i+j]-xs[i]))
	var result = dif[0][0]
	for i in range(1,n):
		var mult = 1.0
		for j in range(i):
			mult *= (x-xs[j])
		result += mult*dif[0][i]
	return result

func interpolacion_lagrange(xs, ys, x):
	var n = xs.size()
	var result = 0.0
	for i in range(n):
		var li = 1.0
		for j in range(n):
			if i != j:
				li *= (x - xs[j])/(xs[i]-xs[j])
		result += li*ys[i]
	return result

# ----------------- FACTORIAL -----------------
func factorial(n: int) -> int:
	var result = 1
	for i in range(2, n+1):
		result *= i
	return result

# ----------------- BOTONES -----------------
func _on_opcion_1_pressed():
	procesar_respuesta(0)

func _on_opcion_2_pressed():
	procesar_respuesta(1)

func _on_opcion_3_pressed():
	procesar_respuesta(2)

func _on_opcion_4_pressed():
	procesar_respuesta(3)

# ----------------- PROCESAR RESPUESTA -----------------
func procesar_respuesta(index):
	if etapa == 1:
		if redondeo_preciso(opciones[index]) == redondeo_preciso(respuesta_correcta):
			etapa = 2
			preparar_opciones(respuesta_comprobacion)
		else:
			Global.trivia_exito = false
			_regresar_a_batalla()
	elif etapa == 2:
		if redondeo_preciso(opciones[index]) == redondeo_preciso(respuesta_comprobacion):
			Global.trivia_exito = true
		else:
			Global.trivia_exito = false
		_regresar_a_batalla()

func _regresar_a_batalla():
	var escena_batalla = ""
	match Global.batalla_actual:
		1: escena_batalla = "res://Escenas/Mundo 1/Batalla_1.tscn"
		2: escena_batalla = "res://Escenas/Mundo 1/Batalla_2.tscn"
		3: escena_batalla = "res://Escenas/Mundo 1/Batalla_3.tscn"
	get_tree().change_scene_to_file(escena_batalla)
