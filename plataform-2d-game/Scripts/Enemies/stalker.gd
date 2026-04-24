extends CharacterBody2D

const SPEED = 120.0

@onready var player = get_tree().get_first_node_in_group("players")
@onready var animated_sprite = $AnimatedSprite2D
@onready var edge_detector: RayCast2D = $EdgeDetector

enum State { IDLE, RUN }
var current_state = State.IDLE

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

	# Espelha o EdgeDetector na direção do movimento
	edge_detector.target_position.x = abs(edge_detector.target_position.x) * direction

	# Para na borda — o perseguidor não cai de plataformas
	if not edge_detector.is_colliding():
		velocity.x = 0
		return

	velocity.x = direction * SPEED

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
	print("Perseguidor acertou o player!")
