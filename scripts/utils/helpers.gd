# scripts/utils/helpers.gd
# 通用工具函数

class_name Helpers

## 随机整数 [from, to] 含两端
static func randi_range(from: int, to: int) -> int:
	return randi() % (to - from + 1) + from


## 按权重随机选择
static func weighted_random(items: Array[Dictionary]) -> Variant:
	var total_weight: float = 0.0
	for item in items:
		total_weight += item.get("weight", 1.0)

	var roll: float = randf() * total_weight
	var cumulative: float = 0.0

	for item in items:
		cumulative += item.get("weight", 1.0)
		if roll <= cumulative:
			return item.get("value")

	return items[-1].get("value") if items.size() > 0 else null


## 2D 方向枚举转 Vector2
static func direction_to_vector(direction: int) -> Vector2:
	match direction:
		0: return Vector2.UP
		1: return Vector2.RIGHT
		2: return Vector2.DOWN
		3: return Vector2.LEFT
		_: return Vector2.ZERO


## Vector2 转最近的方向枚举
static func vector_to_direction(v: Vector2) -> int:
	if absf(v.x) > absf(v.y):
		return 1 if v.x > 0 else 3
	else:
		return 2 if v.y > 0 else 0


## 格式化秒数为 mm:ss
static func format_time(seconds: float) -> String:
	var mins: int = int(seconds) / 60
	var secs: int = int(seconds) % 60
	return "%02d:%02d" % [mins, secs]
