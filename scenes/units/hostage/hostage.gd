extends AIActor

func _ready() -> void:
	super()
	$AnimationPlayer.play("animations/handgun_aiming")
