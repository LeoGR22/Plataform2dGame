extends CharacterBody2D

#MOVIMENTAÇÂO
##variavel de velocidade
const SPEED = 200.0
##variavel de desaleração ao terminar de correr
var deceleration = 30

#PULO
const JUMP_VELOCITY = -400.0
const COYOTE_TIME = 0.12
var coyote_timer : float = 0.0
var was_on_floor : bool = false 

#variavel para setar o estado de animação
@onready var animate_sprite = $AnimatedSprite2D
enum State {IDLE, RUNNING, JUMPING, FALLING}
var current_state = State.IDLE

#essa função é chamada o tempo todo
#usamos para movimentação e etc
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_floor():
		coyote_timer = COYOTE_TIME
		was_on_floor = true
	else:
		if was_on_floor:
			coyote_timer -= delta
			if coyote_timer <= 0:
				was_on_floor = false
	
	jump()
	move()
	
	update_state()
	animate_sprite.manage_animations(current_state, velocity.x)
	move_and_slide()



#função para o personagem pular
func jump():
	var can_jump = is_on_floor() or (was_on_floor and coyote_timer > 0)
	if Input.is_action_just_pressed("P1_Jump") and can_jump:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0
		was_on_floor = false

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
