extends CharacterBody2D

@export_category("Movement")
@export var move_speed: float = 240.0
@export var acceleration: float = 8.0
@export var drag: float = 6.0
@export var dash_speed: float = 480.0
@export var dash_cooldown: float = 0.5

@export_category("Mass")
@export var base_mass: float = 1.0
@export var min_mass: float = 0.5
@export var max_mass: float = 8.0
@export var mass_growth_rate: float = 0.35
@export var mass_decay_rate: float = 0.5

@export_category("UI")
@export_node_path("Label") var mass_label_path: NodePath

@export_category("Level")
@export var movement_bounds: Rect2 = Rect2(Vector2(-256, -360), Vector2(512, 720))

var mass: float
var _target_scale: float
var _mass_label: Label
var _dash_timer: float = 0.0

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
	if input_vector.length_squared() > 0:
		input_vector = input_vector.normalized()
	var desired_velocity := input_vector * move_speed
	velocity = velocity.lerp(desired_velocity, clamp(acceleration * delta, 0.0, 1.0))
	if input_vector == Vector2.ZERO:
		velocity = velocity.lerp(Vector2.ZERO, clamp(drag * delta, 0.0, 1.0))
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

func _clamp_to_bounds() -> void:
	if movement_bounds.size == Vector2.ZERO:
		return
	var min_x := movement_bounds.position.x
	var min_y := movement_bounds.position.y
	var max_x := movement_bounds.position.x + movement_bounds.size.x
	var max_y := movement_bounds.position.y + movement_bounds.size.y
	var clamped_position := Vector2(
		clamp(global_position.x, min_x, max_x),
		clamp(global_position.y, min_y, max_y)
	)
	global_position = clamped_position
