# scripts/enemies/enemy_state_base.gd
# 敌人状态基类，提供宿主访问和 AI 工具方法。
# 所有敌人状态脚本必须继承此类。

extends Node


## 由 StateMachine 注入
var state_machine: Node = null


## 获取宿主角色
var host: CharacterBody2D:
	get:
		return state_machine.host if state_machine else null


## 获取属性组件
var stats: Node:
	get:
		return host.get_node_or_null("Stats") if host else null


## 虚方法：进入状态
func enter() -> void:
	pass


## 虚方法：退出状态
func exit() -> void:
	pass


## 虚方法：物理帧更新
func physics_update(_delta: float) -> void:
	pass


## 虚方法：帧更新
func update(_delta: float) -> void:
	pass


## 获取玩家引用
func _get_player() -> CharacterBody2D:
	var tree: SceneTree = get_tree()
	if not tree:
		return null
	return tree.get_first_node_in_group("player") as CharacterBody2D


## 到玩家的距离
func _distance_to_player() -> float:
	var player: CharacterBody2D = _get_player()
	if not player or not host:
		return 9999.0
	return host.global_position.distance_to(player.global_position)


## 到玩家的方向
func _direction_to_player() -> Vector2:
	var player: CharacterBody2D = _get_player()
	if not player or not host:
		return Vector2.ZERO
	return (player.global_position - host.global_position).normalized()
