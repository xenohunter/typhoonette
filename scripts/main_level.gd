extends Node2D

@export_range(40.0, 400.0, 1.0) var scroll_speed: float = 140.0
@export_range(0.2, 5.0, 0.1) var spawn_interval: float = 1.3
@export var spawn_distance: float = 560.0
@export var horizontal_spawn_range: Vector2 = Vector2(-220.0, 220.0)
@export var level_length: float = 3200.0
@export var crate_scene: PackedScene
@export var play_area_margin: Vector2 = Vector2(48.0, 160.0)
@export var camera_follow_offset: float = 220.0
@export_range(1.0, 20.0, 0.5) var camera_follow_speed: float = 8.0

@onready var player: CharacterBody2D = $World/Player
@onready var parallax: ParallaxBackground = $World/ParallaxBackground
@onready var timer: Timer = $CrateSpawnTimer
@onready var crate_container: Node2D = $World/Crates
@onready var camera: Camera2D = $Camera2D

var _distance_scrolled: float = 0.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	if timer:
		timer.wait_time = spawn_interval
		timer.timeout.connect(_on_crate_spawn_timer_timeout)
		timer.start()
	if "auto_forward_speed" in player:
		player.auto_forward_speed = max(player.auto_forward_speed, scroll_speed)
	_update_player_bounds()

func _process(delta: float) -> void:
	if parallax:
		parallax.scroll_offset.y += scroll_speed * delta
	_distance_scrolled += scroll_speed * delta
	if _distance_scrolled >= level_length and timer and not timer.is_stopped():
		timer.stop()
	_update_camera(delta)
	_update_player_bounds()

func _on_crate_spawn_timer_timeout() -> void:
	if crate_scene == null or player == null:
		return
	var crate := crate_scene.instantiate()
	if crate_container:
		crate_container.add_child(crate)
	else:
		add_child(crate)
	var spawn_x := _rng.randf_range(horizontal_spawn_range.x, horizontal_spawn_range.y)
	crate.global_position = player.global_position + Vector2(spawn_x, -spawn_distance)
	if crate.has_method("set_player"):
		crate.set_player(player)
	else:
		crate.player = player
	if crate.has_method("set_scroll_speed"):
		crate.set_scroll_speed(scroll_speed)
	else:
		crate.scroll_speed = scroll_speed
	if crate.has_method("set_cleanup_distance"):
		crate.set_cleanup_distance(max(crate.cleanup_distance, spawn_distance + 200.0))
	else:
		crate.cleanup_distance = max(crate.cleanup_distance, spawn_distance + 200.0)

func _update_camera(delta: float) -> void:
	if camera == null or player == null:
		return
	var target_position := Vector2(
		0.0,
		player.global_position.y - camera_follow_offset
	)
	var lerp_weight: float = clamp(camera_follow_speed * delta, 0.0, 1.0)
	camera.global_position = camera.global_position.lerp(target_position, lerp_weight)

func _update_player_bounds() -> void:
	if camera == null or player == null:
		return
	var viewport := camera.get_viewport()
	if viewport == null:
		return
	var visible_rect := viewport.get_visible_rect()
	var view_size := Vector2(
		visible_rect.size.x * camera.zoom.x,
		visible_rect.size.y * camera.zoom.y
	)
	var half_size := view_size * 0.5
	var margin := Vector2(
		max(min(play_area_margin.x, half_size.x - 4.0), 0.0),
		max(min(play_area_margin.y, half_size.y - 4.0), 0.0)
	)
	var min_corner := camera.global_position - half_size + margin
	var max_corner := camera.global_position + half_size - margin
	if max_corner.x <= min_corner.x or max_corner.y <= min_corner.y:
		return
	var bounds := Rect2(min_corner, max_corner - min_corner)
	if player.has_method("set_movement_bounds"):
		player.set_movement_bounds(bounds)
