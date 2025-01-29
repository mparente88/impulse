extends CharacterBody2D
@export var crosshairs_scene: PackedScene # Assign the crosshairs.tscn in the Inspector
@export var bullet_scene: PackedScene # Reference to the bullet scene
@export var bullet_speed: float = 800
const SHOOT_COOLDOWN = 0.05 # Time between shots in seconds
var can_shoot = true # Tracks whether the player can currently shoot
var is_shooting = false

const SPEED = 450  # Maximum movement speed
const ACCELERATION = 2300  # How quickly the player accelerates
const DECELERATION = 2300  # How quickly the player stops
const WARP_DISTANCE = 200  # Warp distance
const WARP_COOLDOWN = 1.0  # Cooldown for warping

# New Warp-related Variables
var is_warping = false # Track if the player is holding the warp button
var is_charging_warp = false # Track if the player is charging the warp
var is_ready_to_warp = false # Track if the warp is ready to execute
var warp_timer = 0.0 # Measures how long the warp button has been held
var warp_max_distance = 1000.0 # Maximum warp range in pixels
var warp_speed = 500.0 # Speed at which the crosshairs move outward (pixels per second)
var crosshairs = null # Reference to the crosshairs node
var warp_direction = Vector2.ZERO # The direction of the warp

var can_warp = true  # Tracks if the player can warp

func _ready():
	bullet_scene = preload("res://scenes/player/bullet.tscn")
	crosshairs_scene = preload("res://scenes/player/crosshairs.tscn")

func _physics_process(_delta):
	var input_direction = Vector2.ZERO

	# Get input direction
	if Input.is_action_pressed("ui_up"):
		input_direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_direction.y += 1
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1

	# Normalize input direction
	input_direction = input_direction.normalized()
	velocity = input_direction * SPEED # Instantly apply max speed

	# Move the player
	move_and_slide()
	
	# Handle continuous shooting
	if is_shooting and can_shoot:
		shoot()

func _input(event):
	if event.is_action_pressed("fire"):
		is_shooting = true
	if event.is_action_released("fire"):
		is_shooting = false
	
	if event.is_action_pressed("warp"):
		if not is_charging_warp and not is_ready_to_warp:
			start_warp_charge() # First press: Start charging the warp
		elif is_charging_warp:
			execute_warp() # Second press: Engage the warp

func start_warp_charge():
	if is_charging_warp or is_ready_to_warp:
		return  # Prevent starting a new warp charge if one is already in progress

	is_charging_warp = true
	warp_direction = (Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")).normalized()
	
	if warp_direction == Vector2.ZERO:
		warp_direction = Vector2.UP  # Default direction if no input is provided

	# Spawn the crosshairs
	crosshairs = crosshairs_scene.instantiate()
	get_tree().current_scene.add_child(crosshairs)
	crosshairs.global_position = global_position  # Start crosshairs at player position
	crosshairs.direction = warp_direction
	crosshairs.max_distance = warp_max_distance
	crosshairs.player = self


func execute_warp():
	if not is_charging_warp or crosshairs == null:
		return  # Don't execute if warp is not charging or crosshairs are missing

	# Warp the player to the crosshairs' position
	if crosshairs.distance_traveled < warp_max_distance:
		global_position = crosshairs.global_position

	# Clean up
	if crosshairs:
		crosshairs.queue_free()
		crosshairs = null

	is_charging_warp = false
	is_ready_to_warp = false  # Reset warp states

func cancel_warp():
	if crosshairs:
		crosshairs.queue_free()
		crosshairs = null

	is_charging_warp = false
	is_ready_to_warp = false
	
func shoot():
	var bullet = bullet_scene.instantiate()  # Create a new bullet
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()  # Direction toward the mouse

	# Add a slight random angle variation
	var random_variance = randf_range(-0.05, 0.05)  # Adjust this range for more or less variance
	direction = direction.rotated(random_variance)

	bullet.global_position = self.global_position  # Position the bullet at the player
	bullet.rotation = direction.angle() + deg_to_rad(90)
	bullet.linear_velocity = direction * bullet_speed  # Set bullet velocity

	var bullets_node = get_parent().get_node("Bullets")
	bullets_node.add_child(bullet)
	can_shoot = false
	await get_tree().create_timer(SHOOT_COOLDOWN).timeout
	can_shoot = true
