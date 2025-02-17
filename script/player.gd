extends CharacterBody2D

var speed = 100
var run_speed = 1
var hp = 10
var stamina = 100
var damage = 10
var curr_damage = 10
var is_alive = true

var mouse_local_pos
var mouse_area

var cooldown = false

var last_direction = "right"
var direction = Vector2()

var side_walk = false
@onready var anim = $AnimatedSprite2D

enum{
	MOVING,
	ATTACKING,
	DYING
}
var state = MOVING

func _ready() -> void:
	$hurt_box/hurt_box_col.disabled = true
	Signals.connect("player_take_damage", Callable(self, "take_damage"))

func _physics_process(_delta):

	# Отслеживание мыши
	mouse_local_pos = get_local_mouse_position()
	mouse_position()

	# Обнуления направления
	direction = Vector2()
	
	# Отслеживание состояний клавищ
	if Input.is_action_pressed("mouse_left"):
		state = ATTACKING
		
	match state:
		MOVING:
			moving_state()
		ATTACKING:
			attacking_state()
		DYING:
			dying_state()

	# Напрвление в зависимости от положения мыши
	hurt_box_direction()
	
	# Чтобы движения котировались
	move_and_slide()

# Надстройки направления
func hurt_box_direction():
	if mouse_area == "left":
		$hurt_box/hurt_box_col.position.x = -16
		$hurt_box/hurt_box_col.position.y = 0
		$hurt_box/hurt_box_col.rotation = 0
	elif mouse_area == "right":
		$hurt_box/hurt_box_col.position.x = 16
		$hurt_box/hurt_box_col.position.y = 0
		$hurt_box/hurt_box_col.rotation = 0
	elif mouse_area == "top":
		$hurt_box/hurt_box_col.position.x = 0
		$hurt_box/hurt_box_col.position.y = -16
		$hurt_box/hurt_box_col.rotation = 90
	elif mouse_area == "bottom":
		$hurt_box/hurt_box_col.position.x = 0
		$hurt_box/hurt_box_col.position.y = 16
		$hurt_box/hurt_box_col.rotation = 90
func mouse_position():
	# Определяем область, в которой находится мышь

	if mouse_local_pos.x < 0 and abs(mouse_local_pos.x) > abs(mouse_local_pos.y):
		mouse_area = "left"
	elif mouse_local_pos.x > 0 and abs(mouse_local_pos.x) > abs(mouse_local_pos.y):
		mouse_area = "right"
	elif mouse_local_pos.y < 0 and abs(mouse_local_pos.y) > abs(mouse_local_pos.x):
		mouse_area = "top"
	elif mouse_local_pos.y > 0 and abs(mouse_local_pos.y) > abs(mouse_local_pos.x):
		mouse_area = "bottom"

# State Machine функции
func moving_state():
	if Input.is_action_pressed("d"):
		direction.x += 1
		last_direction = "right"
		anim.play("walk_side")
		side_walk = true
		anim.flip_h = false
	elif Input.is_action_pressed("a"):
		direction.x -= 1
		last_direction = "left"
		anim.play("walk_side")
		side_walk = true
		anim.flip_h = true
	else:
		side_walk = false
	if Input.is_action_pressed("s"):
		direction.y += 1
		last_direction = "bottom"
		if not side_walk:
			anim.play("walk_bottom")
	elif Input.is_action_pressed("w"):
		direction.y -= 1
		last_direction = "up"
		if not side_walk:
			anim.play("walk_top")
	if direction != Vector2():
		velocity = direction.normalized() * speed * run_speed
	else:
		velocity = Vector2()
		if last_direction == "right":
			anim.play("idle_side")
			anim.flip_h = false
		elif last_direction == "left":
			anim.play("idle_side")
			anim.flip_h = true
		elif last_direction == "bottom":
			anim.play("idle_bottom")
		elif last_direction == "up":
			anim.play("idle_top")

func attacking_state():
	if not cooldown:
		velocity = Vector2()
		if mouse_area == "right":
			anim.play("atack_side")
			anim.flip_h = false
		elif mouse_area == "left":
			anim.play("atack_side")
			anim.flip_h = true
		elif mouse_area == "bottom":
			anim.play("attack_bottom")
		elif mouse_area == "top":
			anim.play("attack_top")
			
		$hurt_box/hurt_box_col.disabled = false
		$base_attack_cooldown.start()
		cooldown = true
	elif cooldown:
	# Если кулдаун активен, но кнопка мыши отпущена, отключаем коллизию
		$hurt_box/hurt_box_col.disabled = true

func dying_state():
	pass


# Исскуственные Сигналы привязка
func take_damage(damage, attacker_name):
	self.hp -= damage
	if self.hp <= 0:
		state = DYING

# Привязанные функции
func _on_hurt_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		Signals.emit_signal("player_make_damage", self.damage,area.get_parent().name)
func _on_base_attack_cooldown_timeout() -> void:
	cooldown = false
	state = MOVING
