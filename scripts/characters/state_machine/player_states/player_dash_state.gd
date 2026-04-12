# scripts/characters/state_machine/player_states/player_dash_state.gd
# 玩家冲刺状态

extends "res://scripts/characters/state_machine/player_states/player_state_base.gd"

## 冲刺持续时间
@export var dash_duration: float = 0.15

var _timer: float = 0.0
var _dash_direction: Vector2 = Vector2.RIGHT


func enter() -> void:
	_timer = dash_duration

	# 冲刺方向：有输入则跟随输入，否则跟随面朝方向
	var input_dir := _get_movement_input()
	_dash_direction = input_dir if input_dir != Vector2.ZERO else host.face_direction

	# 消耗冲刺次数
	if stats:
		stats.use_dash()

	# 启用无敌
	host.set_invincible(true)


func physics_update(delta: float) -> void:
	_timer -= delta

	if _timer <= 0.0:
		host.set_invincible(false)
		state_machine.transition_to("idle")
		return

	# 冲刺移动
	var speed: float = GameConstants.DEFAULT_DASH_SPEED
	host.velocity = _dash_direction * speed
	host.move_and_slide()


func exit() -> void:
	host.set_invincible(false)
