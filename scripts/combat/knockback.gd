# scripts/combat/knockback.gd
# 击退效果组件。挂载到需要受击退效果的实体上。

extends Node

## 击退衰减速度
@export var decay_rate: float = 500.0

## 当前击退速度
var _knockback_velocity: Vector2 = Vector2.ZERO

## 宿主
var _host: CharacterBody2D = null


func _ready() -> void:
	_host = owner as CharacterBody2D
	EventBus.subscribe("entity_damaged", _on_entity_damaged)


## 接收击退事件
func _on_entity_damaged(data: Dictionary) -> void:
	if data.get("target") != _host:
		return
	_knockback_velocity = data.get("knockback", Vector2.ZERO)


## 每物理帧应用击退力
func physics_update(delta: float) -> void:
	if _knockback_velocity == Vector2.ZERO:
		return

	_host.velocity += _knockback_velocity * delta
	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, decay_rate * delta)
