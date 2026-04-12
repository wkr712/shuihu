# scripts/characters/character_stats.gd
# 角色属性组件。挂载为角色子节点，管理生命值、攻击力、速度等。

extends Node

## 信号
signal health_changed(current: float, max_val: float)
signal died

## 基础属性
@export var max_health: float = GameConstants.MAX_HEALTH
@export var move_speed: float = GameConstants.DEFAULT_SPEED
@export var attack_power: float = GameConstants.DEFAULT_ATTACK

## 冲刺次数
@export var max_dash_charges: int = 2
@export var dash_cooldown: float = GameConstants.DASH_COOLDOWN

## 当前状态
var current_health: float = 0.0
var dash_charges: int = 0
var _dash_cooldown_timer: float = 0.0
var is_alive: bool = true

## 宿主引用
var _host: CharacterBody2D = null


func _ready() -> void:
	_host = owner as CharacterBody2D
	current_health = max_health
	dash_charges = max_dash_charges


func _process(delta: float) -> void:
	if _dash_cooldown_timer > 0.0:
		_dash_cooldown_timer -= delta
		if _dash_cooldown_timer <= 0.0 and dash_charges < max_dash_charges:
			dash_charges += 1
			_dash_cooldown_timer = dash_cooldown


## 是否可以冲刺
var can_dash: bool:
	get: return dash_charges > 0


## 使用冲刺
func use_dash() -> void:
	dash_charges -= 1
	_dash_cooldown_timer = dash_cooldown


## 受到伤害
func take_damage(amount: float) -> void:
	if not is_alive:
		return

	current_health = maxf(current_health - amount, 0.0)
	health_changed.emit(current_health, max_health)

	if current_health <= 0.0:
		is_alive = false
		died.emit()


## 恢复生命
func heal(amount: float) -> void:
	current_health = minf(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)
