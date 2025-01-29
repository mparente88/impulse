extends Area2D

var health = 100

func _ready():
	connect("area_entered", _on_area_entered)
	
func _on_area_entered(area):
	if area.is_in_group("player_bullets"):
		take_damage(10)
		
func take_damage(amount):
	health -= amount
	if health <= 0:
		queue_free() # Destroy this part when it runs out of health
