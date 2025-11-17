extends Control

@onready var label_problema = $ProblemaLabel
@onready var boton1 = $HBoxContainer/Opcion1
@onready var boton2 = $HBoxContainer/Opcion2
@onready var boton3 = $HBoxContainer/Opcion3
@onready var boton4 = $HBoxContainer/Opcion4
@onready var label_tiempo = $TiempoLabel

var metodo_actual = ""
var funcion_texto = ""
var coefs = []                   
var a = 0                        
var b = 1
var n = 3                       
var opciones = []
var respuesta_correcta = ""     
var h_correcto = 0.0             
var etapa = 1
var tiempo_restante = 1800

func _ready():
	randomize()
	generar_trivia()
	iniciar_temporizador()

func fmt9(v):
	return "%.9f" % v

func fmt1(v):
	return "%.1f" % v

func redondeo_2dec(v):
	return round(v * 100.0) / 100.0

func randf_range(a,b):
	return a + randf() * (b - a)

func generar_polinomio():
	var grado = 1 + randi() % 3    
	coefs.clear()
	for i in range(grado + 1):
		var c = randf_range(-3.0, 3.0)
		if i == grado and abs(c) < 1e-6:
			c = 1.0
		coefs.append(redondeo_2dec(c))
	funcion_texto = polinomio_a_texto(coefs)

func polinomio_a_texto(cfs):
	var parts = []
	for i in range(cfs.size() - 1, -1, -1):
		var c = cfs[i]
		if abs(c) < 1e-12:
			continue
		var sval = "%.2f" % abs(c)
		var term = ""
		if i == 0:
			term = "%s" % sval
		elif i == 1:
			term = "%s*x" % sval
		else:
			term = "%s*x^%d" % [sval, i]
		if c < 0:
			parts.append("- " + term)
		else:
			parts.append("+ " + term)
	if parts.size() == 0:
		return "0"
	var first = parts[0]
	if first.begins_with("+ "):
		first = first.substr(2, first.length() - 2)
	parts[0] = first
	return " ".join(parts)

func evaluar_polinomio(x):
	var s = 0.0
	for i in range(coefs.size()):
		s += coefs[i] * pow(x, i)
	return s

func f_eval(x):
	return evaluar_polinomio(x)

func integral_exacta(cfs, A, B):
	var s = 0.0
	for i in range(cfs.size()):
		s += cfs[i] * (pow(B, i + 1) - pow(A, i + 1)) / float(i + 1)
	return s

var pesos_cerrados = {
	3: [1.0, 3.0, 3.0, 1.0],                     
	4: [7.0,32.0,12.0,32.0,7.0],                 
	5: [19.0,75.0,50.0,50.0,75.0,19.0],        
	6: [41.0,216.0,27.0,272.0,27.0,216.0,41.0]  
}
var alpha_cerrado = {
	3: 3.0/8.0,
	4: 2.0/45.0,
	5: 5.0/288.0,
	6: 1.0/140.0
}

var pesos_abiertos = {
	3: [0.0, 11.0, 1.0, 1.0, 11.0, 0.0],  
	4: [0.0, 11.0, -14.0, 26.0, -14.0, 11.0, 0.0],  
	5: [0.0, 611.0, -453.0, 562.0,562.0, -453.0, 611.0, 0.0],
	6: [0.0, 460.0, -954.0, 2196.0, -2459.0, 2196.0, -954.0, 460.0, 0.0], 

}
var alpha_abierto = {
	3: 5.0/24.0,   
	4: 6.0/20.0,   
	5: 7.0/1440.0,
	6: 8.0/945.0
}


func regla_cerrada_general(A, B, n_local):
	var h = float(B - A) / n_local
	h_correcto = h
	var pesos = pesos_cerrados.get(n_local, null)
	var alpha = alpha_cerrado.get(n_local, 0.0)
	if pesos == null:
		return 0.0
	var suma = 0.0
	for i in range(n_local + 1):
		var xi = A + i * h
		suma += pesos[i] * f_eval(xi)
	return alpha * h * suma

func regla_trapecio_compuesta(A, B, n_local):
	var h = float(B - A) / n_local
	h_correcto = h
	var suma = 0.0
	for i in range(1, n_local):
		var xi = A + i * h
		suma += 2.0 * f_eval(xi)
	suma += f_eval(A) + f_eval(B)
	return (h / 2.0) * suma


func regla_simpson38_compuesta(A, B, n_local):
	var h = float(B - A) / n_local
	h_correcto = h
	var suma = 0.0
	for i in range(1, n_local):
		var xi = A + i * h
		suma += 3.0 * f_eval(xi)
	suma += f_eval(A) + f_eval(B)
	return (3*h / 8.0) * suma


func regla_abierta_general(A, B, n_local):
	var h_open = float(B - A) / (n_local + 2)
	h_correcto = h_open
	var pesos = pesos_abiertos.get(n_local, null)
	var alpha = alpha_abierto.get(n_local, null)
	if pesos != null and alpha != null:
		var msize = pesos.size()
		var need = n_local + 1
		var start = int((msize - need) / 2)
		if start < 0:
			start = 0
		var suma = 0.0
		for k in range(need):
			var coeff = pesos[start + k]
			var xi = A + (k + 1) * h_open  
			suma += coeff * f_eval(xi)
		return alpha * h_open * suma
	else:
		var suma = 0.0
		for k in range(1, n_local + 2):
			var xi = A + k * h_open
			suma += f_eval(xi)
		h_correcto = h_open
		return h_open * suma * 1.0

func regla_simpson13_compuesta(A, B, n_local):
	if n_local % 2 != 0:
		n_local += 1
	var h = float(B - A) / n_local
	h_correcto = h
	var suma = f_eval(A) + f_eval(B)
	for i in range(1, n_local):
		var xi = A + i * h
		if i % 2 == 0:
			suma += 2 * f_eval(xi)
		else:
			suma += 4 * f_eval(xi)
	return (h / 3.0) * suma

func generar_trivia():
	etapa = 1
	opciones.clear()
	h_correcto = 0.0

	var tema = "Integrales"   
	var disponibles = []
	for m in Global.metodos_por_tema[tema]:
		if not Global.metodos_usados[tema].has(m):
			disponibles.append(m)
	if disponibles.size() == 0:
		Global.metodos_usados[tema].clear()
		disponibles = Global.metodos_por_tema[tema].duplicate()
	
	metodo_actual = disponibles[randi() % disponibles.size()]
	Global.metodos_usados[tema].append(metodo_actual)
	generar_polinomio()

	# -----------------------------
	# n según método
	# -----------------------------
	if metodo_actual == "Simpson1/3":
		n = 2 + 2 * randi() % 3  
	elif metodo_actual == "Simpson3/8":
		n = 3 + randi() % 3     
		n += (3 - (n % 3)) % 3   
	else:
		n = 3 + randi() % 4    

	a = randi() % 6
	b = a + 1

	var approx = 0.0
	match metodo_actual:
		"Trapecio":
			approx = regla_trapecio_compuesta(a, b, n)
		"Simpson1/3":
			approx = regla_simpson13_compuesta(a, b, n)
		"Simpson3/8":
			approx = regla_simpson38_compuesta(a, b, n)
		"Newton-CotesCerrados":
			approx = regla_cerrada_general(a, b, n)
		"Newton-CotesAbiertos":
			approx = regla_abierta_general(a, b, n)

	respuesta_correcta = fmt9(approx)

	preparar_opciones_etapa1()
	mostrar_pregunta()

	print("\n--- Integral generada ---")
	print("f(x) = ", funcion_texto)
	print("Intervalo: [", a, ",", b, "]    n =", n)
	print("Método:", metodo_actual)
	print("Aproximación (metodo):", respuesta_correcta)
	print("Integral exacta (polinomio):", fmt9(integral_exacta(coefs, a, b)))
	print("h calculado (según fórmula del método):", fmt1(h_correcto))

# -----------------------------
# resto del código sin cambios
# -----------------------------
func preparar_opciones_etapa1():
	opciones.clear()
	opciones.append(respuesta_correcta)
	while opciones.size() < 4:
		var scale = max(1.0, abs(float(respuesta_correcta)))
		var delta = randf_range(-0.03 * scale, 0.03 * scale)
		var fake = float(respuesta_correcta) + delta
		var sf = fmt9(fake)  # <- usa mismo formato que la respuesta real
		if not opciones.has(sf):
			opciones.append(sf)
	opciones.shuffle()

func mostrar_pregunta():
	if etapa == 1:
		var texto = "Método: %s\nIntegral: \n∫_{%d}^{%d} \n%s dx\nn = %d\n" % [metodo_actual,a, b, funcion_texto, n]
		label_problema.text = texto
		boton1.text = opciones[0]
		boton2.text = opciones[1]
		boton3.text = opciones[2]
		boton4.text = opciones[3]
	else:
		var correct_h_s = "%.10f" % h_correcto  
		var opts_h = [correct_h_s]
		while opts_h.size() < 4:
			var delta = randf_range(-0.5 * max(1.0, abs(h_correcto)), 0.5 * max(1.0, abs(h_correcto)))
			var fake_h = h_correcto + delta
			var s = "%.10f" % fake_h
			if not opts_h.has(s):
				opts_h.append(s)
		opts_h.shuffle()
		label_problema.text = "Selecciona el valor de h usado:\n"
		boton1.text = opts_h[0]
		boton2.text = opts_h[1]
		boton3.text = opts_h[2]
		boton4.text = opts_h[3]

func _on_opcion_1_pressed(): procesar_respuesta(0)
func _on_opcion_2_pressed(): procesar_respuesta(1)
func _on_opcion_3_pressed(): procesar_respuesta(2)
func _on_opcion_4_pressed(): procesar_respuesta(3)

func procesar_respuesta(index):
	if etapa == 1:
		var elegido = opciones[index]
		if elegido == respuesta_correcta:
			print("Etapa1: correcto seleccionado:", elegido)
			etapa = 2
			mostrar_pregunta()
		else:
			print("Etapa1: incorrecto seleccionado:", elegido, " - correcto:", respuesta_correcta)
			Global.trivia_exito = false
			_regresar_a_batalla()
	else:
		var elegido_h_s = ""
		if index == 0:
			elegido_h_s = boton1.text
		elif index == 1:
			elegido_h_s = boton2.text
		elif index == 2:
			elegido_h_s = boton3.text
		else:
			elegido_h_s = boton4.text
		var correcto_h_s = "%.10f" % h_correcto
		if elegido_h_s == correcto_h_s:
			print("Etapa2: h correcto seleccionado:", elegido_h_s)
			Global.trivia_exito = true
		else:
			print("Etapa2: h incorrecto seleccionado:", elegido_h_s, " - correcto:", correcto_h_s)
			Global.trivia_exito = false
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
	label_tiempo.text = "Tiempo: %02d:%02d" % [int(tiempo_restante / 60), int(tiempo_restante % 60)]

func _regresar_a_batalla():
	var escena_batalla = ""
	var mundo_atual = Global.mundo_actual 
	if mundo_atual == 7:
		Global.batalla_final += 1
		escena_batalla ="res://Escenas/Mundo 7/Batalla_1.tscn"
		get_tree().change_scene_to_file(escena_batalla)
	
	else:
		match Global.batalla_actual:
			1: escena_batalla = "res://Escenas/Mundo 5/Batalla_1.tscn"
			2: escena_batalla = "res://Escenas/Mundo 5/Batalla_2.tscn"
			3: escena_batalla = "res://Escenas/Mundo 5/Batalla_3.tscn"
		get_tree().change_scene_to_file(escena_batalla)
