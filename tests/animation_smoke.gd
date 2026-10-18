extends SceneTree
# Run: godot --headless --path . --max-fps 120 --quit-after 1000 --script res://tests/animation_smoke.gd

var failures := 0

class RecordedFootstep extends AudioStream:
	var source: AudioStream
	var played: Array
	var index: int

	func _instantiate_playback() -> AudioStreamPlayback:
		played.append(index)
		return source.instantiate_playback()

	func _get_length() -> float:
		return source.get_length()

	func _get_stream_name() -> String:
		return "Footstep verification"

func _initialize() -> void:
	call_deferred("run_checks")

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: ", description)
	else:
		failures += 1
		push_error(description)

func advance_anim(animator, frames := 30) -> void:
	for i in frames:
		animator._physics_process(1.0 / 60.0)

func freeze(node: Node) -> void:
	node.set_process(false)
	node.set_physics_process(false)
	if node is AudioStreamPlayer or node is AudioStreamPlayer3D:
		node.stop()
	for child in node.get_children():
		freeze(child)

func physics_frames(count: int) -> void:
	for i in count: await physics_frame
	await process_frame

func key(keycode: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = pressed
	Input.parse_input_event(event)

func pose_distance(a: Skeleton3D, b: Skeleton3D, bone: int) -> float:
	return a.get_bone_pose_position(bone).distance_to(b.get_bone_pose_position(bone)) + a.get_bone_pose_rotation(bone).angle_to(b.get_bone_pose_rotation(bone)) + a.get_bone_pose_scale(bone).distance_to(b.get_bone_pose_scale(bone))

func run_checks() -> void:
	# These checks load the level directly, without Boot's game-over UI.
	root.get_node("GameManager").set_process_input(false)
	var level: Node = load("res://scenes/levels/level_1.tscn").instantiate()
	root.add_child(level)
	freeze(level)
	var player = level.get_node("Player")
	var teammate = level.get_node("AITeammate")
	var enemy = level.get_node("Enemy")
	var hostage = level.get_node("Hostage")
	for name in ["Player", "AITeammate", "Hostage", "Enemy", "Enemy2", "Enemy3"]:
		var actor = level.get_node(name)
		check(actor.animator != null and actor.animator.active, "%s has an active, connected animator" % name)
		if actor.animator == null:
			quit(1)
			return
		check(not actor.animator._player.is_playing(), "%s has no competing AnimationPlayer playback" % name)
	var control = load("res://scenes/player/player.tscn").instantiate()
	root.add_child(control)
	freeze(control)
	check(player.animator.tree_root != control.animator.tree_root, "Player instances have independent blend graphs")
	var animated: Skeleton3D = player.get_node("CharacterModel/rig-enemy/Skeleton3D")
	var baseline: Skeleton3D = control.get_node("CharacterModel/rig-enemy/Skeleton3D")
	player.animator.update_motion(3.0)
	control.animator.update_motion(3.0)
	var legs_match := true
	var hand_changes := false
	var shield_matches := true
	var leg_start := Quaternion.IDENTITY
	var leg_moves := false
	for frame in 90:
		if frame == 20: player.animator.set_signal(HandSignalSprite.SIGNAL.STOP)
		player.animator._physics_process(1.0 / 60.0)
		control.animator._physics_process(1.0 / 60.0)
		for bone in 12:
			legs_match = legs_match and pose_distance(animated, baseline, bone) < 0.002
		shield_matches = shield_matches and pose_distance(animated, baseline, animated.find_bone("DEF-hand.L")) < 0.002
		if frame == 30: leg_start = animated.get_bone_pose_rotation(0)
		if frame == 45: leg_moves = leg_start.angle_to(animated.get_bone_pose_rotation(0)) > 0.05
		if frame > 45:
			hand_changes = hand_changes or pose_distance(animated, baseline, animated.find_bone("DEF-hand.R")) > 0.1
	check(legs_match, "Gesture changes no leg transforms throughout the walk cycle")
	check(leg_moves, "Legs continue moving while a gesture is active")
	check(hand_changes, "The gesture actually changes the right-hand pose")
	check(shield_matches, "Right-hand gestures leave the left shield arm unchanged")
	check(is_equal_approx(control.animator.get("parameters/Gesture/blend_amount"), 0.0), "Gestures do not bleed into another player instance")
	var shoulder := animated.find_bone("DEF-upper_arm.R")
	var standing_height := animated.get_bone_pose_position(shoulder).y
	player.animator.update_motion(0.0, true)
	advance_anim(player.animator)
	check(player.animator._locomotion.get_current_node() == &"CrouchIdle", "Crouch idle transition selects its clip")
	check(standing_height - animated.get_bone_pose_position(shoulder).y > 0.2, "Gesture arm follows the chest down into a crouch")
	player.animator.update_motion(1.8, true)
	advance_anim(player.animator)
	check(player.animator._locomotion.get_current_node() == &"CrouchWalk", "Crouched movement selects its walk clip")
	player.animator.update_motion(4.5)
	advance_anim(player.animator)
	check(player.animator._locomotion.get_current_node() == &"Run", "Sprint selects the running clip")
	player.animator.update_motion(4.5, false, true)
	advance_anim(player.animator)
	check(player.animator._locomotion.get_current_node() == &"Idle", "Airborne motion does not keep cycling the legs")
	player.animator.set_signal(HandSignalSprite.SIGNAL.NONE)
	advance_anim(player.animator)
	check(is_zero_approx(player.animator.get("parameters/Gesture/blend_amount")), "Releasing a held gesture fades back to locomotion")
	player.animator.set_signal(HandSignalSprite.SIGNAL.FOLLOW)
	advance_anim(player.animator, 1)
	player.animator.set_signal(HandSignalSprite.SIGNAL.NONE)
	advance_anim(player.animator, 10)
	check(player.animator.get("parameters/Gesture/blend_amount") > 0.9, "Quick taps still play the gesture")
	advance_anim(player.animator, 60)
	check(is_zero_approx(player.animator.get("parameters/Gesture/blend_amount")), "A completed tap returns to locomotion")
	for sig in [HandSignalSprite.SIGNAL.STOP, HandSignalSprite.SIGNAL.FOLLOW, HandSignalSprite.SIGNAL.MOVE, HandSignalSprite.SIGNAL.ENGAGE, HandSignalSprite.SIGNAL.PATROL, HandSignalSprite.SIGNAL.ONE, HandSignalSprite.SIGNAL.FOUR]:
		player.animator.set_signal(sig)
		advance_anim(player.animator, 2)
		check(player.animator._player.has_animation(player.animator._gesture_clip.animation), "Signal %s resolves to an existing clip" % sig)
	teammate.receive_command(HandSignalSprite.SIGNAL.STOP, player)
	teammate._physics_process(1.0 / 60.0)
	advance_anim(teammate.animator)
	check(teammate.animator.locomotion_state == &"Idle" and not teammate.animator.aiming, "Waiting with HoldFire uses relaxed idle")
	teammate.global_position.x += 0.05
	teammate._physics_process(1.0 / 60.0)
	advance_anim(teammate.animator)
	check(teammate.animator.locomotion_state == &"Walk", "AI animation follows actual movement")
	teammate._physics_process(1.0 / 60.0)
	advance_anim(teammate.animator)
	check(teammate.animator.locomotion_state == &"Idle", "AI stops walking when displacement stops")
	teammate.receive_command(HandSignalSprite.SIGNAL.ENGAGE, player)
	teammate._physics_process(1.0 / 60.0)
	advance_anim(teammate.animator)
	check(teammate.animator.aiming, "Scanning selects the SMG aiming pose")
	for shooter in [teammate, enemy, level.get_node("Enemy3")]:
		shooter.combat_target = player
		shooter.combat.transition_to(shooter.get_node("CombatState/Engaging"))
		shooter.get_node("CombatState/Engaging").shoot_at(player.global_position)
		advance_anim(shooter.animator, 3)
		check(shooter.animator.get("parameters/Shot/active"), "%s firing triggers recoil" % shooter.name)
		advance_anim(shooter.animator, 60)
		check(not shooter.animator.get("parameters/Shot/active"), "%s firing returns to its base pose" % shooter.name)
	check(hostage.animator.tree_root.get_node("Locomotion").get_node("Idle").animation == &"animations/surrendering", "Hostage uses the surrender clip")
	var standalone = load("res://scenes/player/policePlayer.tscn").instantiate()
	root.add_child(standalone)
	freeze(standalone)
	check(standalone.animator != null and standalone.animator.active, "Standalone policePlayer also has the animation controller")
	for node in root.get_children():
		if node is RigidBody3D: node.queue_free()
	# Exercise actual player inputs/physics on a separate collision layer.
	var floor_body := StaticBody3D.new()
	floor_body.collision_layer = 1 << 30
	var floor_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(100, 1, 100)
	floor_shape.shape = box
	floor_body.add_child(floor_shape)
	root.add_child(floor_body)
	floor_body.position = Vector3(1000, -0.5, 1000)
	control.collision_mask = 1 << 30
	control.position = Vector3(1000, 0.2, 1000)
	control.set_physics_process(true)
	control.animator.set_physics_process(true)
	var footsteps: AudioStreamRandomizer = control.get_node("Footsteps").stream
	var footstep_events: Array = []
	for i in footsteps.streams_count:
		var recorded := RecordedFootstep.new()
		recorded.source = footsteps.get_stream(i)
		recorded.played = footstep_events
		recorded.index = i
		footsteps.set_stream(i, recorded)
	await physics_frames(40)
	Input.action_press("pc_forward")
	await physics_frames(20)
	check(control.animator.locomotion_state == &"Walk", "Player movement input drives walking")
	key(KEY_SHIFT, true)
	await physics_frames(20)
	check(control.animator.locomotion_state == &"Run", "Player sprint input drives running")
	key(KEY_CTRL, true)
	await physics_frames(20)
	check(control.animator.locomotion_state == &"CrouchWalk", "Player crouch input drives crouched walking")
	key(KEY_SHIFT, false)
	key(KEY_CTRL, false)
	Input.action_press("signal_stop")
	await physics_frames(40)
	check(control.animator.locomotion_state == &"Walk" and control.animator.get("parameters/Gesture/blend_amount") > 0.99, "Signal input layers a held gesture during actual walking")
	Input.action_release("signal_stop")
	Input.action_release("pc_forward")
	await physics_frames(40)
	check(control.animator.locomotion_state == &"Idle" and is_zero_approx(control.animator.get("parameters/Gesture/blend_amount")), "Released controls return to idle without a gesture")
	var audio_ordered := footstep_events.size() >= 4
	for i in footstep_events.size():
		audio_ordered = audio_ordered and footstep_events[i] == i % 4
	check(audio_ordered, "Round-robin footstep audio still works with animation and gestures")
	floor_body.queue_free()
	player.take_damage(1000.0)
	check(not player.animator.active, "Death stops animation processing")
	level.queue_free()
	control.queue_free()
	standalone.queue_free()
	await process_frame
	await process_frame
	call_deferred("finish_checks")

func finish_checks() -> void:
	print("ANIMATION CHECKS COMPLETE: ", failures, " failures")
	quit(1 if failures else 0)
