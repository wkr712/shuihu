# scripts/enemies/enemy_states/enemy_chase_state.gd
# 敌人追击状态：向玩家移动，进入攻击范围切换攻击。

extends "res://scripts/enemies/enemy_state_base.gd"


## 追击速度
@export var chase_speed: float = 120.0

## 攻击触发距离
@export var attack_range: float = 30.0

## 丢失目标距离
@export var lose_range: float = 250.0


func enter() -> void:
	pass


func physics_update(_delta: float) -> void:
	var dist: float = _distance_to_player()

	# 丢失目标
	if dist > lose_range:
		host.velocity = Vector2.ZERO
		state_machine.transition_to("idle")
		return

	# 进入攻击范围
	if dist <= attack_range:
		host.velocity = Vector2.ZERO
		state_machine.transition_to("attack")
		return

	# 追击
	var direction: Vector2 = _direction_to_player()
	host.velocity = direction * chase_speed
	host.move_and_slide()
