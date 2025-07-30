class_name Player extends CharacterBody2D

# Player stats
const speed = 75
var damage = 5
var maxHp = 5
var hp = maxHp

# States and directions
enum PlayerState { IDLE, WALK, ATTACK }
var state: PlayerState = PlayerState.IDLE
var idle_direction = Vector2(0, -1)
var last_walk_direction := Vector2.ZERO
var is_taking_damage: bool = false
var iframe_counter: int = 0

# Signals
signal took_damage

# Nodes
@onready var player_animate_node = $PlayerAnimation
@onready var sword_animate_node = $AttackArea/SwordAnimation
@onready var attack_area = $AttackArea
@onready var attack_collision = $AttackArea/CollisionShape2D
@onready var camera = $Camera2D
@onready var audio_stream = $AudioStreamPlayer2D

# SFX
var sfx_swing = preload("res://Assets/SFX/swing.wav")
var sfx_hurt = preload("res://Assets/SFX/playerHurt.wav")

func _ready() -> void:
	player_animate_node.animation_finished.connect(_on_animation_finished)
	attack_area.visible = false
	attack_collision.disabled = true

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")

	match state:
		PlayerState.ATTACK:
			velocity = Vector2.ZERO
			attack_area.visible = true
			attack_collision.disabled = false
			move_and_slide()
			return
		PlayerState.WALK:
			velocity = direction * speed
		PlayerState.IDLE:
			velocity = Vector2.ZERO

	move_and_slide()

	# States and animations
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
			
	if iframe_counter % 60 == 0 and is_taking_damage:
		take_damage()
	
	iframe_counter += 1

func play_attack_animation() -> void:
	sword_animate_node.stop()
	audio_stream.stream = sfx_swing
	audio_stream.play()
	if idle_direction.x > 0:
		player_animate_node.play("attack_right")
		sword_animate_node.play("attack_right")
		attack_area.z_index = 0
	elif idle_direction.x < 0:
		player_animate_node.play("attack_left")
		sword_animate_node.play("attack_left")
		attack_area.z_index = 0
	elif idle_direction.y > 0:
		player_animate_node.play("attack_down")
		sword_animate_node.play("attack_down")
		attack_area.z_index = 0
	elif idle_direction.y < 0:
		player_animate_node.play("attack_up")
		sword_animate_node.play("attack_up")
		attack_area.z_index = -1

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
		attack_collision.disabled = true
		var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if direction != Vector2.ZERO:
			state = PlayerState.WALK
			play_walk_animation(direction)
		else:
			state = PlayerState.IDLE
			play_idle_animation()

func take_damage() -> void:
	audio_stream.stream = sfx_hurt
	audio_stream.play()
	hp -= 1
	emit_signal("took_damage")
	if hp <= 0:
		call_deferred("die")

func die():
	queue_free()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.take_damage(damage)

func _on_hitbox_body_entered(body: Node2D) -> void:
	iframe_counter = 0
	if body is Enemy:
		is_taking_damage = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body is Enemy:
		is_taking_damage = false
