extends CharacterBody2D

const SPEED = 75

enum PlayerState { IDLE, WALK, ATTACK }
var state: PlayerState = PlayerState.IDLE
var idle_direction = Vector2(0, -1)
var last_walk_direction := Vector2.ZERO

@onready var player_animate_node = $AnimatedSprite2D
@onready var sword_animate_node = $AttackArea/AnimationPlayer
@onready var attack_area = $AttackArea

func _ready() -> void:
	player_animate_node.animation_finished.connect(_on_animation_finished)
	attack_area.visible = false

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")

	match state:
		PlayerState.ATTACK:
			velocity = Vector2.ZERO
			attack_area.visible = true
			move_and_slide()
			return
		PlayerState.WALK:
			velocity = direction * SPEED
		PlayerState.IDLE:
			velocity = Vector2.ZERO

	move_and_slide()

	# State transitions
	if state != PlayerState.ATTACK:
		if Input.is_action_just_pressed("attack"):
			state = PlayerState.ATTACK
			play_attack_animation()
			return
		elif direction != Vector2.ZERO:
			if state != PlayerState.WALK:
				state = PlayerState.WALK
				play_walk_animation(direction)
			elif direction != last_walk_direction:
				play_walk_animation(direction)
			idle_direction = direction
			last_walk_direction = direction
		else:
			if state != PlayerState.IDLE:
				state = PlayerState.IDLE
				play_idle_animation()
			last_walk_direction = Vector2.ZERO

func play_attack_animation() -> void:
	sword_animate_node.stop()
	if idle_direction.x > 0:
		player_animate_node.play("attack_right")
		sword_animate_node.play("attack_right")
		attack_area.z_index = 0 # In front
	elif idle_direction.x < 0:
		player_animate_node.play("attack_left")
		sword_animate_node.play("attack_left")
		attack_area.z_index = 0 # In front
	elif idle_direction.y > 0:
		player_animate_node.play("attack_down")
		sword_animate_node.play("attack_down")
		attack_area.z_index = 0 # In front
	elif idle_direction.y < 0:
		player_animate_node.play("attack_up")
		sword_animate_node.play("attack_up")
		attack_area.z_index = -1 # Behind

func play_walk_animation(direction: Vector2) -> void:
	if direction.x > 0:
		player_animate_node.play("walk_right")
	elif direction.x < 0:
		player_animate_node.play("walk_left")
	elif direction.y > 0:
		player_animate_node.play("walk_down")
	elif direction.y < 0:
		player_animate_node.play("walk_up")

func play_idle_animation() -> void:
	if idle_direction.x > 0:
		player_animate_node.play("idle_right")
	elif idle_direction.x < 0:
		player_animate_node.play("idle_left")
	elif idle_direction.y > 0:
		player_animate_node.play("idle_down")
	elif idle_direction.y < 0:
		player_animate_node.play("idle_up")

func _on_animation_finished() -> void:
	if state == PlayerState.ATTACK:
		# After attack, return to idle or walk
		attack_area.visible = false
		var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if direction != Vector2.ZERO:
			state = PlayerState.WALK
			play_walk_animation(direction)
		else:
			state = PlayerState.IDLE
			play_idle_animation()
