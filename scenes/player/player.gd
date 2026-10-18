class_name Player
extends Unit

@export var teammates: Array[AIActor]
var actively_signaled_teammate: AIActor

@export var cam_rig : Node3D
@export var cam : Camera3D

@export_flags_3d_physics var interactable_occlusion_flags := 1

## Audio
@onready var hand_signal_sprite: HandSignalSprite = $HandSignal
@onready var FOOTSTEPS: AudioStreamPlayer3D = $Footsteps
@onready var SIGNALSOUND: AudioStreamPlayer = $SignalSFX
@onready var DENIEDSOUND: AudioStreamPlayer = $DeniedSFX

# make running = shorter step sound trigger interval
@export_group("Footsteps")
@export_range(0.1, 3.0, 0.05) var footstep_distance := 1.2
@export_group("")
var _footstep_travel := 0.0

var run_speed = 4.5
var speed = run_speed
var walk_speed = 3
var crouch_speed = 1.8

var jump_velocity = 7
var landing_velocity

var distance = 0


#func _enter_tree() -> void:
	#GameManager.set_player(self)
#
#
#func _exit_tree() -> void:
	#GameManager.clear_player(self)

var active_signal := HandSignalSprite.SIGNAL.NONE
var _last_signal := HandSignalSprite.SIGNAL.NONE

func get_target_points() -> Array[Vector3]:
	var shape_node: CollisionShape3D = $CollisionShape3D
	var half := (shape_node.shape as CapsuleShape3D).height * 0.5
	return [
		shape_node.global_position + Vector3.UP * (half - 0.15),  # head
		shape_node.global_position,                               # chest
	]

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	super()

func _unhandled_input(event: InputEvent) -> void:
	if is_dead():return# or is_mouse_free: return
	
	if event.is_action_pressed("cheat_float"):
		cheat_float = !cheat_float
		if cheat_float:
			velocity.y = 0
			
	if event.is_action_pressed("cheat_hide_shield"):
		$Shield.visible = !$Shield.visible
	
	#if is_mouse_free: return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x / 10
		cam_rig.rotation_degrees.x -= event.relative.y / 10
		cam_rig.rotation_degrees.x = clamp(cam_rig.rotation_degrees.x, -90, 90)

var cheat_float := false

var fov_tween: Tween
func change_fov(target_fov: float, duration: float) -> void:
	# Kill any active tween to prevent jittery, conflicting animations
	if fov_tween and fov_tween.is_valid():
		fov_tween.kill()
	
	# Create a new tween and animate the fov property
	fov_tween = create_tween()
	fov_tween.tween_property(cam, "fov", target_fov, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(delta: float) -> void:
	if is_dead(): return
	
	focused_target = find_signal_target()


func _handle_signals():
	# Compute the requested signal first, then handle its edge once per press/change.
	active_signal = hand_signal_sprite.SIGNAL.NONE
	if Input.is_action_pressed("signal_ready"):
		active_signal = hand_signal_sprite.SIGNAL.PATROL
	elif Input.is_action_pressed("signal_stop"):
		active_signal = hand_signal_sprite.SIGNAL.STOP
	elif Input.is_action_pressed("signal_follow"):
		active_signal = hand_signal_sprite.SIGNAL.FOLLOW
	elif Input.is_action_pressed("signal_1"):
		active_signal = hand_signal_sprite.SIGNAL.ONE
	elif Input.is_action_pressed("signal_2"):
		active_signal = hand_signal_sprite.SIGNAL.TWO
	elif Input.is_action_pressed("signal_3"):
		active_signal = hand_signal_sprite.SIGNAL.THREE
	elif Input.is_action_pressed("signal_4"):
		active_signal = hand_signal_sprite.SIGNAL.FOUR
	elif Input.is_action_pressed("signal_move"):
		active_signal = hand_signal_sprite.SIGNAL.MOVE
	elif Input.is_action_pressed("signal_engage"):
		active_signal = hand_signal_sprite.SIGNAL.ENGAGE
	else:
		active_signal = hand_signal_sprite.SIGNAL.NONE
	
	_send_gesture(active_signal)

func _send_gesture(sig: HandSignalSprite.SIGNAL) -> void:
	active_signal = sig
	hand_signal_sprite._set_hand_signal(sig)
	
	if sig != _last_signal:
		_last_signal = sig
		if animator:
			animator.set_signal(sig)
		_send_command(sig)

func _send_command(sig: HandSignalSprite.SIGNAL) -> void:
	match sig:
		HandSignalSprite.SIGNAL.NONE:
			return
		HandSignalSprite.SIGNAL.ONE, HandSignalSprite.SIGNAL.TWO, \
		HandSignalSprite.SIGNAL.THREE, HandSignalSprite.SIGNAL.FOUR:
			var index := int(sig) - int(HandSignalSprite.SIGNAL.ONE)
			if index >= teammates.size() or not is_instance_valid(teammates[index]) or teammates[index].is_dead():
				DENIEDSOUND.play()
				return
			actively_signaled_teammate = teammates[index]
			SIGNALSOUND.play()
			return
	if not is_instance_valid(actively_signaled_teammate) or actively_signaled_teammate.is_dead():
		DENIEDSOUND.play()
		return
	if actively_signaled_teammate.receive_command(sig, self, focused_target):
		SIGNALSOUND.play()
	else:
		DENIEDSOUND.play()


func _physics_process(delta: float) -> void:
	if is_dead(): return
	
	#_handle_signals()
	
	var raw_input := Input.get_vector("pc_left", "pc_right", "pc_forward", "pc_back")	
	
	if not cheat_float and not is_on_floor():
		velocity += get_gravity() * 2 * delta
		landing_velocity = -velocity.y
		distance = 0

	# Jump with Space - only if on floor and no ceiling above
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = jump_velocity

	$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, 1.85, 0.1)

	if cheat_float or is_on_floor():
		if landing_velocity != 0:
			landing_velocity = 0

		speed = walk_speed
		# Crouch with Control
		if Input.is_key_pressed(KEY_CTRL):
			speed = crouch_speed
		# Walk with Shift
		elif Input.is_key_pressed(KEY_SHIFT):
			speed = run_speed
	
		if cheat_float:
			speed *= 6

	if Input.is_key_pressed(KEY_CTRL):
		$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, 1.38, 0.1)

	$CapsuleBody.mesh.height = $CollisionShape3D.shape.height
	#%HeadPosition.position.y = $CollisionShape3D.shape.height - 0.25

	# Movement inputs
	var direction := (transform.basis * Vector3(raw_input.x, 0, raw_input.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if cheat_float:
		if Input.is_key_pressed(KEY_CTRL):
			velocity.y -= .35
		elif Input.is_key_pressed(KEY_SPACE):
			velocity.y += .35
		else:
			velocity *= .55
	
	var previous_position := global_position
	var was_on_floor := is_on_floor()
	move_and_slide()
	_update_footsteps(global_position - previous_position, not raw_input.is_zero_approx(), was_on_floor)
	if animator:
		var travel := global_position - previous_position
		animator.update_motion(Vector2(travel.x, travel.z).length() / delta, Input.is_key_pressed(KEY_CTRL), not is_on_floor() or cheat_float)
	
	
func _update_footsteps(travel: Vector3, moving: bool, was_on_floor: bool) -> void:
	var horizontal_distance := Vector2(travel.x, travel.z).length()
	if is_dead() or cheat_float or not was_on_floor or not is_on_floor() or not moving or horizontal_distance < 0.001:
		_footstep_travel = 0.0
		return
	_footstep_travel += horizontal_distance
	if _footstep_travel >= footstep_distance:
		_footstep_travel = fmod(_footstep_travel, footstep_distance)
		play_footstep()

func play_footstep() -> void:
	if is_alive() and is_on_floor() and not cheat_float:
		FOOTSTEPS.play()

# Add to player.gd

@export var max_signal_distance := 15.0
## Fraction of screen height from the crosshair.
@export var max_screen_radius := 0.25
## Score bonus for the current target, to stop flicker.
@export var focus_stickiness := 0.03

var focused_target: SignalTarget:
	set(value):
		if value == focused_target:
			return
		if is_instance_valid(focused_target):
			focused_target.set_highlighted(false)
		focused_target = value
		if focused_target:
			focused_target.set_highlighted(true)



func perform_signal(sig: int) -> void:
	if focused_target:
		focused_target.receive_signal(sig, self)


func find_signal_target() -> SignalTarget:
	var vp_size := get_viewport().get_visible_rect().size
	var center := vp_size * 0.5
	var cam_pos := cam.global_position
	var best: SignalTarget
	var best_score := INF

	for node in get_tree().get_nodes_in_group(&"signal_targets"):
		if node.disabled: continue
		var target := node as SignalTarget
		if not target or not target.is_visible_in_tree():
			continue
		var pos := target.get_aim_position()
		var world_dist := cam_pos.distance_to(pos)

		if world_dist > max_signal_distance or cam.is_position_behind(pos):
			continue

		var screen_dist := ((cam.unproject_position(pos) - center) / vp_size.y).length()
		if screen_dist > max_screen_radius:
			continue

		var score := screen_dist + world_dist * 0.002
		if target == focused_target:
			score -= focus_stickiness

		if score < best_score and _has_line_of_sight(cam_pos, pos, target):
			best_score = score
			best = target

	return best


func _has_line_of_sight(from: Vector3, to: Vector3, target: Node) -> bool:
	var draw_from = from - cam.global_basis.y * 0.1 - cam.global_basis.x * 0.01
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_rid()]
	query.collision_mask = interactable_occlusion_flags
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		if DEBUG.draw_player_los:
			DebugDraw.draw_line(draw_from, to, Color.PINK, 2)
		return true
	
	var collider: Node = hit.collider
	
	if collider == target or target.is_ancestor_of(collider) or collider.is_ancestor_of(target):
		if DEBUG.draw_player_los:
			DebugDraw.draw_line(draw_from, to, Color.LAWN_GREEN, 2)
		return true
	
	if DEBUG.print_player_los:
		print("Player LOS occluded by: ", collider.name)
	
	if DEBUG.draw_player_los:
		DebugDraw.draw_line(draw_from, hit.position, Color.AZURE, 2)
	return false

func _on_radial_menu_player_gestured(gesture: HandSignalSprite.SIGNAL) -> void:
	_send_gesture(gesture)
