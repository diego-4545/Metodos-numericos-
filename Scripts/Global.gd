extends Node

# ------------------------------
# Variables globales
# ------------------------------
var accion_pendiente = null
var trivia_exito = false

var player_hp = 100
var enemigos_hp = {
	"Mundo1_Enemigo1": 30, "Mundo1_Enemigo2": 40, "Mundo1_Enemigo3": 50,
	"Mundo2_Enemigo1": 60, "Mundo2_Enemigo2": 70, "Mundo2_Enemigo3": 80,
	"Mundo3_Enemigo1": 90, "Mundo3_Enemigo2": 100, "Mundo3_Enemigo3": 110,
	"Mundo4_Enemigo1": 120, "Mundo4_Enemigo2": 130, "Mundo4_Enemigo3": 140,
	"Mundo5_Enemigo1": 150, "Mundo5_Enemigo2": 160, "Mundo5_Enemigo3": 170,
	"Mundo6_Enemigo1": 180, "Mundo6_Enemigo2": 190, "Mundo6_Enemigo3": 200,
	"Mundo7_Enemigo1": 600
}
var enemigos_hpt = enemigos_hp.duplicate()

var batalla_actual = 1
var batalla_final = 1
var mundo_actual = 1

var metodos_por_tema = {
	"Interpolacion": ["Lineal","NewtonAdelante","NewtonAtras","DiferenciasDivididas","Lagrange"],
	"EcuacionesNoLineales": ["Grafico", "FalsaPosicion", "PuntoFijo", "Secante"],
	"SistemasLineales": ["EliminacionGaussiana", "GaussJordan", "Montante", "Jacobi", "GaussSeidel"],
	"MinimosCuadrados": ["Recta","Cuadrática","Cúbica","LinealFunción","CuadraticaFunción"],
	"Integrales": ["Trapecio", "Simpson1/3", "Simpson3/8", "Newton-CotesCerrados", "Newton-CotesAbiertos"],
	"EcuacionesDiferenciales": ["EulerModificado","Runge-Kutta-2doOrden","Runge-Kutta-3erOrden","Runge-Kutta-1/3Simpson","Runge-Kutta-3/8Simpson","Runge-Kutta-Orden-Superior"]
}

var metodos_usados = {
	"Interpolacion": [], "EcuacionesNoLineales": [], "SistemasLineales": [],
	"MinimosCuadrados": [], "Integrales": [], "EcuacionesDiferenciales": []
}

const SAVE_FILE := "user://savegame.save"

func guardar_juego():
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo guardar")
		return

	var datos = {
		"mundo_actual": mundo_actual,
		"batalla_actual": batalla_actual
	}

	file.store_var(datos)
	file.close()
	print("Juego guardado.")


func cargar_juego():
	if not FileAccess.file_exists(SAVE_FILE):
		print("No hay archivo de guardado, usando valores por defecto.")
		return

	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir guardado.")
		return

	var datos: Dictionary = file.get_var()
	file.close()

	mundo_actual = datos.get("mundo_actual", 1)
	batalla_actual = datos.get("batalla_actual", 1)

	print("Juego cargado. Mundo:", mundo_actual, " Batalla:", batalla_actual)


func obtener_metodo_sin_repetir(tema):
	var disponibles = []
	for m in metodos_por_tema[tema]:
		if !metodos_usados[tema].has(m):
			disponibles.append(m)
	if disponibles.size() == 0:
		metodos_usados[tema].clear()
		disponibles = metodos_por_tema[tema].duplicate()
	var index = randi() % disponibles.size()
	var metodo = disponibles[index]
	metodos_usados[tema].append(metodo)
	return metodo
