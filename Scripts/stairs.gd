extends StaticBody2D

signal player_tried_exiting_level

func _on_exit_area_body_entered(body: Node2D) -> void:
	if body is Player:
		emit_signal("player_tried_exiting_level")
