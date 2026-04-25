extends CharacterBody2D

#MOVIMENTAÇÂO
##variavel de velocidade
const SPEED = 200.0
##variavel de velocidade abaixado
const CROUCH_SPEED = 100.0
var is_crouching : bool = false
##variavel de desaleração ao terminar de correr
var deceleration = 30

#PULO
const JUMP_VELOCITY = -400.0
const COYOTE_TIME = 0.12
var coyote_timer : float = 0.0
var was_on_floor : bool = false 

#variavel para setar o estado de animação
@onready var animate_sprite = $AnimatedSprite2D
enum State {IDLE, RUNNING, JUMPING, FALLING, CROUCHING, CROUCH_WALKING}
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
	
	crouch()
	jump()
	move()
	
	update_state()
	animate_sprite.manage_animations(current_state, velocity.x)
	move_and_slide()



#função para o personagem pular
func jump():
	if is_crouching:
		return
	var can_jump = is_on_floor() or (was_on_floor and coyote_timer > 0)
	if Input.is_action_just_pressed("P1_Jump") and can_jump:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0
		was_on_floor = false

#função para o personagem se mover
func move():
	var direction := Input.get_axis("P1_Left", "P1_Right")
	var current_speed = CROUCH_SPEED if is_crouching else SPEED
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)

func crouch():
	if Input.is_action_pressed("P1_Crouch") and is_on_floor():
		is_crouching = true
	else:
		is_crouching = false

#função para setar o estado de animação
func update_state():
	if not is_on_floor():
		if velocity.y < 0:
			current_state = State.JUMPING
		else:
			current_state = State.FALLING
	elif is_crouching:
		if velocity.x == 0:
			current_state = State.CROUCHING
		else:
			current_state = State.CROUCH_WALKING
	else:
		if velocity.x == 0:
			current_state = State.IDLE
		else:
			current_state = State.RUNNING
