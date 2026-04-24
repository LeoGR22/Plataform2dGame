extends CharacterBody2D

const SPEED = 100.0
const JUMP_FORCE = -500.0
const JUMP_COOLDOWN = 1.2
const JUMP_RANGE = 200.0   # distância horizontal para acionar o pulo

@onready var player = get_tree().get_first_node_in_group("players")
@onready var animated_sprite = $AnimatedSprite2D
@onready var edge_detector: RayCast2D = $EdgeDetector

enum State { IDLE, RUN, JUMP, FALL }
var current_state = State.IDLE
var jump_timer: float = 0.0

func _ready() -> void:
	$HurtBox.body_entered.connect(_on_hurtbox_body_entered)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	jump_timer -= delta
	chase_and_jump()
	update_state()
	manage_animations()
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func chase_and_jump() -> void:
	if player == null:
		return

	var direction = sign(player.global_position.x - global_position.x)
	var distance = global_position.distance_to(player.global_position)

	if is_on_floor():
		edge_detector.target_position.x = abs(edge_detector.target_position.x) * direction

		# Pula em direção ao player se estiver perto o suficiente e o cooldown passou
		if distance <= JUMP_RANGE and jump_timer <= 0:
			velocity.y = JUMP_FORCE
			jump_timer = JUMP_COOLDOWN

		# Caminha em direção ao player no chão (se não for cair)
		if edge_detector.is_colliding():
			velocity.x = direction * SPEED
		else:
			velocity.x = 0
	else:
		# Mantém movimento horizontal no ar para alcançar o player
		velocity.x = direction * SPEED

func update_state() -> void:
	if not is_on_floor():
		if velocity.y < 0:
			current_state = State.JUMP
		else:
			current_state = State.FALL
	else:
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
		State.JUMP:
			animated_sprite.play("Jump")
		State.FALL:
			animated_sprite.play("Fall")
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x < 0

func _on_hurtbox_body_entered(body: Node) -> void:
	if body.is_in_group("players"):
		on_touch_player()

func on_touch_player() -> void:
	print("Saltador acertou o player!")
