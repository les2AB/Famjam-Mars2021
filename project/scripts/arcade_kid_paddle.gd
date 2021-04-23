# déplacement du personnage KidPaddle dans la salle d'arcade
extends KinematicBody2D


onready var audio_pas:AudioStreamPlayer2D = $Audio_pas_01


# vitesse de déplacement
const SPEED = 200
# Orientation de la scene vers le haut
const FLOOR_NORMAL = Vector2(0, -1)
# direction de déplacement du personnage
var motion =Vector2()


func _ready():
	# bruits de pas : préchargement, mise en pause
	audio_pas.playing = true
	audio_pas.stream_paused = true



func _physics_process(_delta):
	if Input.is_action_pressed("ui_right"):
		audio_pas.stream_paused = false
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.play("walk")
		motion.x = SPEED
	elif Input.is_action_pressed("ui_left"):
		audio_pas.stream_paused = false
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.play("walk")
		motion.x = -SPEED
	elif Input.is_action_pressed("ui_up"):
		audio_pas.stream_paused = false
		$AnimatedSprite.play("walk")
		motion.y = -SPEED
	elif Input.is_action_pressed("ui_down"):
		audio_pas.stream_paused = false
		$AnimatedSprite.play("walk")
		motion.y = SPEED	
	else:
		audio_pas.stream_paused = true
		motion.x = 0
		motion.y = 0
		$AnimatedSprite.play("idle")
		pass
		
	var _vscode_ = move_and_slide(motion, FLOOR_NORMAL)	
		
