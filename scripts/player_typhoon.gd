extends CharacterBody2D

@export_category("Movement")
@export var move_speed: float = 240.0
@export var acceleration: float = 8.0
@export var drag: float = 6.0
@export var dash_speed: float = 480.0
@export var dash_cooldown: float = 0.5
@export var auto_forward_speed: float = 180.0

@export_category("Mass")
@export var base_mass: float = 1.0
@export var min_mass: float = 0.5
@export var max_mass: float = 8.0
@export var mass_growth_rate: float = 0.35
@export var mass_decay_rate: float = 0.5

@export_category("UI")
@export_node_path("Label") var mass_label_path: NodePath

var mass: float
var _target_scale: float
var _mass_label: Label
var _dash_timer: float = 0.0
var _movement_bounds: Rect2

func _ready() -> void:
	if not is_in_group("player"):
		add_to_group("player")
	mass = base_mass
	_target_scale = _mass_to_scale(mass)
	if mass_label_path:
		_mass_label = get_node_or_null(mass_label_path)
	_update_mass_label()

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_update_scale(delta)
	if _dash_timer > 0.0:
		_dash_timer = max(_dash_timer - delta, 0.0)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("absorb"):
		absorb_small_object()
	if Input.is_action_just_pressed("dash") and _dash_timer == 0.0:
		_perform_dash()
		_dash_timer = dash_cooldown

func _handle_movement(delta: float) -> void:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector.y = min(input_vector.y, 0.0)
	if input_vector.length_squared() > 0:
		input_vector = input_vector.normalized()
	var desired_velocity := Vector2(
		input_vector.x * move_speed,
		input_vector.y * move_speed - auto_forward_speed
	)
	velocity = velocity.lerp(desired_velocity, clamp(acceleration * delta, 0.0, 1.0))
	if input_vector == Vector2.ZERO:
		var idle_target := Vector2(0.0, -auto_forward_speed)
		velocity = velocity.lerp(idle_target, clamp(drag * delta, 0.0, 1.0))
	if velocity.y > -auto_forward_speed:
		velocity.y = lerp(velocity.y, -auto_forward_speed, clamp(acceleration * delta, 0.0, 1.0))
	move_and_slide()
	_clamp_to_bounds()

func add_mass(amount: float) -> void:
	mass = clamp(mass + amount, min_mass, max_mass)
	_target_scale = _mass_to_scale(mass)
	_update_mass_label()

func absorb_small_object() -> void:
	add_mass(mass_growth_rate)

func hit_by_large_object() -> void:
	add_mass(-mass_decay_rate)

func _mass_to_scale(value: float) -> float:
	return 0.5 + (value - min_mass) / max(1.0, max_mass - min_mass)

func _update_scale(delta: float) -> void:
	var current: float = scale.x
	var next: float = lerp(current, _target_scale, clamp(6.0 * delta, 0.0, 1.0))
	scale = Vector2(next, next)

func _update_mass_label() -> void:
	if _mass_label:
		_mass_label.text = "Mass: %.1f" % mass

func _perform_dash() -> void:
	var direction := velocity.normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	velocity = direction * dash_speed

func set_movement_bounds(bounds: Rect2) -> void:
	_movement_bounds = bounds

func _clamp_to_bounds() -> void:
	if _movement_bounds.size == Vector2.ZERO:
		return
	var min_corner := _movement_bounds.position
	var max_corner := _movement_bounds.position + _movement_bounds.size
	var original_position := global_position
	var clamped_position := Vector2(
		clamp(original_position.x, min_corner.x, max_corner.x),
		clamp(original_position.y, min_corner.y, max_corner.y)
	)
	global_position = clamped_position
	var bottom := max_corner.y
	if original_position.y >= bottom and is_equal_approx(clamped_position.y, bottom):
		velocity.y = min(velocity.y, -auto_forward_speed)
