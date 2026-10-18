extends CharacterBody3D


const SPEED = 2.0
@onready var animator: CharacterAnimator = $AnimationTree
var _last_signal := HandSignalSprite.SIGNAL.NONE
const SIGNAL_ACTIONS := {
	"signal_ready": HandSignalSprite.SIGNAL.PATROL,
	"signal_stop": HandSignalSprite.SIGNAL.STOP,
	"signal_follow": HandSignalSprite.SIGNAL.FOLLOW,
	"signal_1": HandSignalSprite.SIGNAL.ONE,
	"signal_2": HandSignalSprite.SIGNAL.TWO,
	"signal_3": HandSignalSprite.SIGNAL.THREE,
	"signal_4": HandSignalSprite.SIGNAL.FOUR,
	"signal_move": HandSignalSprite.SIGNAL.MOVE,
	"signal_engage": HandSignalSprite.SIGNAL.ENGAGE,
}
#const JUMP_VELOCITY = 0.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction *= -1
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	var previous_position := global_position
	move_and_slide()
	var travel := global_position - previous_position
	animator.update_motion(Vector2(travel.x, travel.z).length() / delta, false, not is_on_floor())
	var current := HandSignalSprite.SIGNAL.NONE
	for action in SIGNAL_ACTIONS:
		if Input.is_action_pressed(action):
			current = SIGNAL_ACTIONS[action]
			break
	if current != _last_signal:
		_last_signal = current
		animator.set_signal(current)
