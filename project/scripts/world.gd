extends Control


const LOADER_1 = preload("res://scenes/loader_1.tscn")
const LOADERS  = [LOADER_1]

const GAME_1 = preload("res://scenes/game_1.tscn")
const GAMES  = [GAME_1]

var arcade = preload("res://scenes/arcade.tscn")


# Point d'entré du jeu. Ouvre le splash_screen d'accueil.
func _ready():
	# changement du seed aléatoire
	randomize()
	_random_loader_start()


# Charge le loader d'ID connu.
func _loader_start( id:int ) -> void :
	add_child( LOADERS[id-1].instance() )


# Charge un loader au hasard parmis la liste `loaders`.
func _random_loader_start() -> void:
	_loader_start ( randi() % len(LOADERS) )
	 

# Méthode appelée lorsque le loader chargé termine.
# Charger la scène `arcade`
func on_loader_exit() -> void:
	_arcade_start()


# Charge la salle d'arcade.
func _arcade_start() -> void:
	add_child(arcade.instance()) 


# Méthode appelée par la `arcade.gd` pour charger le jeu n° ID.
func on_game_start( id:int ) -> void:
	var game = GAMES [ id-1 ]
	# chargement de la scène game_ID
	# add_child(game01.instance()) bugue donc remplacé par :
	call_deferred("add_child", game.instance())