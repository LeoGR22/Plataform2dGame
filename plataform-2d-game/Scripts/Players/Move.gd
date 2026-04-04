extends CharacterBody2D

#variavel de velocidade
const SPEED = 300.0
#variavel da força do pulo
const JUMP_VELOCITY = -400.0
#variavel de desaleração ao terminar de correr
var deceleration = 1000

#essa função é chamada o tempo todo
#usamos para movimentação e etc
func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	jump()
	move()
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
