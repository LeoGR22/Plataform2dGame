extends AnimatedSprite2D

enum State {IDLE, RUNNING, JUMPING, FALLING}


func _ready() -> void:
	play("Idle")


func manage_animations(curent_state: State, velocity_x: float) -> void:
	#flipa o personagem
	if velocity_x > 0:
		flip_h = false
	elif velocity_x < 0:
		flip_h = true
	
	#troca de animação de acordo com o estado
	match curent_state:
		State.IDLE:
			play("Idle")
		State.RUNNING:
			play("Run")
		State.JUMPING:
			play("Jump")
		State.FALLING:
			play("Fall")
