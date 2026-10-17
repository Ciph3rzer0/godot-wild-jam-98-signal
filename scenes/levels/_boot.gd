extends Node3D

@export_file("*.tscn") var starting_scene_path: String
@export var progress_bar: ProgressBar
@export var status_label: Label

var _progress: Array = []
var _instance: Node

func _ready() -> void:
	assert(starting_scene_path)
	assert(progress_bar)
	
	ResourceLoader.load_threaded_request(starting_scene_path)
	status_label.text = "Loading Assets..."

func _process(_delta: float) -> void:
	var status := ResourceLoader.load_threaded_get_status(starting_scene_path, _progress)

	if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		push_error("Failed to load %s" % starting_scene_path)
		set_process(false)
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

	var packed: PackedScene = ResourceLoader.load_threaded_get(starting_scene_path)

	var task := WorkerThreadPool.add_task(func(): _instance = packed.instantiate())
	while not WorkerThreadPool.is_task_completed(task):
		await get_tree().process_frame
	WorkerThreadPool.wait_for_task_completion(task)

	if _instance == null:
		push_error("Failed to instantiate %s" % starting_scene_path)
		return

	progress_bar.value = 100.0
	await get_tree().process_frame
	await get_tree().process_frame

	var old := get_tree().current_scene
	get_tree().root.add_child(_instance)
	get_tree().current_scene = _instance
	old.queue_free()
