# scripts/roguelike/upgrade_manager.gd
# 升级管理器：加载升级池、随机生成选择、应用属性修改。

extends Node


## 升级资源路径
const UPGRADE_PATHS: Array[String] = [
	"res://resources/items/upgrades/health_up.tres",
	"res://resources/items/upgrades/attack_up.tres",
	"res://resources/items/upgrades/speed_up.tres",
	"res://resources/items/upgrades/heal_small.tres",
	"res://resources/items/upgrades/dash_charge_up.tres",
	"res://resources/items/upgrades/attack_big.tres",
]


var _upgrade_pool: Array[UpgradeDataResource] = []


func _ready() -> void:
	_load_upgrade_pool()


## 加载升级资源池
func _load_upgrade_pool() -> void:
	for path: String in UPGRADE_PATHS:
		if ResourceLoader.exists(path):
			var upgrade: UpgradeDataResource = load(path) as UpgradeDataResource
			if upgrade:
				_upgrade_pool.append(upgrade)


## 生成随机选择
func generate_choices(count: int = GameConstants.UPGRADE_CHOICES) -> Array[UpgradeDataResource]:
	var available: Array[UpgradeDataResource] = _upgrade_pool.duplicate()
	var choices: Array[UpgradeDataResource] = []

	for i: int in range(mini(count, available.size())):
		var idx: int = randi() % available.size()
		choices.append(available[idx])
		available.remove_at(idx)

	return choices


## 应用升级到玩家属性
func apply_upgrade(upgrade: UpgradeDataResource, player: CharacterBody2D) -> void:
	if not player or not player.has_node("Stats"):
		return

	var stats: Node = player.get_node("Stats")

	# 应用属性修改
	for stat_name: String in upgrade.stat_modifiers:
		var value: float = upgrade.stat_modifiers[stat_name]
		if stat_name == "max_health":
			stats.max_health += value
			stats.current_health += value
		elif stat_name == "max_dash_charges":
			stats.max_dash_charges += int(value)
			stats.dash_charges += int(value)
		elif stats.get(stat_name) != null:
			stats.set(stat_name, stats.get(stat_name) + value)

	# 应用治疗
	if upgrade.is_heal and stats.has_method("heal"):
		stats.heal(upgrade.heal_amount)

	# 更新 hitbox 伤害
	if player.has_node("HitboxPivot/Hitbox"):
		player.get_node("HitboxPivot/Hitbox").damage = stats.attack_power

	# 记录升级
	if GameManager.current_run:
		GameManager.current_run.upgrades_collected.append(upgrade.upgrade_id)

	# 通知
	EventBus.emit_event("upgrade_applied", {
		"upgrade_id": upgrade.upgrade_id,
		"modifiers": upgrade.stat_modifiers,
	})
