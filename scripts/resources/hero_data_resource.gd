# scripts/resources/hero_data_resource.gd
# 英雄数据资源类。定义英雄的各项属性。

class_name HeroDataResource
extends Resource


@export var hero_id: String = ""
@export var display_name: String = ""
@export var sprite_color: Color = Color.WHITE
@export var max_health: float = 100.0
@export var move_speed: float = 200.0
@export var attack_power: float = 10.0
@export var max_dash_charges: int = 2
@export var weapon_type: GameConstants.WeaponType = GameConstants.WeaponType.SWORD
@export var description: String = ""
