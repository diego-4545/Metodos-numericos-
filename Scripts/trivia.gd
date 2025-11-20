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
var tiempo_restante = 1800 
var etapa = 1 

func _ready():
	randomize()
	generar_trivia()
	iniciar_temporizador()

func formatear_tabla(valor):
	var s = str(round(valor * 100) / 100.0)
	while s.length() < 10:
		s += " "
	return s

func redondeo_preciso(valor):
	return round(valor * 1e9) / 1e9

func redondear_2(valor):
	return round(valor * 100) / 100.0

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

func generar_trivia():
	metodo_actual = Global.obtener_metodo_sin_repetir("Interpolacion")
	etapa = 1
	
	match metodo_actual:
		"Lineal":
			var x0 = redondear_2(2 + randf() * 3)
			var x1 = redondear_2(x0 + 1 + randf() * 2)
			x_tabla = [x0, x1]
			y_tabla = [redondear_2(log(x0)), redondear_2(log(x1))]
			valor_a_interpolar = redondear_2(x0 + randf() * (x1 - x0))
			respuesta_correcta = redondeo_preciso(interpolacion_lineal(x0, y_tabla[0], x1, y_tabla[1], valor_a_interpolar))
			print(respuesta_correcta)
			respuesta_comprobacion = redondeo_preciso(log(valor_a_interpolar) - respuesta_correcta)
			print(respuesta_comprobacion)

		"Newton-Hacia-Adelante":
			x_tabla = [1, 2, 3, 4]
			y_tabla = [
				redondear_2(2 + randf() * 2),
				redondear_2(5 + randf() * 2),
				redondear_2(8 + randf() * 3),
				redondear_2(12 + randf() * 4)
			]
			valor_a_interpolar = redondear_2(x_tabla[0] + randf() * (x_tabla[-1] - x_tabla[0]))
			respuesta_correcta = redondeo_preciso(interpolacion_newton_adelante(x_tabla, y_tabla, valor_a_interpolar))
			respuesta_comprobacion = redondeo_preciso((valor_a_interpolar - x_tabla[0]) / (x_tabla[1] - x_tabla[0]))
			print(respuesta_comprobacion)

		"Newton-Hacia-Atras":
			x_tabla = [3, 4, 5, 6]
			y_tabla = [
				redondear_2(10 + randf() * 5),
				redondear_2(16 + randf() * 6),
				redondear_2(23 + randf() * 7),
				redondear_2(31 + randf() * 9)
			]
			valor_a_interpolar = redondear_2(
				x_tabla[x_tabla.size() - 2] + randf() * (x_tabla[x_tabla.size() - 1] - x_tabla[x_tabla.size() - 2])
			)
			respuesta_correcta = redondeo_preciso(
				interpolacion_newton_atras(x_tabla, y_tabla, valor_a_interpolar)
			)
			respuesta_comprobacion = redondeo_preciso(
				abs((valor_a_interpolar - x_tabla[x_tabla.size() - 1]) / (x_tabla[1] - x_tabla[0]))
			)
			print(respuesta_comprobacion)


		"Newton-Diferencias-Divididas":
			x_tabla = [2, 4, 7]
			y_tabla = [
				redondear_2(2 + randf() * 3),
				redondear_2(7 + randf() * 5),
				redondear_2(15 + randf() * 10)
			]
			valor_a_interpolar = redondear_2(x_tabla[0] + randf() * (x_tabla[-1] - x_tabla[0]))
			respuesta_correcta = redondeo_preciso(interpolacion_diferencias_divididas(x_tabla, y_tabla, valor_a_interpolar))
			respuesta_comprobacion = redondeo_preciso((y_tabla[1] - y_tabla[0]) / (x_tabla[1] - x_tabla[0]))
			print(respuesta_comprobacion)

		"Lagrange":
			x_tabla = [2, 3, 6]
			y_tabla = [
				redondear_2(3 + randf() * 3),
				redondear_2(5 + randf() * 5),
				redondear_2(15 + randf() * 10)
			]
			valor_a_interpolar = redondear_2(x_tabla[0] + randf() * (x_tabla[-1] - x_tabla[0]))
			respuesta_correcta = redondeo_preciso(interpolacion_lagrange(x_tabla, y_tabla, valor_a_interpolar))
			respuesta_comprobacion = redondeo_preciso(y_tabla[0])
			print(respuesta_comprobacion)

	preparar_opciones(respuesta_correcta)
	

func preparar_opciones(valor):
	
	if typeof(valor) != TYPE_FLOAT and typeof(valor) != TYPE_INT:
		valor = 0.0
	if is_nan(valor):
		valor = 0.0

	var texto_valor = str(valor)
	var partes = texto_valor.split(".")
	var decimales = 0
	var enteros = 1

	if partes.size() > 0 and partes[0] != "":
		enteros = partes[0].length()
	if partes.size() > 1 and partes[1] != "":
		decimales = partes[1].length()

	opciones = [valor]
	while opciones.size() < 4:
		var delta = randf_range(-3.0, 3.0)
		var falsa = valor + delta
		if falsa < 0 or is_nan(falsa):
			continue  

		decimales = min(decimales, 9)
		falsa = round(falsa * pow(10, decimales)) / pow(10, decimales)

		var texto_falsa = str(falsa)
		var partes_falsa = texto_falsa.split(".")
		var enteros_falsa = 1
		if partes_falsa.size() > 0 and partes_falsa[0] != "":
			enteros_falsa = partes_falsa[0].length()

		if enteros_falsa != enteros:
			continue

		if !opciones.has(falsa):
			opciones.append(falsa)

	opciones.shuffle()
	

	if etapa == 1:
		label_problema.text = "Método: %s\nInterpolar f(%.2f)\n%s\n%s" % [metodo_actual, valor_a_interpolar, xs_text(), ys_text()]
	else:
		match metodo_actual:
			"Lineal":
				label_problema.text = "Método: Lineal\nIngresa el margen de error"
			"Newton-Hacia-Adelante", "Newton-Hacia-Atras":
				label_problema.text = "Método: %s\nIngresa s" % metodo_actual
			"Lagrange":
				label_problema.text = "Método: Lagrange\nIngresa el valor de y1 en la tabla"
			"Newton-Diferencias-Divididas":
				label_problema.text = "Método: Diferencias Divididas\nIngresa d11"

	mostrar_opciones()

func mostrar_opciones():
	boton1.text = str(opciones[0])
	boton2.text = str(opciones[1])
	boton3.text = str(opciones[2])
	boton4.text = str(opciones[3])

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

func interpolacion_lineal(x0, y0, x1, y1, x):
	if is_equal_approx(x1, x0):
		return y0   
	return y0 + (y1 - y0) * (x - x0) / (x1 - x0)


func interpolacion_newton_adelante(xs, ys, x):
	var n = xs.size()
	var dif = []
	for i in range(n):
		dif.append([ys[i]])
	for j in range(1, n):
		for i in range(n - j):
			dif[i].append(dif[i + 1][j - 1] - dif[i][j - 1])
	var h = xs[1] - xs[0]
	var u = (x - xs[0]) / h
	var result = ys[0]
	var mult = 1.0
	for i in range(1, n):
		mult *= (u - (i - 1))
		result += (mult * dif[0][i]) / factorial(i)
	print (result)
	return result

func interpolacion_newton_atras(xs, ys, x):
	var n = xs.size()
	var dif = []
	for i in range(n):
		dif.append([ys[i]])
	for j in range(1, n):
		for i in range(n - j):
			dif[i].append(dif[i + 1][j - 1] - dif[i][j - 1])
	var h = xs[1] - xs[0]
	var u = (x - xs[-1]) / h
	var result = ys[-1]
	var mult = 1.0
	for i in range(1, n):
		mult *= (u + (i - 1))
		result += (mult * dif[n - i - 1][i]) / factorial(i)
	print (result)
	return result

func interpolacion_diferencias_divididas(xs, ys, x):
	var n = xs.size()
	var dif = []
	for i in range(n):
		dif.append([ys[i]])
	for j in range(1, n):
		for i in range(n - j):
			dif[i].append((dif[i + 1][j - 1] - dif[i][j - 1]) / (xs[i + j] - xs[i]))
	var result = dif[0][0]
	for i in range(1, n):
		var mult = 1.0
		for j in range(i):
			mult *= (x - xs[j])
		result += mult * dif[0][i]
	print (result)
	return result

func interpolacion_lagrange(xs, ys, x):
	var n = xs.size()
	var result = 0.0
	for i in range(n):
		var li = 1.0
		for j in range(n):
			if i != j:
				li *= (x - xs[j]) / (xs[i] - xs[j])
		result += li * ys[i]
	print (result)
	return result

func factorial(n: int) -> int:
	var result = 1
	for i in range(2, n + 1):
		result *= i
	return result

func _on_opcion_1_pressed(): procesar_respuesta(0)
func _on_opcion_2_pressed(): procesar_respuesta(1)
func _on_opcion_3_pressed(): procesar_respuesta(2)
func _on_opcion_4_pressed(): procesar_respuesta(3)

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
	var mundo_atual = Global.mundo_actual 
	if mundo_atual == 7:
		Global.batalla_final += 1
		escena_batalla ="res://Escenas/Mundo 7/Batalla_1.tscn"
		get_tree().change_scene_to_file(escena_batalla)
	
	else:
		match Global.batalla_actual:
			1: escena_batalla = "res://Escenas/Mundo 1/Batalla_1.tscn"
			2: escena_batalla = "res://Escenas/Mundo 1/Batalla_2.tscn"
			3: escena_batalla = "res://Escenas/Mundo 1/Batalla_3.tscn"
		get_tree().change_scene_to_file(escena_batalla)
