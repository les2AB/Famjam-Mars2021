# Jeu n°1
# presser la bonne touche avant d'être touché par le monstre.
extends Node


onready var world = get_parent()
onready var enemy = preload("res://scenes/game_1_Blork.tscn")

onready var barbare       = $Barbare
onready var blork         = $Blork
onready var barbare_sprite= $Barbare/Animation
onready var musique       = $Musique
onready var again_label   = $Cadre/Again
onready var score_label   = $Cadre/Score
onready var letter_label  = $Cadre/Lettre
onready var gameover_label= $Cadre/GameOver
onready var kick_sounds= [$Barbare/Audio_kicks/coups1, $Barbare/Audio_kicks/coups2, \
						  $Barbare/Audio_kicks/coups3, $Barbare/Audio_kicks/coups4, \
						  $Barbare/Audio_kicks/coups5, $Barbare/Audio_kicks/coups6, \
						  $Barbare/Audio_kicks/coups7 ]

onready var cris_sounds= [$Barbare/Audio_cris/cris1, $Barbare/Audio_cris/cris2, \
				 		  $Barbare/Audio_cris/cris3, $Barbare/Audio_cris/cris4, \
						  $Barbare/Audio_cris/cris5, $Barbare/Audio_cris/cris6]


var score = 0
# lettres
var current_letter
var current_letter_code
var letters      = ["Q"  , "S"  , "D"  , "F"  , "J"  , "K"  , "L"  , "M"  , "G"  , "H"  ,\
					"A"  , "Z"  , "E"  , "R"  , "T"  , "Y"  , "U"  , "I"  , "O"  , "P"  ,\
					"W"  , "X"  , "C"  , "V"  , "B"  , "N"]
var letters_code = [KEY_Q, KEY_S, KEY_D, KEY_F, KEY_J, KEY_K, KEY_L, KEY_M, KEY_G, KEY_H, \
					KEY_A, KEY_Z, KEY_E, KEY_R, KEY_T, KEY_Y, KEY_U, KEY_I, KEY_O, KEY_P, \
					KEY_W, KEY_X, KEY_C, KEY_V, KEY_B, KEY_N]

var current_audio_attack
var current_audio_cris
# monstre courant = blork
var current_blork
var current_blork_speed =Vector2()
# timer pour des pauses et délais
var timers = [Timer.new(), Timer.new(), Timer.new(), Timer.new()]
var timer1 = timers[0]
var timer2 = timers[1]
var timer3 = timers[2]
var timer4 = timers[3]


# état du joueur # 
# * PLAYING : en tran de jouer ?
# * WAITING : perdu
var  current_state
enum State {PLAYING, WAITING}
# en attente de saisie clavier ou pas
var current_answer
enum Answer {WAITING, DONE}


# arrêt de tous les timers
func _stop_timers():
	for e in timers:
		e.stop()


func _ready() -> void :
	# initialisation des affichages et du score
	current_state = State.WAITING
	current_audio_attack = kick_sounds[0]
	current_audio_cris = cris_sounds[0]
	musique.playing = true
	current_letter = letters[0]
	current_letter_code = letters_code[0]
	letter_label.visible = false
	score_label.text = "Score : " + str (score)
	
	timer3.set_wait_time( 2 )
	timer3.connect("timeout",self,"_on_timer3_timeout") 
	add_child(timer3)
	timer3.start()


func _on_timer3_timeout():
	current_state = State.PLAYING
	_stop_timers()


# apparition d'un nouveau blork
func new_enemy() -> void:
	blork.add_child(enemy.instance())
	current_blork= blork.get_children()[0]
	current_blork.position.x = 900
	current_blork.position.y = 320
	current_blork_speed.x    = -300 - score
	# lettre aléatoire
	var tirage = randi() % len(letters)
	current_letter = letters[tirage]
	current_letter_code = letters_code[tirage]
	letter_label.text = current_letter
	letter_label.visible = true
	# en attente de saisie clavier
	current_answer = Answer.WAITING


# destruction d'un blork
func _shoot_enemy() -> void:
	current_answer = Answer.DONE
	score += 10
	score_label.text = "Score : " + str (score)
	letter_label.visible = false
	# animation + audio + suppression enemy
	barbare_sprite.play("attack")
	barbare_sprite.frame = 0
	current_audio_attack = kick_sounds[ randi() % len(kick_sounds) ]
	current_audio_attack.playing = true
	current_audio_cris = cris_sounds[ randi() % len(cris_sounds) ]
	current_audio_cris.playing = true
	current_blork.queue_free()


# signal émis par la scène `game_1.tscn` : fin de l'animation attaque
func _on_Perso_animation_finished() -> void:
	barbare_sprite.play("idle")
	

# recommencer une partie
func _restart_game() -> void:
	world.on_game_start( 1 )
	queue_free()


# retour à la salle d'arcade
func _leave_game() -> void:
	world._loader_start( 1 )
	queue_free()


func _on_Barbare_body_entered(_body) -> void:
	_game_over()


# partie perdue
# mise à jour affichage / audio / états
func _game_over() -> void :
	if current_state == State.PLAYING:
		if current_blork != null:
			current_blork.queue_free()
		
		current_state = State.WAITING
		musique.playing = false
		letter_label.visible = false
		barbare.visible = false
		gameover_label.visible = true

		_stop_timers()
		timer1.set_wait_time( 1 )
		timer1.connect("timeout",self,"_show_again_label") 
		add_child(timer1)
		timer1.start()


# affichage du texte pour recommencer une partie
func _show_again_label():
	_stop_timers()
	again_label.visible = true	
	again_label.percent_visible = 0

	timer2.set_wait_time( 0.1 )
	timer2.connect("timeout",self,"_scroll_again_label") 
	add_child(timer2)
	timer2.start()


# animation du texte pour recommencer une partie
var i=0
func _scroll_again_label():
	if i > 10:
		_stop_timers()
		again_label.percent_visible = 1
	else:
		again_label.percent_visible += 0.1
		i += 1


# écoute des événements claviers
func _input(event):
	if event is InputEventKey and event.is_pressed():
		var letter = event.scancode
		if  letter == current_letter_code and current_blork != null:
			if barbare_sprite.animation == "idle" and current_answer == Answer.WAITING:
				_shoot_enemy()
		
		# partie perdue
		if current_state == State.WAITING:
			if letter == KEY_O:
				_restart_game()
			elif letter == KEY_N:
				_leave_game()


# animation du blork
func _process(_delta):
	if current_state == State.PLAYING:
		if current_blork != null:
			current_blork.move_and_slide(current_blork_speed, Vector2(0, -1))
		else:
			new_enemy()