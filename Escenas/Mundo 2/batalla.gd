extends Control


var player_hp = 100
var enemy_hp = 30
var mundo = Global.mundo_actual
var batalla = Global.batalla_actual
var ve = "Mundo%d_Enemigo%d" % [mundo, batalla]
var enemy_hpt = 0
var player_turn = true
@onready var animj = $Jugador
@onready var animm = $ManosJ
@onready var animc = $Curar
@onready var animz = $Enemigo



func _ready():

	player_hp = Global.player_hp
	enemy_hpt = Global.enemigos_hpt[ve]
	enemy_hp = Global.enemigos_hp[ve]
	animj.play("default")
	animm.play("Invisible")
	animc.play("Invisible")
	animz.play("EnemigoD")

	update_ui()
	actualizar_botones()

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
	$VidaEnemigoLabel.text = "%d/%d" % [enemy_hp,enemy_hpt]

	Global.player_hp = player_hp
	Global.enemigos_hp[ve] = enemy_hp

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
		check_battle_state()
		enemy_turn()

func enemy_turn():
	check_battle_state()
	var tree = Engine.get_main_loop() as SceneTree   

	await tree.create_timer(2.0).timeout
	animz.position += Vector2(-520, 0)
	animz.play("AtaqueE")

	await tree.create_timer(1.0).timeout
	var dmg = 20
	player_hp -= dmg
	animz.position += Vector2(520, 0)
	animz.play("EnemigoD")
	update_ui()
	check_battle_state()

	if player_hp > 0:

		player_turn = true
		actualizar_botones()


func check_battle_state():
	if enemy_hp <= 0:
		print("¡Ganaste!")
		animz.play("MuerteE")
		await get_tree().create_timer(2).timeout
		(Engine.get_main_loop() as SceneTree).change_scene_to_file("res://Ganaste.tscn")
		set_process(false)
	elif player_hp <= 0:
		print("Perdiste...")
		animj.play("Muerte")
		await get_tree().create_timer(2).timeout
		(Engine.get_main_loop() as SceneTree).change_scene_to_file("res://Perdiste.tscn")
		set_process(false)
		animj.play("Muerte")

func procesar_resultado_trivia():
	match Global.accion_pendiente:
		"ataque1":
			if Global.trivia_exito:
				player_turn = false
				animj.position += Vector2(500, 0)
				animm.position += Vector2(500, 0)
				animj.play("Golpe")
				animm.play("Manos Golpe")
				
				await get_tree().create_timer(2).timeout
				player_turn = true
				player_attack(25)
				animj.position += Vector2(-500, 0)
				animm.position += Vector2(-500, 0)
				animj.play("default")
				animm.play("Invisible")
				
			else:
				player_turn = false
				actualizar_botones()
				enemy_turn()  
		"ataque2":
			if Global.trivia_exito:
				player_turn = false
				animj.position += Vector2(500, 0)
				animm.position += Vector2(500, 0)
				animj.play("Golpe")
				animm.play("Bate")
				
				await get_tree().create_timer(2).timeout
				player_turn = true
				player_attack(30)
				animj.position += Vector2(-500, 0)
				animm.position += Vector2(-500, 0)
				animj.play("default")
				animm.play("Invisible")
			else:
				player_turn = false
				actualizar_botones()
				enemy_turn() 
		"curar":

			if Global.trivia_exito:
				player_turn = false
				animc.play("Curar")
				await get_tree().create_timer(2).timeout
				player_turn = true
				player_heal(25)
				animc.play("Invisible")
			else:
				player_turn = false
				actualizar_botones()
				enemy_turn() 
func _on_attack_1_button_pressed():
	Global.accion_pendiente = "ataque1"
	get_tree().change_scene_to_file("res://Escenas/Mundo 2/TRIVIA.tscn")

func _on_attack_2_button_pressed():
	Global.accion_pendiente = "ataque2"
	get_tree().change_scene_to_file("res://Escenas/Mundo 2/TRIVIA.tscn")

func _on_heal_button_pressed():
	Global.accion_pendiente = "curar"
	get_tree().change_scene_to_file("res://Escenas/Mundo 2/TRIVIA.tscn")
