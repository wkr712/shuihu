# scripts/resources/upgrade_data_resource.gd
# 升级数据资源类。定义一次升级的效果。

class_name UpgradeDataResource
extends Resource


@export var upgrade_id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var icon_color: Color = Color.WHITE
@export var rarity: GameConstants.Rarity = GameConstants.Rarity.COMMON
@export var stat_modifiers: Dictionary = {}
@export var is_heal: bool = false
@export var heal_amount: float = 0.0
