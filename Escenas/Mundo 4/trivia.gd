extends Control

@onready var label_problema = $ProblemaLabel
@onready var boton1 = $HBoxContainer/Opcion1
@onready var boton2 = $HBoxContainer/Opcion2
@onready var boton3 = $HBoxContainer/Opcion3
@onready var boton4 = $HBoxContainer/Opcion4
@onready var label_tiempo = $TiempoLabel

var metodo_actual = ""
var modelo_texto = ""
var x_vals = []
var y_vals = []
var true_coefs = []        
var coefs_est = []         
var opciones = []
var respuesta_correcta = null    
var respuesta_comprobacion = null
var tiempo_restante = 3000
var etapa = 1

func _ready():
	randomize()
	if not "metodos_por_tema" in Global:
		Global.metodos_por_tema = {}
	if not "metodos_usados" in Global:
		Global.metodos_usados = {}
	if not "MinimosCuadrados" in Global.metodos_por_tema:
		Global.metodos_por_tema["MinimosCuadrados"] = ["Recta","Cuadratica","Cubica","LinealFuncion","CuadraticaFuncion"]
	if not "MinimosCuadrados" in Global.metodos_usados:
		Global.metodos_usados["MinimosCuadrados"] = []

	generar_trivia()
	iniciar_temporizador()

func redondeo_n(valor):
	return round(valor * 1e9) / 1e9

func fmt9(v):
	return "%.9f" % v

func randf_range(a,b):
	return a + randf() * (b - a)

func generar_tabla():
	var n = 5
	x_vals.clear()
	y_vals.clear()

	for i in range(n):
		var xv = randf_range(1.0, 15.0)
		xv = snappedf(xv, 0.1)  
		x_vals.append(xv)

		var yv = randf_range(1.0, 10.0)
		yv = snappedf(yv, 0.1)   
		y_vals.append(yv)

	return n

func modelo_recta(x, coefs): return coefs[0] + coefs[1]*x
func modelo_cuadratica(x, coefs): return coefs[0] + coefs[1]*x + coefs[2]*x*x
func modelo_cubica(x, coefs): return coefs[0] + coefs[1]*x + coefs[2]*x*x + coefs[3]*x*x*x
func modelo_lineal_func(x, coefs): return coefs[0] + coefs[1]*x + coefs[2]*_eval_func(coefs[3], x)
func modelo_cuadratica_func(x, coefs): return coefs[0] + coefs[1]*x + coefs[2]*x*x + coefs[3]*_eval_func(coefs[4], x)

func _eval_func(func_id, x):
	if func_id == 0:
		return sin(x)
	elif func_id == 1:
		return cos(x)
	else:
		var c = cos(x)
		if abs(c) < 1e-3:
			return tan(x) * 0.5
		return tan(x)

func construir_disenio_y(modo):
	var X = []

	for i in range(x_vals.size()):
		var x = x_vals[i]
		var row = []

		match modo:
			"Recta":
				row = [1.0, x]
			"Cuadrática":
				row = [1.0, x, x*x]
			"Cúbica":
				row = [1.0, x, x*x, x*x*x]
			"LinealFunción":
				row = [1.0, x, _eval_func(true_coefs[3], x)]
			"CuadraticaFunción":
				row = [1.0, x, x*x, _eval_func(true_coefs[4], x)]
		X.append(row)
	return X

func minimos_cuadrados(X, y):
	var m = X.size()
	if m == 0: return []
	var p = X[0].size()
	var XT_X = []
	for i in range(p):
		XT_X.append([])
		for j in range(p):
			var s = 0.0
			for k in range(m):
				s += X[k][i] * X[k][j]
			XT_X[i].append(s)
	var XT_y = []
	for i in range(p):
		var s2 = 0.0
		for k in range(m):
			s2 += X[k][i] * y[k]
		XT_y.append(s2)
	return gaussian_solve(XT_X, XT_y)

func gaussian_solve(A_in,b_in):
	var n = A_in.size()
	var A = []
	for i in range(n):
		A.append([])
		for j in range(n):
			A[i].append(float(A_in[i][j]))
	var b = []
	for i in range(n):
		b.append(float(b_in[i]))

	for k in range(n):
		var maxrow = k
		var maxval = abs(A[k][k])
		for i in range(k+1, n):
			if abs(A[i][k]) > maxval:
				maxval = abs(A[i][k])
				maxrow = i
		if maxval < 1e-12:
			var zeros = []
			for i in range(n): zeros.append(0.0)
			return zeros
		if maxrow != k:
			var tmp = A[k]; A[k] = A[maxrow]; A[maxrow] = tmp
			var tmpb = b[k]; b[k] = b[maxrow]; b[maxrow] = tmpb
		for i in range(k+1,n):
			var factor = A[i][k]/A[k][k]
			for j in range(k,n):
				A[i][j] -= factor*A[k][j]
			b[i] -= factor*b[k]

	var x = []
	for i in range(n):
		x.append(0.0)
	for i in range(n-1,-1,-1):
		var s = b[i]
		for j in range(i+1,n):
			s -= A[i][j]*x[j]
		x[i] = s/A[i][i]
	return x

func generar_trivia():
	etapa = 1
	opciones.clear()
	var metodos_disponibles = Global.metodos_por_tema["MinimosCuadrados"]
	var usados = Global.metodos_usados.get("MinimosCuadrados",[])
	if usados.size() == metodos_disponibles.size():
		Global.metodos_usados["MinimosCuadrados"] = []
		usados = []

	while true:
		var metodo = metodos_disponibles[randi() % metodos_disponibles.size()]
		if not metodo in Global.metodos_usados["MinimosCuadrados"]:
			Global.metodos_usados["MinimosCuadrados"].append(metodo)
			metodo_actual = metodo
			break

	generar_tabla()

	match metodo_actual:
		"Recta":
			modelo_texto = ""
			true_coefs = [randf_range(-2.0,2.0),randf_range(-2.0,2.0)]
		"Cuadrática":
			modelo_texto = ""
			true_coefs = [randf_range(-2.0,2.0),randf_range(-2.0,2.0),randf_range(-1.5,1.5)]
		"Cúbica":
			modelo_texto = ""
			true_coefs = [randf_range(-1.5,1.5),randf_range(-1.5,1.5),randf_range(-1.0,1.0),randf_range(-0.5,0.5)]
		"LinealFunción":
			var func_id = randi()%3
			var fname = "sin" if func_id==0 else "cos" if func_id==1 else "tan"
			modelo_texto = "%s(x)" % fname
			true_coefs = [randf_range(-2.0,2.0),randf_range(-2.0,2.0),randf_range(-2.0,2.0),func_id]
		"CuadraticaFunción":
			var func_id = randi()%3
			var fname = "sin" if func_id==0 else "cos" if func_id==1 else "tan"
			modelo_texto = "%s(x)" % fname
			true_coefs = [randf_range(-2.0,2.0),randf_range(-2.0,2.0),randf_range(-1.5,1.5),randf_range(-2.0,2.0),func_id]

	var X = construir_disenio_y(metodo_actual)
	coefs_est = minimos_cuadrados(X, y_vals)
	for i in range(coefs_est.size()): coefs_est[i] = redondeo_n(coefs_est[i])

	print("\n--- Minimos Cuadrados ---")
	print("Metodo:", metodo_actual)
	print("Modelo:", modelo_texto)
	print("Puntos (x,y):")
	for i in range(x_vals.size()):
		print("  x=%.6f  y=%.6f" % [x_vals[i], y_vals[i]])
	print("Coef estimados:", coefs_est)
	print("Coef true:", true_coefs)

	var p = coefs_est.size()
	var idx1 = []
	var idx2 = []
	if p==2:
		idx1=[0]; idx2=[1]
	elif p==3:
		idx1=[0]; idx2=[1,2]
	elif p==4:
		idx1=[0,1]; idx2=[2,3]
	else:
		var half=int(p/2)
		for i in range(half): idx1.append(i)
		for i in range(half,p): idx2.append(i)

	if idx1.size()==1:
		respuesta_correcta = coefs_est[idx1[0]]
	else:
		var parts=[]; for i in idx1: parts.append(fmt9(coefs_est[i]))
		respuesta_correcta = ", ".join(parts)
	var parts2=[]; for i in idx2: parts2.append(fmt9(coefs_est[i]))
	respuesta_comprobacion = ", ".join(parts2)

	print("Etapa1 correcta:", respuesta_correcta)
	print("Etapa2 correcta:", respuesta_comprobacion)

	preparar_opciones()

func preparar_opciones():
	opciones.clear()
	if etapa==1:
		if typeof(respuesta_correcta)==TYPE_STRING:
			opciones.append(respuesta_correcta)
			while opciones.size()<4:
				var comps=respuesta_correcta.split(",")
				var fake=[]
				for c in comps:
					var v=float(c.strip_edges())
					var d=v*randf_range(-0.02,0.02)+randf_range(-1e-6,1e-6)
					fake.append(fmt9(redondeo_n(v+d)))
				var f=", ".join(fake)
				if not opciones.has(f): opciones.append(f)
		else:
			var c=respuesta_correcta
			opciones.append(c)
			while opciones.size()<4:
				var delta=randf_range(-0.02*abs(c),0.02*abs(c))
				var f=redondeo_n(c+delta)
				if not opciones.has(f): opciones.append(f)
	else:
		opciones.append(respuesta_comprobacion)
		while opciones.size()<4:
			var comps=respuesta_comprobacion.split(",")
			var fake=[]
			for c in comps:
				var v=float(c.strip_edges())
				var delta=randf_range(-0.015*abs(v),0.015*abs(v))
				fake.append(fmt9(redondeo_n(v+delta)))
			var f=", ".join(fake)
			if not opciones.has(f): opciones.append(f)
	opciones.shuffle()
	mostrar_pregunta()

func mostrar_pregunta():
	var txt = ""


	if etapa == 1:
		print("\n[CONSOLA] Etapa 1:")

		if typeof(respuesta_correcta) == TYPE_STRING:
			var n = respuesta_correcta.split(",").size()
			print("  → Debes responder", n, "coeficientes:")
			for i in range(n):
				print("     - Coeficiente x%d" % (i+1))
		else:
			print("  → Debes responder 1 coeficiente:")
			print("     - Coeficiente x1")

	else:
		print("\n[CONSOLA] Etapa 2:")
		var comps = respuesta_comprobacion.split(",")
		print("  → Debes responder", comps.size(), "coeficientes restantes:")
		for i in range(comps.size()):
			print("     - Coeficiente x%d" % (i+1))



	if etapa == 1:
		txt = "Mínimos cuadrados - %s\n%s " % [metodo_actual, modelo_texto]
		txt += "Ingresa "

		if typeof(respuesta_correcta) == TYPE_STRING:
			txt += "los coeficientes: x0 y x1\n" 
			txt += "Tabla (x,y):\n"
			for i in range(x_vals.size()):
				txt += "  x=%.2f   y=%.2f\n" % [x_vals[i], y_vals[i]]

		else:
			txt += "el coeficiente x0\n"
			txt += "Tabla (x,y):\n"
			for i in range(x_vals.size()):
				txt += "  x=%.2f   y=%.2f\n" % [x_vals[i], y_vals[i]]

	else:
		txt = "Mínimos cuadrados - \nIngresa los coeficientes restantes.\n\n" \
		% [metodo_actual, modelo_texto]
		
	label_problema.text = txt

	boton1.text = fmt9(opciones[0]) if typeof(opciones[0]) == TYPE_FLOAT else str(opciones[0])
	boton2.text = fmt9(opciones[1]) if typeof(opciones[1]) == TYPE_FLOAT else str(opciones[1])
	boton3.text = fmt9(opciones[2]) if typeof(opciones[2]) == TYPE_FLOAT else str(opciones[2])
	boton4.text = fmt9(opciones[3]) if typeof(opciones[3]) == TYPE_FLOAT else str(opciones[3])

	label_problema.text=txt

	boton1.text = fmt9(opciones[0]) if typeof(opciones[0])==TYPE_FLOAT else str(opciones[0])
	boton2.text = fmt9(opciones[1]) if typeof(opciones[1])==TYPE_FLOAT else str(opciones[1])
	boton3.text = fmt9(opciones[2]) if typeof(opciones[2])==TYPE_FLOAT else str(opciones[2])
	boton4.text = fmt9(opciones[3]) if typeof(opciones[3])==TYPE_FLOAT else str(opciones[3])

func _on_opcion_1_pressed(): procesar_respuesta(0)
func _on_opcion_2_pressed(): procesar_respuesta(1)
func _on_opcion_3_pressed(): procesar_respuesta(2)
func _on_opcion_4_pressed(): procesar_respuesta(3)

func procesar_respuesta(index):
	var elegido = opciones[index]
	if etapa==1:
		var ok=false
		if typeof(respuesta_correcta)==TYPE_STRING:
			ok = str(elegido)==str(respuesta_correcta)
		else:
			ok = redondeo_n(float(elegido))==redondeo_n(float(respuesta_correcta))
		if ok:
			etapa=2
			print("Respuesta Etapa1 correcta seleccionada:", elegido)
			preparar_opciones()
		else:
			print("Respuesta Etapa1 incorrecta:", elegido)
			Global.trivia_exito=false
			_regresar_a_batalla()
	else:
		if str(elegido)==str(respuesta_comprobacion):
			print("Respuesta Etapa2 correcta seleccionada:", elegido)
			Global.trivia_exito=true
		else:
			print("Respuesta Etapa2 incorrecta:", elegido)
			Global.trivia_exito=false
		_regresar_a_batalla()

func iniciar_temporizador():
	actualizar_tiempo_label()
	temporizador_tick()

func temporizador_tick():
	await get_tree().create_timer(1.0).timeout
	tiempo_restante-=1
	actualizar_tiempo_label()
	if tiempo_restante>0:
		temporizador_tick()
	else:
		Global.trivia_exito=false
		_regresar_a_batalla()

func actualizar_tiempo_label():
	var minutos=int(tiempo_restante/60)
	var segundos=int(tiempo_restante%60)
	label_tiempo.text="Tiempo: %02d:%02d" % [minutos,segundos]

func _regresar_a_batalla():
	var escena_batalla = ""
	var mundo_atual = Global.mundo_actual 
	if mundo_atual == 7:
		Global.batalla_final += 1
		escena_batalla ="res://Escenas/Mundo 7/Batalla_1.tscn"
		get_tree().change_scene_to_file(escena_batalla)
	
	else:
		match Global.batalla_actual:
			1: escena_batalla = "res://Escenas/Mundo 4/Batalla_1.tscn"
			2: escena_batalla = "res://Escenas/Mundo 4/Batalla_2.tscn"
			3: escena_batalla = "res://Escenas/Mundo 4/Batalla_3.tscn"
		get_tree().change_scene_to_file(escena_batalla)
