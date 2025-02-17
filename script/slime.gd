extends CharacterBody2D

var speed = 70
# var run_speed = 1
var hp = 10
# var stamina = 100
var damage = 10
# var curr_damage = 10
var is_alive = true

var last_direction = "right"
var direction = Vector2()

@onready var anim = $AnimatedSprite2D
@onready var player = $"../player"

var chase = false

func _ready() -> void:
	Signals.connect("player_make_damage", Callable(self, "take_damage"))

func _physics_process(delta):
	if is_alive:
		anim_player()
		if chase:
			direction = (player.position - self.position).normalized()
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO

	if is_alive:
		anim_player()
	move_and_slide()

func anim_player():
	
	if chase:
		if direction.x > 0:
			anim.play("side_walk")
			anim.flip_h = false
		elif direction.x < 0:
			anim.play("side_walk")
			anim.flip_h = true
		elif direction.y < 0:
			anim.play("up_walk")
		elif direction.y > 0:
			anim.play("down_walk")
	else:
		# Если персонаж стоит, играем анимацию покоя
		if last_direction == "right":
			anim.play("side_idle")
			anim.flip_h = false
		elif last_direction == "left":
			anim.play("side_idle")
			anim.flip_h = true
		elif last_direction == "up":
			anim.play("up_idle")
		elif last_direction == "down":
			anim.play("down_idle")

func die():
	is_alive = false
	velocity = Vector2.ZERO
	anim.play("die")
	await anim.animation_finished  # Дождаться завершения анимации
	queue_free()  # Удаляем объект

func take_damage(damage, name):
	if name == $".".name:
		print(hp, "hp left")
		self.hp -= damage
		if hp < 1:
			die()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		chase = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		chase = false

func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		print("hit")
		Signals.emit_signal("player_take_damage", damage, self.name)
