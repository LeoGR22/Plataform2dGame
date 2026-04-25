extends Node2D

@export var move_speed = 5.0 #velocidade da suavização
var height = 25

func _process(delta):
	var players = get_tree().get_nodes_in_group("players")
	
	if players.size() > 0:
		var target_pos = Vector2.ZERO
		
		for player in players:
			target_pos += player.global_position
		target_pos /= players.size()
		target_pos.y -= height
		
		global_position = global_position.lerp(target_pos, move_speed * delta)
