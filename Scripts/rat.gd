extends Enemy

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# Flip sprite if moving right, unflip if moving left
	if velocity.x > 0:
		sprite.flip_h = true
	elif velocity.x < 0:
		sprite.flip_h = false
