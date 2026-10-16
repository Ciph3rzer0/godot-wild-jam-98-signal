@abstract class_name State
extends Node
## Base class for a state. Override the hooks you need. Leave the state by
## emitting transitioned with the node name of the next state; the StateMachine
## listens, so states never need to know about the machine.

signal state_entered(state: State)
signal state_exited(state: State)

signal transitioned(state_name: String)

## The node being driven: the StateMachine's parent. Set by the StateMachine.
var actor: CharacterBody3D


## Called once when the state becomes active.
@abstract func enter() -> void


## Called once when the state stops being active.
@abstract func exit() -> void


## Called every frame while active.
@abstract func update(_delta: float) -> void


## Called every physics frame while active.
@abstract func physics_update(_delta: float) -> void


func transition_to(v1: Variant = null, v2: Variant = null, v3: Variant = null):
	(get_parent() as StateMachine).transition_to(self)
