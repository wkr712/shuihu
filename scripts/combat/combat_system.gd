# scripts/combat/combat_system.gd
# 战斗辅助工具，处理伤害计算和效果应用。
# 作为静态工具类使用，无需实例化。

class_name CombatHitboxHelper

## 伤害数字场景
var _damage_number_scene: PackedScene = null


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

	# 生成视觉特效
	_spawn_hit_effects(target, damage)

	# 通知目标受击
	if target.has_method("take_damage"):
		target.take_damage(damage, knockback_dir * knockback_force)


## 生成受击视觉特效（伤害数字 + 粒子）
static func _spawn_hit_effects(target: Node2D, damage: float) -> void:
	# 伤害数字
	var scene: PackedScene = load("res://scenes/effects/damage_number.tscn") as PackedScene
	if scene:
		var label: Label = scene.instantiate()
		label.damage_value = damage
		label.global_position = target.global_position + Vector2(0, -20)
		target.get_parent().add_child(label)

	# 受击粒子
	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.amount = 5
	particles.lifetime = 0.25
	particles.direction = Vector2(0, -1)
	particles.spread = 60.0
	particles.gravity = Vector2(0, 80)
	particles.initial_velocity_min = 40.0
	particles.initial_velocity_max = 80.0
	particles.scale_amount_min = 1.0
	particles.scale_amount_max = 2.0
	# 粒子颜色匹配目标
	if target.has_node("Sprite"):
		var sprite: Node = target.get_node("Sprite")
		if sprite is AnimatedSprite2D:
			# 使用白色作为默认
			particles.color = Color(1.0, 0.8, 0.6)
		else:
			particles.color = Color(1.0, 0.8, 0.6)
	else:
		particles.color = Color(1.0, 0.8, 0.6)
	particles.global_position = target.global_position + Vector2(0, -10)
	target.get_parent().add_child(particles)

	# 自动销毁粒子
	particles.get_tree().create_timer(0.5).timeout.connect(particles.queue_free)
