extends Area2D

@export var scroll_speed: float = 140.0
@export var cleanup_distance: float = 720.0
@export var mass_penalty: float = 0.0

var player: CharacterBody2D

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
    position.y += scroll_speed * delta
    if player and global_position.y - player.global_position.y > cleanup_distance:
        queue_free()

func set_player(value: CharacterBody2D) -> void:
    player = value

func set_scroll_speed(value: float) -> void:
    scroll_speed = value

func set_cleanup_distance(value: float) -> void:
    cleanup_distance = value

func _on_body_entered(body: Node) -> void:
    if body is CharacterBody2D:
        if mass_penalty != 0.0 and body.has_method("add_mass"):
            body.add_mass(-mass_penalty)
        elif body.has_method("hit_by_large_object"):
            body.hit_by_large_object()
        queue_free()
