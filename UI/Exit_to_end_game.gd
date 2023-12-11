extends Area3D



func _on_body_entered(body):
	if body.name == "Player":
		if name == "Exit_to_end_game":
			var _target = get_tree().change_scene_to_file("res://UI/end_game.tscn")
