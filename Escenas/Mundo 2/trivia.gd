extends Control

@onready var label_problema = $ProblemaLabel
@onready var boton1 = $HBoxContainer/Opcion1
@onready var boton2 = $HBoxContainer/Opcion2
@onready var boton3 = $HBoxContainer/Opcion3
@onready var boton4 = $HBoxContainer/Opcion4
@onready var label_tiempo = $TiempoLabel

var metodo_actual = ""
var ecuacion_texto = ""
var f : Callable
var opciones = []
var respuesta_correcta = 0.0
var respuesta_comprobacion = 0.0
var tiempo_restante = 1800
var etapa = 1
var problemas_usados = []

func _ready():
	randomize()
	generar_trivia()
	iniciar_temporizador()

func redondeo_preciso(valor): return round(valor * 1e9) / 1e9
func redondear_2(valor): return round(valor * 100) / 100.0
func randf_range_custom(a,b): return a + randf() * (b - a)

func generar_ecuacion_aleatoria():
	var tipo = randi() % 5
	match tipo:
		0:
			var a = randf_range_custom(1, 3)
			var b = randf_range_custom(-2, 2)
			var c = randf_range_custom(-3, 3)
			var d = randf_range_custom(-1, 1)
			ecuacion_texto = "f(x) = %.2fx³ + %.2fx² + %.2fx + %.2f" % [a,b,c,d]
			return func(x): return a*pow(x,3) + b*pow(x,2) + c*x + d
		1:
			var k = randf_range_custom(0.5, 2.0)
			ecuacion_texto = "f(x) = e^(-%.2fx) - x" % k
			return func(x): return exp(-k*x) - x
		2:
			var k = randf_range_custom(0.5, 3.0)
			ecuacion_texto = "f(x) = sin(%.2fx) - 0.5" % k
			return func(x): return sin(k*x) - 0.5
		3:
			var k = randf_range_custom(1, 3)
			ecuacion_texto = "f(x) = cos(%.2fx) - x" % k
			return func(x): return cos(k*x) - x
		4:
			var k = randf_range_custom(1, 4)
			ecuacion_texto = "f(x) = x² - %.2f" % k
			return func(x): return pow(x,2) - k
	return null

func generar_trivia():
	var metodos_disponibles = Global.metodos_por_tema["EcuacionesNoLineales"]
	var usados = Global.metodos_usados["EcuacionesNoLineales"]

	if usados.size() == metodos_disponibles.size():
		Global.metodos_usados["EcuacionesNoLineales"].clear()
		usados = []

	var metodo
	while true:
		metodo = metodos_disponibles[randi() % metodos_disponibles.size()]
		if !usados.has(metodo):
			break
	Global.metodos_usados["EcuacionesNoLineales"].append(metodo)
	metodo_actual = metodo

	f = generar_ecuacion_aleatoria()

	var resultado = []
	match metodo_actual:
		"Grafico":
			resultado = metodo_grafico(f)
		"Falsa-Posicion":
			resultado = metodo_falsa_posicion(f, -3, 3, 0.0001)
		"Punto-Fijo":
			resultado = metodo_punto_fijo(f, 0.5, 0.001)
		"Secante":
			resultado = metodo_secante(f, 0.5, 0.7, 0.001)

	respuesta_correcta = resultado[0]
	respuesta_comprobacion = resultado[1]
	preparar_opciones(respuesta_correcta)

func metodo_grafico(f):
	var x = -10
	var paso = 1
	var intervalo = ""

	while x < 10:
		var a = x
		var b = x + 1
		var fa = f.call(a)
		var fb = f.call(b)

		if fa * fb < 0:
			intervalo = str(a) + "|" + str(b)
			break

		x += 1

	if intervalo == "":
		push_error("No se encontró intervalo con cambio de signo")
		return ["", 0]


	if etapa == 1:
		print (intervalo)
		return [intervalo, 0]


	var partes = intervalo.split("|")
	var a2 = float(partes[0])
	var b2 = float(partes[1])

	var fa2 = f.call(a2)
	var fb2 = f.call(b2)

	var tol = 0.002
	var margen = abs(b2 - a2)
	var c = 0.0
	var fc = 0.0

	while margen > tol:
		c = (a2 + b2) / 2.0
		fc = f.call(c)

		if fa2 * fc < 0:
			b2 = c
			fb2 = fc
		else:
			a2 = c
			fa2 = fc
		margen = abs(b2 - a2)
	print (c)
	return [c, margen]

func metodo_falsa_posicion(f, a, b, tol):
	var fa = f.call(a)
	var fb = f.call(b)
	if fa * fb > 0:
		b += 1
		fb = f.call(b)
	var c = 0.0
	var anterior = a
	var iter = 0
	while abs(b - a) > tol:
		iter += 1
		c = b - fb * (b - a) / (fb - fa)
		var fc = f.call(c)
		print("Iter %d: a=%.5f b=%.5f c=%.5f f(c)=%.5f" % [iter, a, b, c, fc])
		if fa * fc < 0:
			b = c
			fb = fc
		else:
			a = c
			fa = fc
		if abs(fc) < tol:
			break
		anterior = c
	var margen = abs(c - anterior)
	print("→ Raíz aproximada: %.5f, Margen de error: %.8f, Iteraciones: %d\n" % [c, margen, iter])
	return [redondeo_preciso(c), redondeo_preciso(margen)]

func metodo_punto_fijo(f, x0, tol):
	var x1 = 0.0
	var anterior = x0
	var iter = 0
	for i in range(1000):
		iter += 1
		anterior = x0
		x1 = cos(x0)
		print("Iter %d: x0=%.5f → x1=%.5f" % [iter, x0, x1])
		if abs(x1 - x0) < tol:
			break
		x0 = x1
	var margen = abs(x1 - anterior)
	print("→ Raíz aproximada: %.5f, Margen de error: %.8f, Iteraciones: %d\n" % [x1, margen, iter])
	return [redondeo_preciso(x1), redondeo_preciso(margen)]

func metodo_secante(f, x0, x1, tol):
	var x2 = 0.0
	var anterior = x1
	var iteraciones = 0
	while abs(x1 - x0) > tol and iteraciones < 1000:
		var denom = f.call(x1) - f.call(x0)
		if abs(denom) < 1e-10:
			break
		x2 = x1 - f.call(x1) * (x1 - x0) / denom
		anterior = x1
		x0 = x1
		x1 = x2
		iteraciones += 1
		print(iteraciones)
		print(x2)
	var margen = abs(x2 - anterior)
	print(margen)
	return [redondeo_preciso(x2), redondeo_preciso(margen)]

func preparar_opciones(valor):
	opciones.clear()

	if metodo_actual == "Grafico":
		if etapa == 1:
			if typeof(valor) != TYPE_STRING:
				push_error("preparar_opciones: en etapa 1 (Grafico) se esperaba STRING, llegó: " + str(valor))
				return

			opciones.append(valor)

			var partes = valor.split("|")
			if partes.size() != 2:
				push_error("preparar_opciones: intervalo mal formado: " + valor)
				return

			var correcto_a = int(float(partes[0].strip_edges()))

			while opciones.size() < 4:
				var desplaz = (randi() % 5) - 2   
				var a_falso = correcto_a + desplaz
				var b_falso = a_falso + 1
				var intervalo_falso = str(a_falso) + "|" + str(b_falso)
				if not opciones.has(intervalo_falso):
					opciones.append(intervalo_falso)

			opciones.shuffle()
			mostrar_pregunta()
			return

		if etapa == 2:
			var raiz = 0.0
			if typeof(valor) == TYPE_STRING:
				raiz = float(valor.strip_edges())
			else:
				raiz = float(valor)

			opciones = [ redondeo_preciso(raiz) ]
			while opciones.size() < 4:
				var variacion = randf_range_custom(-0.1, 0.1)
				var falsa = redondeo_preciso(raiz + variacion)
				if not opciones.has(falsa):
					opciones.append(falsa)

			opciones.shuffle()
			mostrar_pregunta()
			return


	var valor_num = float(valor)

	if etapa == 1:
		opciones = [valor_num]
		while opciones.size() < 4:
			var falsa = valor_num + randf_range_custom(-2.0, 2.0)
			falsa = redondeo_preciso(falsa)
			if not opciones.has(falsa):
				opciones.append(falsa)

	else:
		opciones = [valor_num]
		while opciones.size() < 4:
			var variacion = randf_range_custom(-0.0005, 0.0005)
			var falsa = valor_num + variacion
			falsa = redondeo_preciso(falsa)

			if falsa > 0 and not opciones.has(falsa):
				opciones.append(falsa)

	opciones.shuffle()
	mostrar_pregunta()


func mostrar_pregunta():


	if metodo_actual == "Grafico":

		if etapa == 1:
			label_problema.text = "Resuelve el siguiente problema:\n%s\nMétodo: %s\nEncuentra los intervalos en los\nque se encuentra una raiz." % [ecuacion_texto, metodo_actual]
		else:
			label_problema.text = "Método Bisectriz:\n\nAhora selecciona la \nrespuesta más cercana a una raiz."
		
		mostrar_opciones()
		return


	if etapa == 1:
		label_problema.text = "Resuelve el siguiente problema:\n%s\nMétodo: %s\n\nEncuentra la raíz aproximada." % [ecuacion_texto, metodo_actual]
	else:
		label_problema.text = "Indica el margen de error."

	mostrar_opciones()

func mostrar_opciones():
	boton1.text = str(opciones[0])
	boton2.text = str(opciones[1])
	boton3.text = str(opciones[2])
	boton4.text = str(opciones[3])

func _on_opcion_1_pressed(): procesar_respuesta(0)
func _on_opcion_2_pressed(): procesar_respuesta(1)
func _on_opcion_3_pressed(): procesar_respuesta(2)
func _on_opcion_4_pressed(): procesar_respuesta(3)

func procesar_respuesta(index):

	if metodo_actual == "Grafico":

		var opcion = str(opciones[index]).strip_edges()
		var correcta = str(respuesta_correcta).strip_edges()

		if etapa == 1:
			if opcion == correcta:
				etapa = 2
				var res = metodo_grafico(f)
				respuesta_comprobacion = res[0]		
				preparar_opciones(respuesta_comprobacion)
			else:
				Global.trivia_exito = false
				_regresar_a_batalla()
			return
		if etapa == 2:
			var elegido = float(opciones[index])

			if redondeo_preciso(elegido) == redondeo_preciso(respuesta_comprobacion):
				Global.trivia_exito = true
			else:
				Global.trivia_exito = false

			_regresar_a_batalla()
			return

	if etapa == 1:
		if redondeo_preciso(opciones[index]) == redondeo_preciso(respuesta_correcta):
			etapa = 2
			preparar_opciones(respuesta_comprobacion)
		else:
			Global.trivia_exito = false
			_regresar_a_batalla()

	elif etapa == 2:
		Global.trivia_exito = redondeo_preciso(opciones[index]) == redondeo_preciso(respuesta_comprobacion)
		_regresar_a_batalla()

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

func _regresar_a_batalla():
	var escena_batalla = ""
	var mundo_atual = Global.mundo_actual 
	if mundo_atual == 7:
		Global.batalla_final += 1
		escena_batalla ="res://Escenas/Mundo 7/Batalla_1.tscn"
		get_tree().change_scene_to_file(escena_batalla)
	
	else:
		match Global.batalla_actual:
			1: escena_batalla = "res://Escenas/Mundo 2/Batalla_1.tscn"
			2: escena_batalla = "res://Escenas/Mundo 2/Batalla_2.tscn"
			3: escena_batalla = "res://Escenas/Mundo 2/Batalla_3.tscn"
		get_tree().change_scene_to_file(escena_batalla)
