# scripts/enemies/enemy_states/enemy_death_state.gd
# 敌人死亡状态：闪烁动画后移除节点。

extends "res://scripts/enemies/enemy_state_base.gd"


## 死亡动画持续时间
@export var death_duration: float = 0.5


var _timer: float = 0.0
var _flash_tween: Tween = null


func enter() -> void:
	_timer = death_duration

	# 停止移动
	host.velocity = Vector2.ZERO

	# 禁用碰撞
	host.set_collision_layer_value(2, false)
	host.set_collision_mask_value(1, false)
	host.set_collision_mask_value(3, false)

	# 闪烁效果
	if host.sprite:
		_flash_tween = host.create_tween().set_loops()
		_flash_tween.tween_property(host.sprite, "color:a", 0.2, 0.08)
		_flash_tween.tween_property(host.sprite, "color:a", 0.8, 0.08)


func physics_update(delta: float) -> void:
	_timer -= delta

	if _timer <= 0.0:
		# 清理并移除
		if _flash_tween:
			_flash_tween.kill()
		host.queue_free()


func exit() -> void:
	if _flash_tween:
		_flash_tween.kill()
