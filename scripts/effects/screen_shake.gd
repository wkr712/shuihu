# scripts/effects/screen_shake.gd
# 屏幕震动效果：挂载到 Camera2D 上，通过 Tween 实现偏移抖动。

extends Camera2D


var _shake_tween: Tween = null


## 触发屏幕震动
## strength: 最大偏移像素数, duration: 震动持续秒数
func shake(strength: float = 4.0, duration: float = 0.2) -> void:
	if _shake_tween:
		_shake_tween.kill()

	_shake_tween = create_tween()
	_shake_tween.tween_property(self, "offset:x", randf_range(-strength, strength), 0.02)
	_shake_tween.tween_property(self, "offset:y", randf_range(-strength, strength), 0.02)
	_shake_tween.set_loops(int(duration / 0.04))
	_shake_tween.tween_property(self, "offset", Vector2.ZERO, 0.05)
