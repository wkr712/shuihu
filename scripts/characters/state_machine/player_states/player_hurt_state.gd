# scripts/characters/state_machine/player_states/player_hurt_state.gd
# 玩家受击状态

extends "res://scripts/characters/state_machine/player_states/player_state_base.gd"

## 受击硬直时间
@export var hurt_duration: float = 0.4

var _timer: float = 0.0


func enter() -> void:
	_timer = hurt_duration
	# 受击时清除速度
	host.velocity = Vector2.ZERO


func physics_update(delta: float) -> void:
	_timer -= delta

	# 受击期间逐渐减速
	host.velocity = host.velocity.move_toward(Vector2.ZERO, 300.0 * delta)
	host.move_and_slide()

	if _timer <= 0.0:
		state_machine.transition_to("idle")
