extends Node

# ----------------- ACCIÓN Y RESULTADO -----------------
var accion_pendiente = null  # "ataque1", "ataque2", "curar"
var trivia_exito = false

# ----------------- VIDA DEL JUGADOR Y ENEMIGOS -----------------
var player_hp = 100
var enemigos_hp = {
	"Mundo1_Enemigo1": 30,
	"Mundo1_Enemigo2": 40,
	"Mundo1_Enemigo3": 50,
	"Mundo2_Enemigo1": 60,
	"Mundo2_Enemigo2": 70,
	"Mundo2_Enemigo3": 80,
	"Mundo3_Enemigo1": 90,
	"Mundo3_Enemigo2": 100,
	"Mundo3_Enemigo3": 110,
	"Mundo4_Enemigo1": 120,
	"Mundo4_Enemigo2": 130,
	"Mundo4_Enemigo3": 140,
	"Mundo5_Enemigo1": 150,
	"Mundo5_Enemigo2": 160,
	"Mundo5_Enemigo3": 170,
	"Mundo6_Enemigo1": 180,
	"Mundo6_Enemigo2": 190,
	"Mundo6_Enemigo3": 200
}

var enemigos_hpt = {
	"Mundo1_Enemigo1": 30,
	"Mundo1_Enemigo2": 40,
	"Mundo1_Enemigo3": 50,
	"Mundo2_Enemigo1": 60,
	"Mundo2_Enemigo2": 70,
	"Mundo2_Enemigo3": 80,
	"Mundo3_Enemigo1": 90,
	"Mundo3_Enemigo2": 100,
	"Mundo3_Enemigo3": 110,
	"Mundo4_Enemigo1": 120,
	"Mundo4_Enemigo2": 130,
	"Mundo4_Enemigo3": 140,
	"Mundo5_Enemigo1": 150,
	"Mundo5_Enemigo2": 160,
	"Mundo5_Enemigo3": 170,
	"Mundo6_Enemigo1": 180,
	"Mundo6_Enemigo2": 190,
	"Mundo6_Enemigo3": 200
}

# ----------------- BATALLA ACTUAL -----------------
var batalla_actual = 1

# ----------------- MÉTODOS POR TEMA -----------------
var metodos_por_tema = {
	"Interpolacion": ["Lineal","NewtonAdelante","NewtonAtras","DiferenciasDivididas","Lagrange"]
}
var metodos_usados = {
	"Interpolacion": []
}

# ----------------- MUNDO ACTUAL -----------------
var mundo_actual = 1

# ----------------- FUNCIONES -----------------
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

# ----------------- GUARDAR Y CARGAR -----------------
func guardar_global():
	var datos = {
		"player_hp": player_hp,
		"enemigos_hp": enemigos_hp,
		"batalla_actual": batalla_actual,
		"metodos_usados": metodos_usados,
		"mundo_actual": mundo_actual
	}

	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(datos))  # stringify sigue siendo estático
		file.close()
		print("Juego guardado!")

func cargar_global():
	if FileAccess.file_exists("user://savegame.json"):
		var file = FileAccess.open("user://savegame.json", FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()          # <-- crear instancia de JSON
			var result = json.parse(json_string)
			if result == OK:
				var datos = json.get_data()  # obtiene el diccionario
				player_hp = datos.get("player_hp", 100)
				enemigos_hp = datos.get("enemigos_hp", enemigos_hp)
				batalla_actual = datos.get("batalla_actual", 1)
				metodos_usados = datos.get("metodos_usados", metodos_usados)
				mundo_actual = datos.get("mundo_actual", 1)
				print("Juego cargado, mundo actual:", mundo_actual)
			else:
				print("Error al parsear JSON")
