extends Control

@onready var label_problema = $ProblemaLabel
@onready var boton1 = $HBoxContainer/Opcion1
@onready var boton2 = $HBoxContainer/Opcion2
@onready var boton3 = $HBoxContainer/Opcion3
@onready var boton4 = $HBoxContainer/Opcion4
@onready var label_tiempo = $TiempoLabel

var metodo_actual = ""
var ecuaciones_texto = []
var opciones = []
var respuesta_correcta = []
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

func generar_sistema_3x3():
	var A = []
	var B = []
	ecuaciones_texto.clear()
	var intento = 0
	while true:
		A.clear()
		B.clear()
		ecuaciones_texto.clear()
		for i in range(3):
			var fila = []
			var texto = ""
			var suma_fila = 0.0
			for j in range(3):
				if i != j:
					var coef = randf_range_custom(1,5)
					fila.append(coef)
					suma_fila += abs(coef)
					texto += "%.2fx%d " % [coef,j+1]
					if j < 2:
						texto += "+ "
				else:
					fila.append(0) 
			fila[i] = randf_range_custom(suma_fila + 1, suma_fila + 5)
			texto = ""
			for j in range(3):
				texto += "%.2fx%d" % [fila[j], j+1]
				if j < 2:
					texto += " + "
			var term = randf_range_custom(1,10)
			B.append(term)
			texto += " = %.2f" % term
			A.append(fila)
			ecuaciones_texto.append(texto)
		
		if abs(determinante_3x3(A)) > 1e-5:
			break
		intento += 1
		if intento > 50:
			print("No se pudo generar un sistema válido")
			break
	return [A,B]

func determinante_3x3(A):
	return A[0][0]*(A[1][1]*A[2][2]-A[1][2]*A[2][1]) \
		 - A[0][1]*(A[1][0]*A[2][2]-A[1][2]*A[2][0]) \
		 + A[0][2]*(A[1][0]*A[2][1]-A[1][1]*A[2][0])

func generar_trivia():
	var metodos_disponibles = ["EliminacionGauss", "GaussJordan", "Montante", "GaussSeidel", "Jacobi"]
	var usados = Global.metodos_usados.get("SistemasLineales", [])
	if usados.size() == metodos_disponibles.size():
		Global.metodos_usados["SistemasLineales"].clear()
		usados = []

	var metodo
	while true:
		metodo = metodos_disponibles[randi() % metodos_disponibles.size()]
		if !usados.has(metodo):
			break
	Global.metodos_usados["SistemasLineales"].append(metodo)
	metodo_actual = metodo

	var sistema = generar_sistema_3x3()
	var A = sistema[0]
	var B = sistema[1]

	match metodo_actual:
		"EliminacionGauss":
			respuesta_correcta = metodo_gauss(A,B)
		"GaussJordan":
			respuesta_correcta = metodo_gauss_jordan(A,B)
		"Montante":
			respuesta_correcta = metodo_montante(A,B)
		"GaussSeidel":
			respuesta_correcta = metodo_gauss_seidel(A,B,0.001)
		"Jacobi":
			respuesta_correcta = metodo_jacobi(A,B,0.001)

	preparar_opciones()

func metodo_gauss(A, B):
	var n = 3
	var mat = []
	for i in range(n):
		mat.append(A[i] + [B[i]])
	
	var iteraciones = 0
	
	for i in range(n):
		for j in range(i+1, n):
			var factor = mat[j][i] / mat[i][i]
			for k in range(i, n+1):
				mat[j][k] -= factor * mat[i][k]
			iteraciones += 1
	
	var x = [0.0, 0.0, 0.0]
	for i in range(n-1, -1, -1):
		var suma = 0.0
		for j in range(i+1, n):
			suma += mat[i][j] * x[j]
		x[i] = (mat[i][n] - suma) / mat[i][i]
	
	print("Gauss: Iteraciones = %d, Resultado = %s" % [iteraciones, str(x)])
	return x

func metodo_gauss_jordan(A, B):
	var n = 3
	var mat = []
	for i in range(n):
		mat.append(A[i] + [B[i]])
	
	var iteraciones = 0
	for i in range(n):
		for k in range(n+1):
			mat[i][k] /= mat[i][i]
		for j in range(n):
			if j != i:
				var factor = mat[j][i]
				for k in range(n+1):
					mat[j][k] -= factor * mat[i][k]
				iteraciones += 1
	
	var x = []
	for i in range(n):
		x.append(mat[i][n])
	
	print("Gauss-Jordan: Iteraciones = %d, Resultado = %s" % [iteraciones, str(x)])
	return x

func metodo_montante(A, B):
	var n = 3
	var D_prev = 1.0
	var mat = []
	for i in range(n):
		mat.append(A[i])
	
	var B_copy = B.duplicate()
	var iteraciones = 0
	
	for k in range(n):
		for i in range(n):
			if i != k:
				for j in range(n):
					if j != k:
						mat[i][j] = (mat[k][k]*mat[i][j] - mat[i][k]*mat[k][j]) / D_prev
						iteraciones += 1
		for i in range(n):
			if i != k:
				mat[i][k] = 0
		D_prev = mat[k][k]
	
	var x = []
	for i in range(n):
		x.append(B_copy[i] / mat[i][i])
	
	print("Montante: Iteraciones = %d, Resultado = %s" % [iteraciones, str(x)])
	return x

func metodo_jacobi(A, B, tol=0.001, max_iter=1000):
	var n = 3
	var x = [0.0, 0.0, 0.0]
	var iteraciones = 0
	
	while iteraciones < max_iter:
		iteraciones += 1
		var x_new = x.duplicate()
		
		for i in range(n):
			var suma = 0.0
			for j in range(n):
				if j != i:
					suma += A[i][j] * x[j]
			x_new[i] = (B[i] - suma) / A[i][i]
		
		var diff = 0.0
		for i in range(n):
			diff = max(diff, abs(x_new[i] - x[i]))
		
		x = x_new.duplicate()
		
		if diff < tol:
			break
	
	print("Jacobi: Iteraciones = %d, Resultado = %s" % [iteraciones, str(x)])
	return x


func metodo_gauss_seidel(A, B, tol=0.001, max_iter=1000):
	var n = 3
	var x = [0.0, 0.0, 0.0]
	var iteraciones = 0
	
	while iteraciones < max_iter:
		iteraciones += 1
		var x_old = x.duplicate()
		
		for i in range(n):
			var suma = 0.0
			for j in range(n):
				if j != i:
					suma += A[i][j] * x[j]
			x[i] = (B[i] - suma) / A[i][i]
		
		var diff = 0.0
		for i in range(n):
			diff = max(diff, abs(x[i] - x_old[i]))
		
		if diff < tol:
			break
	
	print("Gauss-Seidel: Iteraciones = %d, Resultado = %s" % [iteraciones, str(x)])
	return x

func preparar_opciones():
	opciones.clear()
	if etapa == 1:
		opciones = [respuesta_correcta[0]]
		while opciones.size() < 4:
			var falsa = respuesta_correcta[0] + randf_range_custom(-2, 2)
			if !opciones.has(falsa):
				opciones.append(redondeo_preciso(falsa))
	else:
		var correctas = "%.9f, %.9f" % [respuesta_correcta[1], respuesta_correcta[2]]
		opciones.append(correctas)
		
		while opciones.size() < 4:
			var delta1 = randf_range_custom(-0.00000005, 0.00000005)
			var delta2 = randf_range_custom(-0.00000005, 0.00000005)
			var falsa = "%.9f, %.9f" % [respuesta_correcta[1] + delta1, respuesta_correcta[2] + delta2]
			if !opciones.has(falsa):
				opciones.append(falsa)
	opciones.shuffle()
	mostrar_pregunta()

func mostrar_pregunta():
	if etapa == 1:
		var texto = "Resuelve el sistema 3x3 usando el método: \n%s\n Ingresa X1\n" % metodo_actual
		for e in ecuaciones_texto:
			texto += e + "\n"
		label_problema.text = texto
	else:
		label_problema.text = "\n\n\nIngresa X2 y X3"
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
	if etapa == 1:
		if redondeo_preciso(opciones[index]) == redondeo_preciso(respuesta_correcta[0]):
			etapa = 2
			label_problema.text = "Ahora indica el margen de error de las otras dos variables:"
			preparar_opciones()
		else:
			Global.trivia_exito = false
			_regresar_a_batalla()
	elif etapa == 2:
		var correctas = "%.9f, %.9f" % [respuesta_correcta[1], respuesta_correcta[2]]
		Global.trivia_exito = opciones[index] == correctas
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
	match Global.batalla_actual:
		1: escena_batalla = "res://Escenas/Mundo 3/Batalla_1.tscn"
		2: escena_batalla = "res://Escenas/Mundo 3/Batalla_2.tscn"
		3: escena_batalla = "res://Escenas/Mundo 3/Batalla_3.tscn"
	get_tree().change_scene_to_file(escena_batalla)
