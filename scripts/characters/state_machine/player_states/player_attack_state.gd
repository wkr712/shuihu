# scripts/characters/state_machine/player_states/player_attack_state.gd
# 玩家攻击状态

extends "res://scripts/characters/state_machine/player_states/player_state_base.gd"

## 攻击持续时间（秒）
@export var attack_duration: float = 0.3

var _timer: float = 0.0


func enter() -> void:
	_timer = attack_duration
	# 通知攻击开始（触发 Hitbox 启用）
	host.attack_started()
	host.play_animation("attack")
	# 攻击时减速但不完全停止
	host.velocity *= 0.3


func physics_update(delta: float) -> void:
	_timer -= delta

	if _timer <= 0.0:
		host.attack_finished()
		state_machine.transition_to("idle")
		return

	# 攻击期间缓慢滑行
	host.velocity = host.velocity.move_toward(Vector2.ZERO, 200.0 * delta)
	host.move_and_slide()
