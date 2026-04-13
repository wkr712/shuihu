# scripts/enemies/enemy_states/enemy_hurt_state.gd
# 敌人受击状态：短暂硬直后恢复追击。

extends "res://scripts/enemies/enemy_state_base.gd"


## 受击硬直时间
@export var hurt_duration: float = 0.3


var _timer: float = 0.0


func enter() -> void:
	_timer = hurt_duration


func physics_update(delta: float) -> void:
	_timer -= delta

	# 减速到停止
	host.velocity = host.velocity.move_toward(Vector2.ZERO, 300.0 * delta)
	host.move_and_slide()

	if _timer <= 0.0:
		state_machine.transition_to("chase")
