extends CharacterBody2D

const SPEED = 40.0           # bem mais lento que os demais
var max_health: int = 20     # muito mais HP

@onready var player = get_tree().get_first_node_in_group("players")
@onready var animated_sprite = $AnimatedSprite2D
@onready var edge_detector: RayCast2D = $EdgeDetector

enum State { IDLE, RUN }
var current_state = State.IDLE
var current_health: int = max_health

func _ready() -> void:
	$HurtBox.body_entered.connect(_on_hurtbox_body_entered)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	chase_player()
	update_state()
	manage_animations()
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func chase_player() -> void:
	if player == null or not is_on_floor():
		return

	var direction = sign(player.global_position.x - global_position.x)
	edge_detector.target_position.x = abs(edge_detector.target_position.x) * direction

	# Tanque para na borda — é lento mas não é burro
	if not edge_detector.is_colliding():
		velocity.x = 0
		return

	velocity.x = direction * SPEED

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Tanque recebeu dano! HP restante: ", current_health)
	if current_health <= 0:
		die()

func die() -> void:
	print("Tanque foi derrotado!")
	queue_free()

func update_state() -> void:
	if abs(velocity.x) > 0.1:
		current_state = State.RUN
	else:
		current_state = State.IDLE

func manage_animations() -> void:
	match current_state:
		State.IDLE:
			animated_sprite.play("Idle")
		State.RUN:
			animated_sprite.play("Run")
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x < 0

func _on_hurtbox_body_entered(body: Node) -> void:
	if body.is_in_group("players"):
		on_touch_player()

func on_touch_player() -> void:
	print("Tanque acertou o player!")
