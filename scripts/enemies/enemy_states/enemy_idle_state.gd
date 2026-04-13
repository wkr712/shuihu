# scripts/enemies/enemy_states/enemy_idle_state.gd
# 敌人空闲状态：在原地附近随机游荡，检测到玩家后切换追击。

extends "res://scripts/enemies/enemy_state_base.gd"


## 检测范围
@export var detection_range: float = 150.0

## 游荡等待时间范围 [最小, 最大]
@export var wander_time_range: Vector2 = Vector2(1.0, 3.0)

## 游荡速度
@export var wander_speed: float = 30.0


var _wander_timer: float = 0.0
var _wander_direction: Vector2 = Vector2.ZERO


func enter() -> void:
	_wander_timer = 0.0
	_pick_new_wander()


func physics_update(delta: float) -> void:
	# 优先级：检测玩家 → 游荡
	if _distance_to_player() <= detection_range:
		host.velocity = Vector2.ZERO
		state_machine.transition_to("chase")
		return

	# 游荡计时
	_wander_timer -= delta
	if _wander_timer <= 0.0:
		_pick_new_wander()

	# 应用游荡速度
	host.velocity = _wander_direction * wander_speed
	host.move_and_slide()


func _pick_new_wander() -> void:
	_wander_timer = randf_range(wander_time_range.x, wander_time_range.y)
	# 随机方向或停下
	if randf() > 0.4:
		_wander_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	else:
		_wander_direction = Vector2.ZERO
