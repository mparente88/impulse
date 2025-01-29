extends Node2D

var speed = 500.0 # Speed at which the crosshairs move outward
var max_distance = 1000.0 # Maximum distance before stopping
var direction = Vector2.ZERO # The direction the crosshairs move
var distance_traveled = 0.0 # Keep track of the distance traveled
var player = null # Reference to the player, assigned when created

func _process(delta):
	if distance_traveled < max_distance:
		var movement = direction * speed * delta
		position += movement
		distance_traveled += movement.length()
		
		# Get the Camera2D
		var camera = get_viewport().get_camera_2d()
		if camera:
			var cam_position = camera.global_position  # Camera's center position
			var viewport_size = get_viewport_rect().size  # Viewport size
			var zoom_factor = camera.zoom  # Camera zoom

			# Adjust for zoom by dividing by zoom values
			var half_width = (viewport_size.x * 0.5) / zoom_factor.x
			var half_height = (viewport_size.y * 0.5) / zoom_factor.y

			# Calculate camera visible area
			var left = cam_position.x - half_width
			var right = cam_position.x + half_width
			var top = cam_position.y - half_height
			var bottom = cam_position.y + half_height

			# Debugging: Print values to check
			print("Camera bounds:", left, right, top, bottom)
			print("Crosshairs position:", position)

			# Check if crosshairs are out of bounds
			if position.x < left or position.x > right or position.y < top or position.y > bottom:
				cancel_warp()
	else:
		cancel_warp()


		
func cancel_warp():
	if player:
		player.cancel_warp() # Tell the player to cancel warping
	queue_free()
