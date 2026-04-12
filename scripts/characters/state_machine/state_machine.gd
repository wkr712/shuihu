# scripts/characters/state_machine/state_machine.gd
# 通用有限状态机，管理状态的切换和生命周期。
# 作为角色的子节点使用。

extends Node

## 信号
signal state_changed(new_state: String)

## 当前状态节点
var current_state: Node = null

## 状态名 -> 状态节点的映射
var _states: Dictionary = {}

## 宿主角色引用
@onready var host: CharacterBody2D = owner as CharacterBody2D


func _ready() -> void:
	# 收集所有子节点作为状态
	for child in get_children():
		if child is Node:
			_states[child.name.to_lower()] = child
			child.state_machine = self

	# 默认进入第一个子节点状态
	if get_child_count() > 0:
		current_state = get_child(0)
		current_state.enter()


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


## 切换到指定状态
func transition_to(state_name: String) -> void:
	var key: String = state_name.to_lower()
	if not _states.has(key):
		push_warning("StateMachine: State '%s' not found" % state_name)
		return

	if current_state:
		current_state.exit()

	current_state = _states[key]
	current_state.enter()
	state_changed.emit(state_name)


## 获取宿主角色的某个属性（快捷方式）
func get_host() -> CharacterBody2D:
	return host
