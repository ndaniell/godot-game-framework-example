extends CharacterBody3D

signal died(enemy: CharacterBody3D)

@export var max_hp: int = 30
@export var move_speed: float = 3.0
@export var damage: int = 10
@export var attack_range: float = 2.0
@export var attack_cooldown: float = 1.5

var hp: int = 30
var _target: Node3D = null
var _time_since_last_attack: float = 0.0


func _ready() -> void:
	hp = max_hp


func _physics_process(delta: float) -> void:
	_time_since_last_attack += delta

	# Simple AI: move towards target if we have one
	if _target and is_instance_valid(_target):
		var direction := (_target.global_position - global_position).normalized()
		direction.y = 0  # Keep on ground plane

		var distance := global_position.distance_to(_target.global_position)

		if distance > attack_range:
			# Move towards target
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
		else:
			# In range, stop and attack
			velocity.x = 0.0
			velocity.z = 0.0
			_try_attack()

		# Look at target
		if direction.length() > 0.01:
			look_at(global_position + direction, Vector3.UP)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	# Apply gravity
	if not is_on_floor():
		velocity.y -= 18.0 * delta

	move_and_slide()


func set_target(target: Node3D) -> void:
	_target = target


func apply_damage(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		_on_death()


func _try_attack() -> void:
	if _time_since_last_attack < attack_cooldown:
		return

	if not _target or not is_instance_valid(_target):
		return

	var distance := global_position.distance_to(_target.global_position)
	if distance <= attack_range:
		if _target.has_method("apply_damage"):
			_target.apply_damage(damage)
		_time_since_last_attack = 0.0


func _on_death() -> void:
	died.emit(self)
	queue_free()
