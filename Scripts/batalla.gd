extends Control

var player_hp = 100
var enemy_hp = 30
var player_turn = true

func _ready():
	# Cargar HP desde Global
	player_hp = Global.player_hp
	enemy_hp = Global.enemigos_hp["Mundo1_Enemigo1"]


	update_ui()
	actualizar_botones()

	# Si venimos de TRIVIA, procesar la acción pendiente
	if Global.accion_pendiente != "":
		procesar_resultado_trivia()
		Global.accion_pendiente = ""
		actualizar_botones()

func update_ui():
	$PlayerHPBar.value = player_hp
	if enemy_hp <= 0:
		enemy_hp = 0
	$EnemyHPBar.value = enemy_hp
	$VidaPlayerLabel.text = "%d/100" % player_hp
	$VidaEnemigoLabel.text = "%d/30" % enemy_hp

	# Guardar HP en Global
	Global.player_hp = player_hp
	Global.enemigos_hp["Mundo1_Enemigo1"] = enemy_hp

func actualizar_botones():
	var bloqueados = not player_turn
	get_node("HBoxContainer/Attack1Button").disabled = bloqueados
	get_node("HBoxContainer/Attack2Button").disabled = bloqueados
	get_node("HBoxContainer/HealButton").disabled = bloqueados

func player_attack(damage):
	if player_turn:
		enemy_hp -= damage
		update_ui()
		check_battle_state()
		player_turn = false
		actualizar_botones()
		enemy_turn()

func player_heal(amount):
	if player_turn:
		player_hp += amount
		if player_hp > 100:
			player_hp = 100
		update_ui()
		player_turn = false
		actualizar_botones()
		enemy_turn()

func enemy_turn():
	await get_tree().create_timer(1.0).timeout
	var dmg = 20
	player_hp -= dmg
	update_ui()
	check_battle_state()
	player_turn = true
	actualizar_botones()

func check_battle_state():
	if enemy_hp <= 0:
		print("¡Ganaste!")
		set_process(false)
	elif player_hp <= 0:
		print("Perdiste...")
		set_process(false)

func procesar_resultado_trivia():
	match Global.accion_pendiente:
		"ataque1":
			if Global.trivia_exito:
				player_attack(15)
			else:
				player_turn = false
				actualizar_botones()
				enemy_turn()  # turno enemigo si falla
		"ataque2":
			if Global.trivia_exito:
				player_attack(25)
			else:
				player_turn = false
				actualizar_botones()
				enemy_turn()  # turno enemigo si falla		"curar":
			if Global.trivia_exito:
				player_heal(20)
			else:
				player_turn = false
				actualizar_botones()
				enemy_turn()  # turno enemigo si falla
# BOTONES
func _on_attack_1_button_pressed():
	Global.accion_pendiente = "ataque1"
	Global.batalla_actual = 1
	get_tree().change_scene_to_file("res://Escenas/Mundo 1/TRIVIA.tscn")

func _on_attack_2_button_pressed():
	Global.accion_pendiente = "ataque2"
	Global.batalla_actual = 1
	get_tree().change_scene_to_file("res://Escenas/Mundo 1/TRIVIA.tscn")

func _on_heal_button_pressed():
	Global.accion_pendiente = "curar"
	Global.batalla_actual = 1
	get_tree().change_scene_to_file("res://Escenas/Mundo 1/TRIVIA.tscn")
