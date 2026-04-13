# scripts/game/game_world.gd
# 游戏世界场景控制器：协调玩家、房间、升级的完整流程。

extends Node2D


## 当前升级选项
var _current_upgrade_choices: Array[UpgradeDataResource] = []

## 节点引用
@onready var player: CharacterBody2D = $Player
@onready var basic_room: Node2D = $BasicRoom
@onready var hud: CanvasLayer = $HUD
@onready var upgrade_manager: Node = $UpgradeManager
@onready var upgrade_select: Control = $UpgradeSelect


func _ready() -> void:
	# 应用英雄数据
	_apply_hero_data()

	# 获取 run_tracker 并连接信号
	var run_tracker: Node = basic_room.get_node_or_null("RunTracker")
	if run_tracker:
		run_tracker.room_cleared.connect(_on_room_cleared)
		run_tracker.start_run()

	# 监听回合结束
	GameManager.run_ended.connect(_on_run_ended)


## 应用选中英雄的数据
func _apply_hero_data() -> void:
	if not player or not player.has_node("Stats"):
		return

	var stats: Node = player.get_node("Stats")
	var hero_id: String = GameManager.selected_hero_id

	if hero_id == "" or not GameManager.current_run:
		return

	var hero_data: Resource = _load_hero_data(hero_id)
	if not hero_data:
		return

	stats.max_health = hero_data.max_health
	stats.current_health = hero_data.max_health
	stats.move_speed = hero_data.move_speed
	stats.attack_power = hero_data.attack_power
	stats.max_dash_charges = hero_data.max_dash_charges

	if player.has_node("Sprite"):
		player.get_node("Sprite").color = hero_data.sprite_color

	if player.has_node("HitboxPivot/Hitbox"):
		player.get_node("HitboxPivot/Hitbox").damage = hero_data.attack_power


## 加载英雄数据资源
func _load_hero_data(hero_id: String) -> Resource:
	var path: String = "res://resources/characters/hero_data/%s.tres" % hero_id
	if ResourceLoader.exists(path):
		return load(path)
	return null


## 房间清除回调
func _on_room_cleared(_room: int, _floor: int) -> void:
	# 生成升级选择
	_current_upgrade_choices = upgrade_manager.generate_choices()
	upgrade_select.show_choices(_current_upgrade_choices, _on_upgrade_chosen)


## 升级选择回调
func _on_upgrade_chosen(index: int) -> void:
	if index < 0 or index >= _current_upgrade_choices.size():
		return

	var chosen: UpgradeDataResource = _current_upgrade_choices[index]
	upgrade_manager.apply_upgrade(chosen, player)

	# 推进到下一个房间
	var run_tracker: Node = basic_room.get_node_or_null("RunTracker")
	if run_tracker:
		run_tracker.advance_room()


## 回合结束回调
func _on_run_ended(victory: bool) -> void:
	SceneManager.change_scene("res://scenes/ui/run_summary.tscn")
