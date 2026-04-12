# scripts/combat/hurtbox.gd
# 受击判定区域。被 Hitbox 检测到后接收伤害。

extends Area2D

## 是否无敌
var is_invincible: bool = false

## 受击冷却计时器
var _invincible_timer: float = 0.0


func _ready() -> void:
	add_to_group("hurtbox")
	monitorable = true


func _process(delta: float) -> void:
	if _invincible_timer > 0.0:
		_invincible_timer -= delta
		if _invincible_timer <= 0.0:
			is_invincible = false


## 设置无敌状态（带持续时间）
func set_invincible(duration: float = 0.5) -> void:
	is_invincible = true
	_invincible_timer = duration


## 检查是否可以受击
func can_take_damage() -> bool:
	return not is_invincible and monitoring
