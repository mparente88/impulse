extends RigidBody2D

@export var speed: float = 800  # Default bullet speed
@export var max_distance: float = 2000  # Maximum distance the bullet can travel

var start_position: Vector2  # To store the bullet's starting position

func _ready():
	# Store the starting position of the bullet when it spawns
	start_position = global_position

func _process(delta):
	# Calculate the distance the bullet has traveled
	var distance_traveled = start_position.distance_to(global_position)
	
	# Remove the bullet if it exceeds the maximum distance
	if distance_traveled > max_distance:
		queue_free()

func _on_body_entered(body: Node) -> void:
	# Handle collision (e.g., damaging an enemy)
	if body.is_in_group("enemy"):  # Check if the body belongs to a specific group
		body.take_damage(1)  # Example: Call a function on the enemy to apply damage
		queue_free()
