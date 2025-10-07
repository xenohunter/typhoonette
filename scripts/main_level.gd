extends Node2D

@export_range(40.0, 400.0, 1.0) var scroll_speed: float = 140.0
@export_range(0.2, 5.0, 0.1) var spawn_interval: float = 1.3
@export var spawn_distance: float = 560.0
@export var horizontal_spawn_range: Vector2 = Vector2(-220.0, 220.0)
@export var level_length: float = 3200.0
@export var crate_scene: PackedScene

@onready var player: CharacterBody2D = $World/Player
@onready var parallax: ParallaxBackground = $World/ParallaxBackground
@onready var timer: Timer = $CrateSpawnTimer
@onready var crate_container: Node2D = $World/Crates

var _distance_scrolled: float = 0.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
    _rng.randomize()
    if timer:
        timer.wait_time = spawn_interval
        timer.timeout.connect(_on_crate_spawn_timer_timeout)
        timer.start()

func _process(delta: float) -> void:
    if parallax:
        parallax.scroll_offset.y += scroll_speed * delta
    _distance_scrolled += scroll_speed * delta
    if _distance_scrolled >= level_length and timer and not timer.is_stopped():
        timer.stop()

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
