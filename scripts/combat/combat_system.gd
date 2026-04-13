# scripts/combat/combat_system.gd
# 战斗辅助工具，处理伤害计算和效果应用。
# 作为静态工具类使用，无需实例化。

class_name CombatHitboxHelper


## 处理一次命中
static func apply_hit(hitbox: Area2D, hurtbox: Area2D) -> void:
	var target: Node2D = hurtbox.owner as Node2D
	var attacker: Node2D = hitbox.attacker if hitbox.attacker else hitbox.owner as Node2D

	if not target or not hurtbox.can_take_damage():
		return

	# 获取 Hitbox 脚本的伤害参数
	var damage: float = hitbox.damage if "damage" in hitbox else GameConstants.DEFAULT_ATTACK
	var knockback_force: float = hitbox.knockback_force if "knockback_force" in hitbox else 300.0

	# 计算击退方向
	var knockback_dir: Vector2 = Vector2.ZERO
	if target is CharacterBody2D and attacker:
		knockback_dir = (target.global_position - attacker.global_position).normalized()

	# 设置无敌帧
	hurtbox.set_invincible(GameConstants.INVINCIBILITY_DURATION)

	# 发射全局事件
	EventBus.emit_event("entity_damaged", {
		"target": target,
		"attacker": attacker,
		"damage": damage,
		"knockback": knockback_dir * knockback_force,
	})

	# 通知目标受击
	if target.has_method("take_damage"):
		target.take_damage(damage, knockback_dir * knockback_force)
