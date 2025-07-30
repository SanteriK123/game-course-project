class_name Enemy extends CharacterBody2D

@onready var hit_flash_timer = $HitFlashTimer

# Player reference
var target_player: Player = null

# States
enum EnemyState {IDLE, WANDER, ATTACK}
var state: EnemyState = EnemyState.IDLE

# Enemy stats
@export var maxHp: int
@export var speed: int
var hp: int

# Nodes
@onready var sprite = $AnimatedSprite2D
@onready var audio_stream = $AudioStreamPlayer2D

# SFX
var enemy_hurt = preload("res://Assets/SFX/enemyHurt.wav")

# Movement variables
var wander_direction := Vector2.ZERO
var direction := Vector2.ZERO

# Signals
signal enemy_dead

func _ready() -> void:
	hp = maxHp
	
func _physics_process(delta: float) -> void:
	if state == EnemyState.IDLE:
		sprite.play("idle")
		velocity = Vector2.ZERO
		move_and_slide()
	elif state == EnemyState.WANDER:
		sprite.play("walk")
		velocity = wander_direction * speed / 2
		move_and_slide()
	elif state == EnemyState.ATTACK and target_player != null:
		sprite.play("walk")
		var dir = (target_player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		
func take_damage(damage: int) -> void:
	audio_stream.stream = enemy_hurt
	audio_stream.play()
	hp -= damage
	sprite.modulate = Color.RED
	hit_flash_timer.start(0.2)
	if hp < 1:
		queue_free()
		emit_signal("enemy_dead")

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body is Player:
		state = EnemyState.ATTACK
		target_player = body
	
func _on_hit_flash_timer_timeout() -> void:
	sprite.modulate = Color.WHITE

func _on_move_timer_timeout() -> void:
	# Make enemy both wander and stay still with a 50% chance for either 
	if state in [EnemyState.IDLE, EnemyState.WANDER]:
		if randf() < 0.5:
			state = EnemyState.IDLE
			wander_direction = Vector2.ZERO
		else:
			state = EnemyState.WANDER
			var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
			wander_direction = directions[randi() % directions.size()]
