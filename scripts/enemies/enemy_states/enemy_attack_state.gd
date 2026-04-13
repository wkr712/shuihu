# scripts/enemies/enemy_states/enemy_attack_state.gd
# 敌人攻击状态：激活 hitbox 进行攻击，有冷却时间。

extends "res://scripts/enemies/enemy_state_base.gd"


## 攻击持续时间
@export var attack_duration: float = 0.4

## 攻击冷却
@export var attack_cooldown: float = 1.0


var _timer: float = 0.0
var _is_attacking: bool = false


func enter() -> void:
	_timer = attack_duration
	_is_attacking = true
	host.attack_started()
	host.velocity = Vector2.ZERO


func physics_update(delta: float) -> void:
	_timer -= delta

	if _is_attacking and _timer <= 0.0:
		# 攻击结束
		_is_attacking = false
		host.attack_finished()
		_timer = attack_cooldown
		return

	if not _is_attacking and _timer <= 0.0:
		# 冷却结束，决定下一步
		var dist: float = _distance_to_player()
		if dist <= 30.0:
			# 还在范围内，再次攻击
			state_machine.transition_to("attack")
		else:
			state_machine.transition_to("chase")
		return

	# 攻击中缓慢减速
	host.velocity = host.velocity.move_toward(Vector2.ZERO, 200.0 * delta)
	host.move_and_slide()


func exit() -> void:
	if _is_attacking:
		host.attack_finished()
	_is_attacking = false
