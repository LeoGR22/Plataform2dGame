extends CharacterBody2D

const SPEED = 60.0
const SHOOT_RANGE = 300.0
const SHOOT_COOLDOWN = 2.0

# Arraste sua ProjectileScene no inspetor
@export var projectile_scene: PackedScene

@onready var player = get_tree().get_first_node_in_group("players")
@onready var animated_sprite = $AnimatedSprite2D
@onready var edge_detector: RayCast2D = $EdgeDetector
@onready var shoot_point: Marker2D = $ShootPoint

enum State { IDLE, RUN, SHOOT }
var current_state = State.IDLE
var direction: float = 1.0
var shoot_timer: float = 0.0

func _ready() -> void:
	$HurtBox.body_entered.connect(_on_hurtbox_body_entered)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	shoot_timer -= delta

	if player and global_position.distance_to(player.global_position) <= SHOOT_RANGE:
		stop_and_shoot(delta)
	else:
		wander()

	update_state()
	manage_animations()
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func wander() -> void:
	if not is_on_floor():
		return

	edge_detector.target_position.x = abs(edge_detector.target_position.x) * direction

	var hit_wall = is_on_wall()
	var hit_edge = not edge_detector.is_colliding()

	if hit_wall or hit_edge:
		direction *= -1.0

	velocity.x = direction * SPEED

func stop_and_shoot(_delta: float) -> void:
	velocity.x = 0
	if shoot_timer <= 0:
		shoot()
		shoot_timer = SHOOT_COOLDOWN

func shoot() -> void:
	if projectile_scene == null or player == null:
		return

	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = shoot_point.global_position

	# Direção do projétil em X e Y em direção ao player
	var direction_to_player = (player.global_position - shoot_point.global_position).normalized()
	projectile.set_direction(direction_to_player)

func update_state() -> void:
	if player and global_position.distance_to(player.global_position) <= SHOOT_RANGE and is_on_floor():
		current_state = State.SHOOT
	elif abs(velocity.x) > 0.1:
		current_state = State.RUN
	else:
		current_state = State.IDLE

func manage_animations() -> void:
	match current_state:
		State.IDLE:
			animated_sprite.play("Idle")
		State.RUN:
			animated_sprite.play("Run")
		State.SHOOT:
			animated_sprite.play("Shoot")
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x < 0
	elif player:
		animated_sprite.flip_h = player.global_position.x < global_position.x

func _on_hurtbox_body_entered(body: Node) -> void:
	if body.is_in_group("players"):
		on_touch_player()

func on_touch_player() -> void:
	print("Atirador acertou o player!")
