# Splash screen n°1
# il faut taper une lettre avant la fin du chargement de la barre
extends Control


onready var consigne  = $Consigne
onready var barre     = $Barre
onready var game_over = $Control/Game_over
onready var again     = $Control/Game_over_again
onready var music     = $Musique
onready var rire      = $Rire


# état du joueur durant le splash screen
# 
# * PLAYING : il peut toucher le clavier pour sortir du loader
# * WAITING : c'est fini, il faut recommencer le loader...
enum State {PLAYING, WAITING}


# état du joueur
var state
# timer divers et variés... (pour faire des pauses)
var timers = [Timer.new(), Timer.new(), Timer.new()]


# initialisation des affichages
# puis mise en place d'un timer
#
# * après 4×100ms : affichage de la barre
# * après 8×100ms : animation de la barre
func _ready():
	barre.visible = false
	barre.frame = 0
	game_over.visible = false
	again.visible = false
	consigne.visible = true
	state = State.PLAYING

	# ajout d'un délai avant affichage de la barre
	timers[0].set_wait_time( 0.1 )
	timers[0].connect("timeout",self,"_on_timer_timeout") 
	add_child(timers[0])
	timers[0].start()

var i = 0
func _on_timer_timeout():
	if i == 4 :
		barre.visible= true
	elif i == 8 :
		_stop_timers()
		barre.play()
	i += 1

	
func _stop_timers() -> void :
	for t in timers:
		t.stop()

# Quitter le loader en cas de victoire
# méthode `World.on_loader_exit()` pour aller en salle d'arcade
func _leave_barre():
	var world= get_parent()
	world.on_loader_exit()
	queue_free()


# signal émis par la scène lorsque l'animation est finie : partie perdue...
func _on_Barre_animation_finished():
	_game_over()


# fin de partie :
#
# * changement des affichages
# * rire
# * arrêt de la musique
# * délais => texte pour recommencer ou pas
func _game_over():
	_stop_timers()
	state = State.WAITING
	music.playing = false
	rire.playing = true
	barre.visible = false
	consigne.visible = false
	game_over.visible = true

	timers[2].set_wait_time( 1 )
	timers[2].connect("timeout",self,"_show_end_text") 
	add_child(timers[2])
	timers[2].start()


# Affichage du texte pour recommencer une partie
func _show_end_text():
	_stop_timers()
	again.visible = true	
	again.percent_visible = 0

	timers[1].set_wait_time( 0.1 )
	timers[1].connect("timeout",self,"_scroll_end_text") 
	add_child(timers[1])
	i= 0
	timers[1].start()


# Animation pour dérouler le texte
func _scroll_end_text():
	if i > 10:
		_stop_timers()
		again.percent_visible = 1
	else:
		again.percent_visible += 0.1
		i += 1


func _input(event):
	if event is InputEventKey and event.is_pressed():
		var letter = event.scancode
		if state == State.PLAYING:
			if letter == KEY_Q:
				# gagné : quittre le loader
				_leave_barre()
			else:
				_game_over()
		
		# partie perdue
		# * `O` pour relancer le loader
		# * `N` pour reécrire le texte
		if state == State.WAITING:
			if letter == KEY_O:
				var _vscode_ = get_tree().reload_current_scene()
			if letter == KEY_N:
				_show_end_text()

