extends Area2D

const SPEED = 400.0

var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	var shader_material = ShaderMaterial.new()
	shader_material.shader = preload("res://shaders/glow.gdshader")
	shader_material.set_shader_parameter("glow_color", Color(0.875, 1.0, 0.039, 1.0))
	shader_material.set_shader_parameter("intensity", 1.8)
	$AnimatedSprite2D.material = shader_material
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)

func _physics_process(delta: float) -> void:
	# Mantém a trajetória fixa — não persegue o player
	position += direction * SPEED * delta

# Chamado pelo atirador ao instanciar o projétil
func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	# Rotaciona o sprite na direção do disparo (opcional, fica bonito)
	rotation = direction.angle()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("players"):
		print("Projétil acertou o player!")
		on_hit_player(body)

func on_hit_player(_body: Node) -> void:
	# Implemente aqui: tirar vida do player, knockback etc.
	destroy()

func destroy() -> void:
	# Aqui você pode trocar por uma animação de explosão antes de destruir
	queue_free()

func _on_screen_exited() -> void:
	queue_free()
