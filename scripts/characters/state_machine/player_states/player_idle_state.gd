# scripts/characters/state_machine/player_states/player_idle_state.gd
# 玩家待机状态

extends "res://scripts/characters/state_machine/player_states/player_state_base.gd"


func enter() -> void:
	host.velocity = Vector2.ZERO
	host.play_animation("idle")


func physics_update(_delta: float) -> void:
	# 优先检测攻击
	if _is_attack_pressed():
		state_machine.transition_to("attack")
		return

	# 检测冲刺
	if _is_dash_pressed() and stats and stats.can_dash:
		state_machine.transition_to("dash")
		return

	# 检测移动
	var direction := _get_movement_input()
	if direction != Vector2.ZERO:
		state_machine.transition_to("move")
		return

	# 保持静止
	host.velocity = Vector2.ZERO
	host.move_and_slide()
