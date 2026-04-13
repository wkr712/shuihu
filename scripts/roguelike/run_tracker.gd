# scripts/roguelike/run_tracker.gd
# 回合追踪器：管理房间/楼层推进、敌人生成和清房检测。

extends Node


## 信号
signal room_started(room_number: int, floor_number: int)
signal room_cleared(room_number: int, floor_number: int)
signal floor_cleared(floor_number: int)
signal room_changed(room: int, floor: int)


## 配置
@export var rooms_per_floor: int = GameConstants.ROOMS_PER_FLOOR


## 状态
var current_floor: int = 1
var current_room: int = 0
var enemies_alive: int = 0

## 预加载场景
var _enemy_scenes: Dictionary = {}
## 生成点引用
var _spawn_points: Array[Marker2D] = []
## 当前房间节点引用
var _room_node: Node2D = null


func _ready() -> void:
	_load_enemy_scenes()
	EventBus.subscribe("enemy_died", _on_enemy_died)


## 开始新回合（第一个房间）
func start_run() -> void:
	current_floor = 1
	current_room = 0
	enemies_alive = 0
	advance_room()


## 推进到下一个房间
func advance_room() -> void:
	current_room += 1

	# 检查楼层推进
	if current_room > rooms_per_floor:
		current_room = 1
		current_floor += 1
		floor_cleared.emit(current_floor - 1)

	# 限制最大楼层
	if current_floor > GameConstants.MAX_FLOOR:
		_sync_run_data()
		GameManager.end_run(true)
		return

	_sync_run_data()
	room_changed.emit(current_room, current_floor)


## 开始房间战斗（由 game_world 在房间模板加载后调用）
func start_room_battle() -> void:
	_spawn_room_enemies()
	room_started.emit(current_room, current_floor)

	# 通知 HUD
	EventBus.emit_event("room_changed", {
		"room": current_room,
		"floor": current_floor,
	})


## 收集场景中的生成点（由 game_world 调用）
func collect_spawn_points(room: Node2D) -> void:
	_room_node = room
	_spawn_points.clear()
	if not room:
		return

	var sp_node: Node = room.get_node_or_null("SpawnPoints")
	if sp_node:
		for child in sp_node.get_children():
			if child is Marker2D:
				_spawn_points.append(child)


## 同步数据到 GameManager.current_run
func _sync_run_data() -> void:
	if GameManager.current_run:
		GameManager.current_run.current_floor = current_floor
		GameManager.current_run.current_room = current_room


## 生成当前房间的敌人
func _spawn_room_enemies() -> void:
	var count: int = _get_enemy_count_for_room(current_room)
	var scene: PackedScene = _get_enemy_scene_for_room(current_room)

	if not scene:
		return

	for i in range(count):
		var pos: Vector2 = _get_spawn_position(i)
		var enemy: CharacterBody2D = scene.instantiate()
		enemy.global_position = pos

		# 添加到房间节点
		if _room_node:
			_room_node.add_child(enemy)
			enemies_alive += 1


## 获取房间敌人数量
func _get_enemy_count_for_room(room: int) -> int:
	return 1 + int(room / 2)


## 获取房间敌人场景
func _get_enemy_scene_for_room(room: int) -> PackedScene:
	# 房间 4+ 有概率出现 Guard
	if room >= 4 and randi() % 3 == 0:
		var guard := _enemy_scenes.get(GameConstants.EnemyType.GUARD) as PackedScene
		if guard:
			return guard
	return _enemy_scenes.get(GameConstants.EnemyType.BANDIT)


## 获取生成位置
func _get_spawn_position(index: int) -> Vector2:
	if _spawn_points.is_empty():
		return Vector2.ZERO

	var point_index: int = index % _spawn_points.size()
	return _spawn_points[point_index].global_position


## 敌人死亡回调
func _on_enemy_died(_data: Dictionary) -> void:
	enemies_alive -= 1
	enemies_alive = maxi(enemies_alive, 0)

	if enemies_alive <= 0:
		# 房间清除
		if GameManager.current_run:
			GameManager.current_run.rooms_cleared += 1
		room_cleared.emit(current_room, current_floor)


## 加载敌人场景
func _load_enemy_scenes() -> void:
	var bandit_scene: PackedScene = load("res://scenes/enemies/bandit.tscn") as PackedScene
	if bandit_scene:
		_enemy_scenes[GameConstants.EnemyType.BANDIT] = bandit_scene
	var guard_scene: PackedScene = load("res://scenes/enemies/guard.tscn") as PackedScene
	if guard_scene:
		_enemy_scenes[GameConstants.EnemyType.GUARD] = guard_scene
