extends CharacterBody2D

const SPEED = 80.0

@onready var player = get_tree().get_first_node_in_group("players")
@onready var animated_sprite = $AnimatedSprite2D
@onready var edge_detector: RayCast2D = $EdgeDetector

enum State { IDLE, RUN }
var current_state = State.IDLE
var direction: float = 1.0  # começa andando para a direita

func _ready() -> void:
	$HurtBox.body_entered.connect(_on_hurtbox_body_entered)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	patrol()
	update_state()
	manage_animations()
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func patrol() -> void:
	if not is_on_floor():
		return

	# Espelha o EdgeDetector na direção atual
	edge_detector.target_position.x = abs(edge_detector.target_position.x) * direction

	# Inverte ao detectar borda ou parede
	var hit_wall = is_on_wall()
	var hit_edge = not edge_detector.is_colliding()

	if hit_wall or hit_edge:
		direction *= -1.0

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
	animated_sprite.flip_h = direction < 0

func _on_hurtbox_body_entered(body: Node) -> void:
	if body.is_in_group("players"):
		on_touch_player()

func on_touch_player() -> void:
	print("Patrulheiro acertou o player!")
