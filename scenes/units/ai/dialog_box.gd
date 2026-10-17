extends Label3D

const FADE_OUT_DURATION := 1.0
@export var dialog_uptime := 4.0

var _tween: Tween
var _dialog_id := 0


func _ready() -> void:
	hide()


func show_dialog(dialog: String) -> void:
	_dialog_id += 1
	var id := _dialog_id

	if _tween:
		_tween.kill()

	text = dialog
	modulate.a = 1.0
	outline_modulate.a = 1.0
	show()

	await get_tree().create_timer(dialog_uptime).timeout
	# A newer line may have replaced this one while we were waiting.
	if id == _dialog_id:
		fade_out()


func fade_out() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel()
	_tween.tween_property(self, "modulate:a", 0.0, FADE_OUT_DURATION)
	_tween.tween_property(self, "outline_modulate:a", 0.0, FADE_OUT_DURATION)
	_tween.chain().tween_callback(hide)
