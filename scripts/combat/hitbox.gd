# scripts/combat/hitbox.gd
# 攻击判定区域。启用时检测与 Hurtbox 的重叠，造成伤害。

extends Area2D

## 伤害值
@export var damage: float = 10.0

## 击退力度
@export var knockback_force: float = 300.0

## 攻击者引用
var attacker: Node2D = null

## 已命中的对象（防止重复判定）
var _hit_targets: Array[Node2D] = []


func _ready() -> void:
	# 默认禁用
	monitoring = false
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


## 启用攻击判定
func activate() -> void:
	_hit_targets.clear()
	monitoring = true


## 禁用攻击判定
func deactivate() -> void:
	monitoring = false
	_hit_targets.clear()


func _on_body_entered(_body: Node2D) -> void:
	pass  # 主要通过 Area 检测 Hurtbox


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox") and not _hit_targets.has(area.owner as Node2D):
		_hit_targets.append(area.owner as Node2D)
		CombatHitboxHelper.apply_hit(self, area)
