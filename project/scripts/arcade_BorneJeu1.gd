extends Sprite


# signal émis par la scène
# 
# * affichage de la scène game_1 (via la méthode de world.gd)
# * destruction de la scène arcade
func _on_Area2D_body_entered(_body):
	var arcade= get_parent()
	var world = arcade.get_parent()
	world.on_game_start(1)
	arcade.queue_free()
