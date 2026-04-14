# scripts/game/game_world.gd
# 游戏世界场景控制器：协调玩家、房间、升级的完整流程。

extends Node2D


## 房间模板路径
const ROOM_TEMPLATES: Array[String] = [
	"res://scenes/levels/room_templates/basic_room.tscn",
	"res://scenes/levels/room_templates/narrow_room.tscn",
	"res://scenes/levels/room_templates/arena_room.tscn",
]

## 当前升级选项
var _current_upgrade_choices: Array[UpgradeDataResource] = []

## 当前房间实例
var _current_room: Node2D = null

## 过渡遮罩
var _transition_rect: ColorRect = null
## 是否正在过渡
var _is_transitioning: bool = false

## 节点引用
@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var upgrade_manager: Node = $UpgradeManager
@onready var upgrade_select: Control = $UpgradeSelect
@onready var run_tracker: Node = $RunTracker


func _ready() -> void:
	# 创建过渡遮罩
	_create_transition_overlay()

	# 应用英雄数据
	_apply_hero_data()

	# 连接 run_tracker 信号
	run_tracker.room_cleared.connect(_on_room_cleared)
	run_tracker.room_changed.connect(_on_room_changed)

	# 监听回合结束
	GameManager.run_ended.connect(_on_run_ended)

	# 开始回合
	run_tracker.start_run()


## 房间变更回调 — 带淡入淡出过渡效果
func _on_room_changed(room: int, floor: int) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true

	# 淡出
	var tween := create_tween()
	tween.tween_property(_transition_rect, "color:a", 1.0, 0.2)
	tween.tween_callback(func() -> void:
		_spawn_room(-1)
		run_tracker.start_room_battle()
		# 淡入
		var tween2 := create_tween()
		tween2.tween_property(_transition_rect, "color:a", 0.0, 0.3)
		tween2.tween_callback(func() -> void:
			_is_transitioning = false
		)
	)


## 生成随机房间
func _spawn_room(template_index: int) -> void:
	# 移除旧房间
	if _current_room:
		_current_room.queue_free()

	# 随机选择模板
	var path: String
	if template_index >= 0 and template_index < ROOM_TEMPLATES.size():
		path = ROOM_TEMPLATES[template_index]
	else:
		path = ROOM_TEMPLATES[randi() % ROOM_TEMPLATES.size()]

	var scene: PackedScene = load(path) as PackedScene
	if not scene:
		return

	_current_room = scene.instantiate()
	add_child(_current_room)
	# 确保房间在玩家下层
	move_child(_current_room, 0)

	# 通知 run_tracker 收集新生成点
	run_tracker.collect_spawn_points(_current_room)


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
	run_tracker.advance_room()


## 回合结束回调
func _on_run_ended(victory: bool) -> void:
	SceneManager.change_scene("res://scenes/ui/run_summary.tscn")


## 创建全屏过渡遮罩
func _create_transition_overlay() -> void:
	_transition_rect = ColorRect.new()
	_transition_rect.color = Color(0, 0, 0, 0)
	_transition_rect.z_index = 100
	# 全屏覆盖 (640x360 viewport)
	_transition_rect.offset_left = -320.0
	_transition_rect.offset_top = -180.0
	_transition_rect.offset_right = 320.0
	_transition_rect.offset_bottom = 180.0
	add_child(_transition_rect)
