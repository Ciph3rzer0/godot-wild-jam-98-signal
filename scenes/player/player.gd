#https://github.com/Linko-3D/Godot-Simple-First-Person-Controller/blob/main/player/player.gd
class_name Player
extends CharacterBody3D

@export var cam : Camera3D

@onready var interaction_ray: RayCast3D = $Camera3D/InteractionRay
@onready var hand_signal_sprite: HandSignalSprite = $HandSignal

var run_speed = 4.5
var speed = run_speed
var walk_speed = 3
var crouch_speed = 1.8

var jump_velocity = 7
var landing_velocity

var distance = 0

var is_mouse_free := false

#func _enter_tree() -> void:
	#GameManager.set_player(self)
#
#
#func _exit_tree() -> void:
	#GameManager.clear_player(self)

var active_signal := HandSignalSprite.SIGNAL.NONE


func _ready() -> void:
	set_mouse_free(false)

func set_mouse_free(val: bool):
	is_mouse_free = val
	#crosshair_dot.visible = !val
	if val:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		set_mouse_free(!is_mouse_free)
		get_viewport().set_input_as_handled()
		return
	
	if is_mouse_free: return
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x / 10
		cam.rotation_degrees.x -= event.relative.y / 10
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)

func _unhandled_input(event: InputEvent) -> void:

	#if event.is_action_pressed("pc_interact") and !_mounted_object and !is_mouse_free:
		#var interactable := get_faced_interactable()
		#if interactable:
			#interactable.interact(self)
			#get_viewport().set_input_as_handled()
			#return
#
	#if (!_mounted_object or !is_mouse_free) and event.is_action_pressed("pc_interact"):
		#if _mounted_object:
			#dismount()
		#else:
			#try_mount()
	
	# if _mounted_object:
	# 	if event is InputEventKey or event is InputEventPanGesture:
	# 		if _mounted_object.push_event_to_viewport(event):
	# 			get_viewport().set_input_as_handled()

	if !is_mouse_free: return


var fov_tween: Tween
func change_fov(target_fov: float, duration: float) -> void:
	# Kill any active tween to prevent jittery, conflicting animations
	if fov_tween and fov_tween.is_valid():
		fov_tween.kill()
	
	# Create a new tween and animate the fov property
	fov_tween = create_tween()
	fov_tween.tween_property(cam, "fov", target_fov, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

var exit_button_held_timer := 0.0
func _process(delta: float) -> void:
	var mouse_mode := Input.get_mouse_mode()
	
	if Input.is_action_pressed("ui_exit_game"):
		exit_button_held_timer += delta
		if (exit_button_held_timer) > 0.5:
			get_tree().quit()
	else:
		exit_button_held_timer = 0
	
	focused_target = find_signal_target()


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("signal_ready"):
		active_signal = hand_signal_sprite.SIGNAL.SWAP
	elif Input.is_action_pressed("signal_stop"):
		active_signal = hand_signal_sprite.SIGNAL.STOP
	elif Input.is_action_pressed("signal_follow"):
		active_signal = hand_signal_sprite.SIGNAL.HOLD
	elif Input.is_action_pressed("signal_1"):
		active_signal = hand_signal_sprite.SIGNAL.ONE
	elif Input.is_action_pressed("signal_2"):
		active_signal = hand_signal_sprite.SIGNAL.TWO
	elif Input.is_action_pressed("signal_3"):
		active_signal = hand_signal_sprite.SIGNAL.THREE
	elif Input.is_action_pressed("signal_4"):
		active_signal = hand_signal_sprite.SIGNAL.FOUR
	else:
		active_signal = hand_signal_sprite.SIGNAL.NONE
	
	hand_signal_sprite._set_hand_signal(active_signal)
	
	
	var raw_input := Input.get_vector("pc_left", "pc_right", "pc_forward", "pc_back")	
	
	if not is_on_floor():
		velocity += get_gravity() * 2 * delta
		landing_velocity = -velocity.y
		distance = 0

	# Jump with Space - only if on floor and no ceiling above
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = jump_velocity

	$CollisionShape3D.shape.height = lerp($CollisionShape3D.shape.height, 1.85, 0.1)

	if is_on_floor():
		if landing_velocity != 0:
			landing_velocity = 0

		speed = walk_speed
		# Crouch with Control
		if Input.is_key_pressed(KEY_CTRL):
			speed = crouch_speed
		# Walk with Shift
		elif Input.is_key_pressed(KEY_SHIFT):
			speed = run_speed

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

	move_and_slide()
	
	
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
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return true
	var collider: Node = hit.collider
	return collider == target or target.is_ancestor_of(collider) or collider.is_ancestor_of(target)
