# scripts/characters/state_machine/player_states/player_state_base.gd
# 玩家状态的基类，所有玩家状态继承此脚本。
# 挂载为 StateMachine 子节点。

extends Node

## 状态机引用（由 StateMachine 在 _ready 时注入）
var state_machine: Node = null

## 快捷访问宿主角色
var host: CharacterBody2D:
	get: return state_machine.host if state_machine else null

## 快捷访问角色属性
var stats: Node:
	get: return host.get_node_or_null("Stats") if host else null


## 进入状态时调用
func enter() -> void:
	pass


## 退出状态时调用
func exit() -> void:
	pass


## 每物理帧更新
func physics_update(_delta: float) -> void:
	pass


## 每帧更新
func update(_delta: float) -> void:
	pass


## 检测攻击输入
func _is_attack_pressed() -> bool:
	return Input.is_action_just_pressed("attack")


## 检测冲刺输入
func _is_dash_pressed() -> bool:
	return Input.is_action_just_pressed("dash")


## 获取移动输入方向
func _get_movement_input() -> Vector2:
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	return direction.normalized()
