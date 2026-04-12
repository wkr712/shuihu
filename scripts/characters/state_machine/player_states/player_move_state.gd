# scripts/characters/state_machine/player_states/player_move_state.gd
# 玩家移动状态

extends "res://scripts/characters/state_machine/player_states/player_state_base.gd"


func enter() -> void:
	pass


func physics_update(_delta: float) -> void:
	# 优先检测攻击
	if _is_attack_pressed():
		state_machine.transition_to("attack")
		return

	# 检测冲刺
	if _is_dash_pressed() and stats and stats.can_dash:
		state_machine.transition_to("dash")
		return

	var direction := _get_movement_input()

	# 停止输入则回到待机
	if direction == Vector2.ZERO:
		state_machine.transition_to("idle")
		return

	# 更新面朝方向
	if direction.x != 0:
		host.face_direction = Vector2(signf(direction.x), 0)

	# 应用移动
	var speed: float = stats.move_speed if stats else GameConstants.DEFAULT_SPEED
	host.velocity = direction * speed
	host.move_and_slide()
