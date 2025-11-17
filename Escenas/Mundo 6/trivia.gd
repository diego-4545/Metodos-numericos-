extends Control

@onready var label_problema = $ProblemaLabel
@onready var boton1 = $HBoxContainer/Opcion1
@onready var boton2 = $HBoxContainer/Opcion2
@onready var boton3 = $HBoxContainer/Opcion3
@onready var boton4 = $HBoxContainer/Opcion4
@onready var label_tiempo = $TiempoLabel

var metodo_actual = ""
var coefs = []
var coef_a = 0.0          
var coef_b = 0.0          
var t0 = 0.0
var y0 = 0.0
var yp0 = 0.0            
var y1_dado = 0.0
var y1_real = 0.0         
var y1p_real = 0.0       
var y2_real = 0.0         
var y2p_real = 0.0       
var h = 0.1
var opciones = []
var respuesta_correcta = ""
var etapa = 1
var tiempo_restante = 1800

func _ready():
	randomize()
	generar_trivia()
	iniciar_temporizador()

func fmt2(v): return "%.2f" % v
func fmt9(v): return "%.9f" % v
func randf_range(a,b): return a + randf()*(b-a)

func preparar_opciones_RK_superior(y_real, yp_real):
	opciones.clear()
	opciones.append("(%s , %s)" % [fmt9(y_real), fmt9(yp_real)])

	while opciones.size() < 4:
		var dy = randf_range(-0.03, 0.03)
		var dyp = randf_range(-0.03, 0.03)

		var y_fake = y_real + dy
		var yp_fake = yp_real + dyp

		var txt = "(%s , %s)" % [fmt9(y_fake), fmt9(yp_fake)]
		if not opciones.has(txt):
			opciones.append(txt)

	opciones.shuffle()

func generar_polinomio():
	var grado = 1 + randi() % 3
	coefs.clear()
	for i in range(grado+1):
		var c = randf_range(-3,3)
		if i==grado and abs(c)<1e-6:
			c = 1.0
		coefs.append(round(c*100)/100.0)

func polinomio_a_texto(cfs):
	var parts = []
	for i in range(cfs.size() - 1, -1, -1):
		var c = cfs[i]
		if abs(c) < 1e-12:
			continue
		var sval = "%.2f" % abs(c)
		var term = "%s" % sval if i == 0 else "%s*t" % sval if i == 1 else "%s*t^%d" % [sval, i]
		var sign = "- " if c < 0 else "+ "
		parts.append(sign + term)
	if parts.size() == 0:
		return "0"
	var first = parts[0]
	if first.begins_with("+ "):
		first = first.substr(2, first.length() - 2)
	parts[0] = first
	return " ".join(parts)

func funcion_completa_texto():
	return "y + (" + polinomio_a_texto(coefs) + ")"

func f_eval(t, y):
	var s = y
	for i in range(coefs.size()):
		s += coefs[i] * pow(t,i)
	return s

func euler_modificado_y1prima(y0_in, y1_in, t0_in, h_in):
	var k1 = f_eval(t0_in, y0_in)
	var k2 = f_eval(t0_in + h_in, y1_in)
	return y0_in + h_in/2.0*(k1 + k2)

func rk2(y0_in, t0_in, h_in):
	var k1 = f_eval(t0_in, y0_in) * h_in
	var k2 = f_eval(t0_in + h_in, y0_in + k1) * h_in
	return y0_in + 0.5*(k1 + k2)

func rk3(y0_in, t0_in, h_in):
	var k1 = f_eval(t0_in, y0_in) * h_in
	var k2 = f_eval(t0_in + h_in/2.0, y0_in + k1/2.0) * h_in
	var k3 = f_eval(t0_in + h_in, y0_in - k1 + 2.0*k2) * h_in
	return y0_in + (1.0/6.0)*(k1 + 4.0*k2 + k3)

func rk413(y0_in, t0_in, h_in):
	var k1 = f_eval(t0_in, y0_in) * h_in
	var k2 = f_eval(t0_in + h_in/2.0, y0_in + k1/2.0) * h_in
	var k3 = f_eval(t0_in + h_in/2.0, y0_in + k2/2.0) * h_in
	var k4 = f_eval(t0_in + h_in, y0_in + k3) * h_in
	return y0_in + (1.0/6.0)*(k1 + 2.0*k2 + 2.0*k3 + k4)

func rk438(y0_in, t0_in, h_in):
	var k1 = f_eval(t0_in, y0_in) * h_in
	var k2 = f_eval(t0_in + h_in/3.0, y0_in + k1/3.0) * h_in
	var k3 = f_eval(t0_in + 2.0*h_in/3.0, y0_in + k1/3.0 + k2/3.0) * h_in
	var k4 = f_eval(t0_in + h_in, y0_in + k1 - k2 + k3) * h_in
	return y0_in + (1.0/8.0)*(k1 + 3.0*k2 + 3.0*k3 + k4)

func rk_superior(y, yp, t, h_in, a, b):
	var Vn = yp
	var Un = y

	var k1 = h_in * Vn
	print(k1)
	var m1 = h_in * f_segundo_orden(t, Un, Vn)
	print(m1)
	var k2 = h_in * (Vn + m1)
	print(k2)
	var m2 = h_in * f_segundo_orden(t + h_in, Un + k1, Vn + m1)
	print(m2)
	var y_next = Un + 0.5 * (k1 + k2)
	print(y_next)
	var yp_next = Vn + 0.5 * (m1 + m2)
	print(yp_next)

	return [y_next, yp_next]


func f_segundo_orden(t, y, yp):
	return coef_a * t * yp + coef_b * y

func generar_trivia():
	etapa = 1
	opciones.clear()

	var tema = "EcuacionesDiferenciales"
	var disponibles = []
	for m in Global.metodos_por_tema[tema]:
		if not Global.metodos_usados[tema].has(m):
			disponibles.append(m)

	if disponibles.size() == 0:
		Global.metodos_usados[tema].clear()
		disponibles = Global.metodos_por_tema[tema].duplicate()

	metodo_actual = disponibles[randi() % disponibles.size()]
	Global.metodos_usados[tema].append(metodo_actual)
	print("Método elegido:", metodo_actual)

	generar_polinomio()
	t0 = 0.0
	y0 = round(randf_range(-2,2)*100)/100.0
	h = round(randf_range(0.1,0.5)*100)/100.0

	yp0 = round(randf_range(-2,2)*100)/100.0

	print("t0 =", fmt9(t0), " y0 =", fmt9(y0), " y'0 =", fmt9(yp0), " h =", fmt9(h))
	print("y1' =", funcion_completa_texto())

	var y1 = 0.0

	if metodo_actual == "EulerModificado":
		y1_dado = y0
		y1 = euler_modificado_y1prima(y0, y1_dado, t0, h)
		print("Etapa1 - y1 dado:", fmt9(y1_dado), " y1' calculado:", fmt9(y1))

	elif metodo_actual == "Runge-Kutta-2doOrden":
		y1 = rk2(y0, t0, h)

	elif metodo_actual == "Runge-Kutta-3erOrden":
		y1 = rk3(y0, t0, h)

	elif metodo_actual == "Runge-Kutta-1/3Simpson":
		y1 = rk413(y0, t0, h)

	elif metodo_actual == "Runge-Kutta-3/8Simpson":
		y1 = rk438(y0, t0, h)

	elif metodo_actual == "Runge-Kutta-Orden-Superior":
		coef_a = round(randf_range(-3,3)*100)/100.0
		coef_b = round(randf_range(-3,3)*100)/100.0
		print("coef_a=", fmt2(coef_a), " coef_b=", fmt2(coef_b))
		print("Ecuación generada: y'' = (%s)*t*y' + (%s)*y" % [fmt2(coef_a), fmt2(coef_b)])

		var r = rk_superior(y0, yp0, t0, h, coef_a, coef_b)
		y1_real = r[0]
		y1p_real = r[1]

		respuesta_correcta = "(%s , %s)" % [fmt9(y1_real), fmt9(y1p_real)]
		preparar_opciones_RK_superior(y1_real, y1p_real)
		mostrar_pregunta()
		return

	print("Etapa1 - Calculado:", fmt9(y1))
	respuesta_correcta = fmt9(y1)

	preparar_opciones_etapa()
	mostrar_pregunta()

func preparar_opciones_etapa():
	opciones.clear()
	opciones.append(respuesta_correcta)
	while opciones.size() < 4:
		var delta = randf_range(-0.03,0.03)
		var fake = float(respuesta_correcta) + delta
		var sf = fmt9(fake)
		if not opciones.has(sf):
			opciones.append(sf)
	opciones.shuffle()

func mostrar_pregunta():
	if etapa == 1:
		var texto = "Método: %s\nCalcular y1%s\nValores dados:\nt0=%.2f, y0=%.2f,y0'=%.2f, h=%.2f\n" % [
			metodo_actual,
			" usando y1 dado" if metodo_actual == "EulerModificado" else "",
			t0, y0,yp0, h
		]

		if metodo_actual == "EulerModificado":
			texto += "f(t,y) = %s\nDado y1 = %s" % [funcion_completa_texto(), fmt2(y1_dado)]
		elif metodo_actual == "Runge-Kutta-Orden-Superior":
			texto += "Ecuación: y'' = (%s)*t*y' + (%s)*y\n" % [fmt2(coef_a), fmt2(coef_b)]
			texto += "Calcular y1 y y1'"
		else:
			texto += "f(t,y) = %s" % funcion_completa_texto()

		label_problema.text = texto
	else:
		var mensaje = "Calcular "
		if metodo_actual == "EulerModificado":
			mensaje += "y2' usando y0=y1 dado y y1=y1' etapa1"
		elif metodo_actual == "Runge-Kutta-Orden-Superior":
			mensaje += "y2 y y2' "
		else:
			mensaje += "y2"
		label_problema.text = mensaje

	boton1.text = opciones[0]
	boton2.text = opciones[1]
	boton3.text = opciones[2]
	boton4.text = opciones[3]


func _on_opcion_1_pressed(): procesar_respuesta(0)
func _on_opcion_2_pressed(): procesar_respuesta(1)
func _on_opcion_3_pressed(): procesar_respuesta(2)
func _on_opcion_4_pressed(): procesar_respuesta(3)

func procesar_respuesta(index):
	var elegido = opciones[index]

	if etapa == 1 and metodo_actual == "Runge-Kutta-Orden-Superior":
		if elegido == respuesta_correcta:
			print("Etapa1 RK Superior correcta:", elegido)
			etapa = 2
			var t1 = t0 + h
			var r2 = rk_superior(y1_real, y1p_real, t1, h, coef_a, coef_b)
			y2_real = r2[0]
			y2p_real = r2[1]

			respuesta_correcta = "(%s , %s)" % [fmt9(y2_real), fmt9(y2p_real)]
			preparar_opciones_RK_superior(y2_real, y2p_real)
			mostrar_pregunta()
			return
		else:
			print("Etapa1 RK Superior incorrecto:", elegido, " - correcto:", respuesta_correcta)
			Global.trivia_exito = false
			_regresar_a_batalla()
			return

	if etapa == 1:
		if elegido == fmt9(float(respuesta_correcta)):
			print("Etapa1: Correcto seleccionado:", elegido)
			etapa = 2
			var t1 = t0 + h
			var y0_etapa2 = y1_dado if metodo_actual == "EulerModificado" else float(respuesta_correcta)
			var y1_etapa2 = float(respuesta_correcta) if metodo_actual == "EulerModificado" else 0.0
			var y2 = 0.0
			if metodo_actual == "EulerModificado":
				y2 = euler_modificado_y1prima(y0_etapa2, y1_etapa2, t1, h)
			elif metodo_actual == "Runge-Kutta-2doOrden":
				y2 = rk2(y0_etapa2, t1, h)
			elif metodo_actual == "Runge-Kutta-3erOrden":
				y2 = rk3(y0_etapa2, t1, h)
			elif metodo_actual == "Runge-Kutta-1/3Simpson":
				y2 = rk413(y0_etapa2, t1, h)
			elif metodo_actual == "Runge-Kutta-3/8Simpson":
				y2 = rk438(y0_etapa2, t1, h)
			respuesta_correcta = fmt9(y2)
			print("Etapa2 - Calculado y2:", fmt9(y2))
			preparar_opciones_etapa()
			mostrar_pregunta()
		else:
			print("Etapa1: Incorrecto seleccionado:", elegido, " - correcto:", fmt9(float(respuesta_correcta)))
			Global.trivia_exito = false
			_regresar_a_batalla()
	else:
		if metodo_actual == "Runge-Kutta-Orden-Superior":
			if elegido == respuesta_correcta:
				print("Etapa2 RK Superior correcta:", elegido)
				Global.trivia_exito = true
			else:
				print("Etapa2 RK Superior incorrecta:", elegido, " - correcto:", respuesta_correcta)
				Global.trivia_exito = false
			_regresar_a_batalla()
		else:
			if elegido == fmt9(float(respuesta_correcta)):
				print("Etapa2: Correcto seleccionado:", elegido)
				Global.trivia_exito = true
			else:
				print("Etapa2: Incorrecto seleccionado:", elegido, " - correcto:", fmt9(float(respuesta_correcta)))
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
		print("Tiempo agotado")

func actualizar_tiempo_label():
	label_tiempo.text = "Tiempo: %02d:%02d" % [int(tiempo_restante/60), int(tiempo_restante%60)]


func _regresar_a_batalla():
	var escena_batalla = ""
	var mundo_atual = Global.mundo_actual 
	if mundo_atual == 7:
		Global.batalla_final += 1
		escena_batalla ="res://Escenas/Mundo 7/Batalla_1.tscn"
		get_tree().change_scene_to_file(escena_batalla)
	
	else:
		match Global.batalla_actual:
			1: escena_batalla = "res://Escenas/Mundo 6/Batalla_1.tscn"
			2: escena_batalla = "res://Escenas/Mundo 6/Batalla_2.tscn"
			3: escena_batalla = "res://Escenas/Mundo 6/Batalla_3.tscn"
		get_tree().change_scene_to_file(escena_batalla)
