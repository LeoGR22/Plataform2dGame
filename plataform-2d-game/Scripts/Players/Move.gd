extends CharacterBody2D

#variavel de velocidade
const SPEED = 300.0
#variavel da força do pulo
const JUMP_VELOCITY = -400.0
#variavel de desaleração ao terminar de correr
var deceleration = 20
#variavel para setar o estado de animação
@onready var animate_sprite = $AnimatedSprite2D
enum State {IDLE, RUNNING, JUMPING, FALLING}
var current_state = State.IDLE

#essa função é chamada o tempo todo
#usamos para movimentação e etc
func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	jump()
	move()
	
	update_state()
	animate_sprite.manage_animations(current_state, velocity.x)
	move_and_slide()



#função para o personagem pular
func jump():
	if Input.is_action_just_pressed("P1_Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

#função para o personagem se mover
func move():
	var direction := Input.get_axis("P1_Left", "P1_Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)

#função para setar o estado de animação
func update_state():
	if not is_on_floor():
		if velocity.y < 0:
			current_state = State.JUMPING
		else:
			current_state = State.FALLING
	else:
		if velocity.x == 0:
			current_state = State.IDLE
		else:
			current_state = State.RUNNING
