extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.001
var health = 5

var can_drop = true

var peer_id = -1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	$Pivot/Camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		$Pivot.rotate_x(-event.relative.y*MOUSE_SENSITIVITY)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -0.5, 0.25)
		rotate_y(-event.relative.x*MOUSE_SENSITIVITY)
	if event.is_action_pressed("pickup") and can_drop:
		for w in $Pivot/Weapon.get_children():
			if w.has_method("drop"):
				w.drop()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
		
	if Input.is_action_just_pressed("shoot"):
		var weapons = $Pivot/Weapon
		for w in weapons.get_children():
			if w.has_method("shoot"):
				w.shoot()
			
		

	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	rpc("_set_rotation", rotation.y)
	rpc("_set_position", global_position)

func die():
	rpc("_die")
	queue_free()



@rpc("any_peer","call_remote","unreliable_ordered")
func _set_position(p):
	global_position = p

@rpc("any_peer","call_remote","unreliable_ordered")
func _set_rotation(r):
	rotation.y = r

@rpc("any_peer","call_remote","unreliable_ordered")
func _die():
	queue_free()


func pickup(weapon):
	can_drop = false
	$Pickup_Timer.start()
	$Pivot/Weapon.add_child(weapon)

func _on_pickup_timer_timeout():
	can_drop = true

