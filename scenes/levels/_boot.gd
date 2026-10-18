class_name Main
extends Node

## Level loaded on startup.
@export_file("*.tscn") var starting_scene_path: String

## The level currently in the container, for code that needs to spawn into it.
static var current_level: Node

@export var level_container: Node3D
@export var loading_screen: CanvasLayer
@export var progress_bar: ProgressBar
@export var status_label: Label

@export var game_over_sequence: Node

var _loading_path := ""
var _instance: Node
var _progress := []


func _ready() -> void:
	loading_screen.show()
	game_over_sequence.hide()
	
	set_process(false)
	if starting_scene_path:
		load_level(starting_scene_path)


func load_level(path: String) -> void:
	if not _loading_path.is_empty():
		return  # already loading something
	_loading_path = path

	loading_screen.show()
	progress_bar.value = 0.0
	status_label.text = "Loading Assets..."

	# Free the old level first: releases its memory before the new one loads
	# (matters on web) and stops it running behind the loading screen.
	for child in level_container.get_children():
		level_container.remove_child(child)
		child.queue_free()
	current_level = null

	ResourceLoader.load_threaded_request(path)
	set_process(true)


func _process(_delta: float) -> void:
	var status := ResourceLoader.load_threaded_get_status(_loading_path, _progress)

	if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		push_error("Failed to load %s" % _loading_path)
		status_label.text = "Failed to load level"
		set_process(false)
		_loading_path = ""
		return

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		set_process(false)
		_finish_loading()
		return

	# Loading is only the first ~80% of the bar.
	var p: float = _progress[0] if not _progress.is_empty() else 0.0
	progress_bar.value = p * 80.0


func _finish_loading() -> void:
	status_label.text = "Preparing level..."
	progress_bar.value = 85.0

	var packed: PackedScene = ResourceLoader.load_threaded_get(_loading_path)

	_instance = null
	if OS.has_feature("web") and not OS.has_feature("threads"):
		_instance = packed.instantiate()
	else:
		var task := WorkerThreadPool.add_task(func(): _instance = packed.instantiate())
		while not WorkerThreadPool.is_task_completed(task):
			await get_tree().process_frame
		WorkerThreadPool.wait_for_task_completion(task)

	if _instance == null:
		push_error("Failed to instantiate %s" % _loading_path)
		_loading_path = ""
		return

	status_label.text = "Compiling shaders..."
	progress_bar.value = 100.0
	await get_tree().process_frame
	await get_tree().process_frame

	level_container.add_child(_instance)  # _ready() runs here
	current_level = _instance
	_instance = null
	_loading_path = ""

	if current_level is Level:
		print("connected")
		current_level.scenario_lost.connect(game_over_sequence.show_game_over)
	else:
		print(current_level)

	# Let the new level render a frame (shader compile) before revealing it.
	await get_tree().process_frame
	loading_screen.hide()
