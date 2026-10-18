class_name CharacterAnimator
extends AnimationTree
## Owns a separate blend graph per character; imported animation assets stay shared/read-only.

enum Profile { POLICE, SMG, HANDGUN, HOSTAGE }

@export var profile: Profile = Profile.POLICE
@export_range(0.02, 0.5) var blend_time := 0.12

const SKELETON_PATH := "rig-enemy/Skeleton3D"
const ARM_BONES := ["shoulder", "upper_arm", "upper_arm.001", "forearm", "forearm.001", "hand"]
const SIGNAL_CLIPS := {
	HandSignalSprite.SIGNAL.STOP: &"handRaise",
	HandSignalSprite.SIGNAL.PATROL: &"handWave",
	HandSignalSprite.SIGNAL.FOLLOW: &"handDavai",
	HandSignalSprite.SIGNAL.MOVE: &"handPoint",
	HandSignalSprite.SIGNAL.ENGAGE: &"handPump",
	# The current rig has no fingers. The existing signal sprite supplies the number.
	HandSignalSprite.SIGNAL.ONE: &"handPoint",
	HandSignalSprite.SIGNAL.TWO: &"handPoint",
	HandSignalSprite.SIGNAL.THREE: &"handPoint",
	HandSignalSprite.SIGNAL.FOUR: &"handPoint",
}

var locomotion_state: StringName = &"Idle"
var aiming := false
var _player: AnimationPlayer
var _skeleton: Skeleton3D
var _locomotion: AnimationNodeStateMachinePlayback
var _pose: AnimationNodeStateMachinePlayback
var _gesture_clip: AnimationNodeAnimation
var _signal := HandSignalSprite.SIGNAL.NONE
var _gesture_remaining := 0.0
var _gesture_weight := 0.0
var _gesture_reference := Vector3.ZERO
var _shot_elapsed := 1.0
var _shot_length := 0.0
var _references: Dictionary = {}


func _ready() -> void:
	active = false
	_player = get_node(anim_player) as AnimationPlayer
	_skeleton = get_node(root_node).get_node(SKELETON_PATH) as Skeleton3D
	_player.stop()
	callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	# Actors and AI movement states finish their physics work before this graph advances.
	process_physics_priority = 10
	_build_graph()
	active = true
	_locomotion = get("parameters/Locomotion/playback")
	_locomotion.start(&"Idle")
	_pose = get("parameters/Pose/playback")
	_pose.start(&"Relaxed")
	set_aiming(profile == Profile.HANDGUN)
	advance(0.0)


func _animation(clip: StringName) -> AnimationNodeAnimation:
	var node := AnimationNodeAnimation.new()
	node.animation = clip
	return node


func _state_machine(clips: Dictionary) -> AnimationNodeStateMachine:
	var machine := AnimationNodeStateMachine.new()
	var index := 0
	for state in clips:
		machine.add_node(state, _animation(clips[state]), Vector2(index % 3, index / 3) * 180.0)
		index += 1
	for from in clips:
		for to in clips:
			if from == to: continue
			var transition := AnimationNodeStateMachineTransition.new()
			transition.xfade_time = blend_time
			machine.add_transition(from, to, transition)
	return machine


func _filter_arm(node: AnimationNode, side: String) -> void:
	node.filter_enabled = true
	for bone in ARM_BONES:
		# Blender's split deform bones put the side before the .001 suffix.
		var name: String = bone.replace(".001", ".%s.001" % side) if bone.ends_with(".001") else bone + "." + side
		node.set_filter_path(NodePath(SKELETON_PATH + ":DEF-" + name), true)


func _build_graph() -> void:
	var graph := AnimationNodeBlendTree.new()
	graph.add_node(&"Locomotion", _state_machine({
		&"Idle": &"animations/surrendering" if profile == Profile.HOSTAGE else &"animations/idleStand",
		&"Walk": &"animations/walkStanding",
		&"Run": &"animations/runScared" if profile == Profile.HOSTAGE else &"animations/runStanding",
		&"CrouchIdle": &"animations/idleCrouch",
		&"CrouchWalk": &"animations/walkCrouch",
		&"CrouchRun": &"animations/runCrouch",
	}), Vector2(-800, 0))
	graph.add_node(&"MoveSpeed", AnimationNodeTimeScale.new(), Vector2(-560, 0))
	graph.connect_node(&"MoveSpeed", 0, &"Locomotion")
	var relaxed := &"animations/shieldRaised"
	var aim := relaxed
	if profile == Profile.SMG:
		relaxed = &"animations/SMG_relaxed"
		aim = &"animations/SMG_aiming"
	elif profile == Profile.HANDGUN:
		relaxed = &"animations/idleStand"
		aim = &"animations/handgun_aiming"
	graph.add_node(&"Pose", _state_machine({&"Relaxed": relaxed, &"Aiming": aim}), Vector2(-800, 220))
	var equipment := AnimationNodeBlend2.new()
	_filter_arm(equipment, "L")
	if profile != Profile.POLICE:
		_filter_arm(equipment, "R")
	graph.add_node(&"Equipment", equipment, Vector2(-320, 0))
	graph.connect_node(&"Equipment", 0, &"MoveSpeed")
	graph.connect_node(&"Equipment", 1, &"Pose")
	var shot_clip := &"animations/handgun_shoot"
	if profile == Profile.SMG:
		shot_clip = _create_smg_recoil()
	_shot_length = _player.get_animation(shot_clip).length
	graph.add_node(&"ShotClip", _animation(shot_clip), Vector2(-320, 220))
	var shot := AnimationNodeOneShot.new()
	shot.fadein_time = 0.025
	shot.fadeout_time = 0.06
	_filter_arm(shot, "L")
	_filter_arm(shot, "R")
	graph.add_node(&"Shot", shot, Vector2(-80, 0))
	graph.connect_node(&"Shot", 0, &"Equipment")
	graph.connect_node(&"Shot", 1, &"ShotClip")
	_gesture_clip = _animation(&"animations/handRaise")
	graph.add_node(&"GestureClip", _gesture_clip, Vector2(-320, 440))
	graph.add_node(&"GestureSeek", AnimationNodeTimeSeek.new(), Vector2(-80, 440))
	graph.connect_node(&"GestureSeek", 0, &"GestureClip")
	var gesture := AnimationNodeBlend2.new()
	_filter_arm(gesture, "R")
	graph.add_node(&"Gesture", gesture, Vector2(160, 0))
	graph.connect_node(&"Gesture", 0, &"Shot")
	graph.connect_node(&"Gesture", 1, &"GestureSeek")
	graph.connect_node(&"output", 0, &"Gesture")
	tree_root = graph
	set("parameters/Equipment/blend_amount", 0.0 if profile == Profile.HOSTAGE else 1.0)
	set("parameters/Gesture/blend_amount", 0.0)
	_gesture_reference = _chest_reference(&"animations/handRaise")


func update_motion(horizontal_speed: float, crouching := false, airborne := false) -> void:
	var moving := horizontal_speed > 0.1 and not airborne
	var running := horizontal_speed > 3.75
	var next: StringName = &"Idle"
	if crouching:
		next = (&"CrouchRun" if running else &"CrouchWalk") if moving else &"CrouchIdle"
	elif moving:
		next = &"Run" if running else &"Walk"
	if next != locomotion_state:
		locomotion_state = next
		_locomotion.travel(next)
	var reference_speed := 1.8 if crouching else (4.5 if running else 3.0)
	set("parameters/MoveSpeed/scale", clampf(horizontal_speed / reference_speed, 0.25, 2.0) if moving else 1.0)


func set_aiming(value: bool) -> void:
	if aiming == value: return
	aiming = value
	_pose.travel(&"Aiming" if aiming else &"Relaxed")


func set_signal(value: HandSignalSprite.SIGNAL) -> void:
	if value == _signal: return
	_signal = value
	if not SIGNAL_CLIPS.has(value): return
	var clip := StringName("animations/" + SIGNAL_CLIPS[value])
	_gesture_clip.animation = clip
	_gesture_reference = _chest_reference(clip)
	# A quick tap completes the gesture; holding the key holds its final pose.
	_gesture_remaining = _player.get_animation(clip).length
	set("parameters/GestureSeek/seek_request", 0.0)


func fire() -> void:
	if profile != Profile.SMG and profile != Profile.HANDGUN: return
	set_aiming(true)
	_shot_elapsed = 0.0
	set("parameters/Shot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _physics_process(delta: float) -> void:
	if not active: return
	_gesture_remaining = maxf(0.0, _gesture_remaining - delta)
	var gesture_target := 1.0 if SIGNAL_CLIPS.has(_signal) or _gesture_remaining > 0.0 else 0.0
	_gesture_weight = move_toward(_gesture_weight, gesture_target, delta / blend_time)
	set("parameters/Gesture/blend_amount", _gesture_weight)
	_shot_elapsed += delta
	advance(delta)
	_align_arm_roots()


## This exported rig has independent shoulder/upper-arm roots, rather than parenting
## them to the chest. Follow the locomotion chest so an overlay doesn't float above a crouch.
func _align_arm_roots() -> void:
	if profile == Profile.HOSTAGE: return
	var chest := _skeleton.get_bone_global_pose(_skeleton.find_bone("DEF-spine.003")).origin
	var equipment_clip := &"animations/shieldRaised"
	if profile == Profile.SMG:
		equipment_clip = &"animations/SMG_aiming" if aiming else &"animations/SMG_relaxed"
	elif profile == Profile.HANDGUN:
		equipment_clip = &"animations/handgun_aiming" if aiming else &"animations/idleStand"
	var offset := chest - _chest_reference(equipment_clip)
	var shot_weight := clampf(minf(_shot_elapsed / 0.025, (_shot_length - _shot_elapsed) / 0.06), 0.0, 1.0)
	if shot_weight > 0.0:
		var reference_clip := &"runtime/smg_recoil" if profile == Profile.SMG else &"animations/handgun_shoot"
		offset = offset.lerp(chest - _chest_reference(reference_clip), shot_weight)
	_shift_arm_roots("L", offset)
	var right_offset := offset if profile != Profile.POLICE else Vector3.ZERO
	right_offset = right_offset.lerp(chest - _gesture_reference, _gesture_weight)
	_shift_arm_roots("R", right_offset)


func _shift_arm_roots(side: String, offset: Vector3) -> void:
	for root in ["DEF-shoulder.", "DEF-upper_arm."]:
		var bone := _skeleton.find_bone(root + side)
		_skeleton.set_bone_pose_position(bone, _skeleton.get_bone_pose_position(bone) + offset)


func _chest_reference(clip_name: StringName) -> Vector3:
	if _references.has(clip_name): return _references[clip_name]
	var clip := _player.get_animation(clip_name)
	var bone := _skeleton.find_bone("DEF-spine.003")
	var pose := Transform3D.IDENTITY
	while bone >= 0:
		var local := _skeleton.get_bone_rest(bone)
		var path := NodePath(SKELETON_PATH + ":" + _skeleton.get_bone_name(bone))
		var position_track := clip.find_track(path, Animation.TYPE_POSITION_3D)
		var rotation_track := clip.find_track(path, Animation.TYPE_ROTATION_3D)
		var scale_track := clip.find_track(path, Animation.TYPE_SCALE_3D)
		if position_track >= 0: local.origin = clip.position_track_interpolate(position_track, 0.0)
		var rotation := clip.rotation_track_interpolate(rotation_track, 0.0) if rotation_track >= 0 else local.basis.get_rotation_quaternion()
		var scale := clip.scale_track_interpolate(scale_track, 0.0) if scale_track >= 0 else local.basis.get_scale()
		local.basis = Basis(rotation).scaled(scale)
		pose = local * pose
		bone = _skeleton.get_bone_parent(bone)
	_references[clip_name] = pose.origin
	return pose.origin


## No SMG firing clip is supplied. Recoil both arm roots together from its aiming
## pose, preserving the two-handed grip instead of using the pistol's hand pose.
func _create_smg_recoil() -> StringName:
	var source := _player.get_animation(&"animations/SMG_aiming")
	var clip := Animation.new()
	clip.length = 0.2
	for track in source.get_track_count():
		var type := source.track_get_type(track)
		var path := source.track_get_path(track)
		var output := clip.add_track(type)
		clip.track_set_path(output, path)
		var value: Variant = source.track_get_key_value(track, 0)
		for time in [0.0, 0.045, 0.12, 0.2]:
			var key: Variant = value
			if type == Animation.TYPE_POSITION_3D and str(path).get_slice(":", 1) in ["DEF-shoulder.L", "DEF-upper_arm.L", "DEF-shoulder.R", "DEF-upper_arm.R"]:
				key += Vector3(0, 0, -0.045 if time == 0.045 else (-0.015 if time == 0.12 else 0.0))
			clip.track_insert_key(output, time, key)
	var library := AnimationLibrary.new()
	library.add_animation(&"smg_recoil", clip)
	_player.add_animation_library(&"runtime", library)
	# The tree has already copied the player's libraries by the time _ready runs.
	add_animation_library(&"runtime", library)
	return &"runtime/smg_recoil"
