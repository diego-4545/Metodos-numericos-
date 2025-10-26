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

# ----------------- BATALLA ACTUAL -----------------
var batalla_actual = 1  # 1, 2 o 3

# ----------------- MÉTODOS POR TEMA -----------------
var metodos_por_tema = {
	"Interpolacion": ["Lineal","NewtonAdelante","NewtonAtras","DiferenciasDivididas","Lagrange"],
	# Ejemplo futuro: "Derivadas": ["DerivadaSimple","DerivadaCompuesta"]
}

var metodos_usados = {
	"Interpolacion": []
	# Ejemplo futuro: "Derivadas": []
}

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
