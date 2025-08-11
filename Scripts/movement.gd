extends Node2D

#you dont need this script in your project only use to move around in this project

@export var SPEED = 300.0
@onready var root = get_parent()
var direction
func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_vector("MoveA","MoveD","MoveW","MoveS")
	#mobile control
	if direction:
		root.velocity.x = direction.x * SPEED
		root.velocity.y = direction.y * SPEED 
		
	#slow down the character
	else:
		root.velocity.x = move_toward(root.velocity.x,0, SPEED)
		root.velocity.y = move_toward(root.velocity.y,0, SPEED)
	root.move_and_slide()


	
