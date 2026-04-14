# scripts/roguelike/room_manager.gd
# 房间管理器：管理房间视觉（地板/墙壁/门 tile）和房间刷新。
# RunTracker 已移至 game_world，通过 EventBus 监听清房事件。

extends Node2D


## TileMapLayer 引用
@onready var floor_layer: TileMapLayer = $FloorLayer
@onready var wall_layer: TileMapLayer = $WallLayer
@onready var door_layer: TileMapLayer = $DoorLayer


func _ready() -> void:
	_setup_tileset()
	_paint_floor()
	_paint_walls()
	_paint_pillars()
	close_doors()

	# 通过 EventBus 监听清房事件
	EventBus.subscribe("room_cleared", _on_room_cleared_event)


## 初始化 TileSet（程序化生成）
func _setup_tileset() -> void:
	var ts: TileSet = TilesetGenerator.generate_dungeon_tileset()
	if floor_layer:
		floor_layer.tile_set = ts
	if wall_layer:
		wall_layer.tile_set = ts
	if door_layer:
		door_layer.tile_set = ts


## 绘制地板 tile（随机石砖变体）
func _paint_floor() -> void:
	if not floor_layer:
		return
	# 房间 640x360 像素 = 40x22.5 tile，用 40x23 覆盖
	# tile 坐标中心在 (0,0)，范围 (-20, -11) 到 (19, 11)
	for y: int in range(-11, 12):
		for x: int in range(-20, 20):
			# 随机选择地板变体
			var variant: int = randi() % 3  # 0, 1, 2
			# source 0 = floor atlas, tile coords = (variant, 0)
			floor_layer.set_cell(Vector2i(x, y), 0, Vector2i(variant, 0))


## 绘制墙壁 tile
func _paint_walls() -> void:
	if not wall_layer:
		return
	# 上墙 (y = -12)
	for x: int in range(-20, 20):
		wall_layer.set_cell(Vector2i(x, -12), 1, Vector2i(0, 0))
	# 下墙 (y = 12)
	for x: int in range(-20, 20):
		wall_layer.set_cell(Vector2i(x, 12), 1, Vector2i(1, 0))
	# 左墙 (x = -21)
	for y: int in range(-11, 12):
		wall_layer.set_cell(Vector2i(-21, y), 1, Vector2i(2, 0))
	# 右墙 (x = 20)
	for y: int in range(-11, 12):
		wall_layer.set_cell(Vector2i(20, y), 1, Vector2i(3, 0))


## 绘制柱子 tile（检测场景中的柱子碰撞体位置）
func _paint_pillars() -> void:
	if not wall_layer:
		return
	# 查找所有 pillar 碰撞体，在其位置绘制柱子 tile
	for child: Node in get_children():
		if child is StaticBody2D and child.name.find("Pillar") >= 0:
			for sub: Node in child.get_children():
				if sub is CollisionShape2D:
					var pos: Vector2 = sub.global_position - global_position
					# 转换为 tile 坐标
					var tile_pos: Vector2i = Vector2i(
						int(pos.x) / 16,
						int(pos.y) / 16
					)
					# 柱子 tile = source 1, atlas coord (8 % 4, 8 / 4) = (0, 2)
					wall_layer.set_cell(tile_pos, 1, Vector2i(0, 2))
					# 柱子顶部和底部覆盖
					wall_layer.set_cell(tile_pos + Vector2i(0, -1), 1, Vector2i(0, 2))
					wall_layer.set_cell(tile_pos + Vector2i(0, 1), 1, Vector2i(0, 2))


## 关闭门（战斗进行中）
func close_doors() -> void:
	if not door_layer:
		return
	_set_door_tiles(2)  # source_id 2 = 关闭的门


## 打开门（房间已清除）
func open_doors() -> void:
	if not door_layer:
		return
	_set_door_tiles(3)  # source_id 3 = 打开的门


## 设置门 tile
func _set_door_tiles(tile_variant_x: int) -> void:
	# 左门位置 (x=-21, y=-2 到 y=2)
	for y: int in range(-2, 3):
		door_layer.set_cell(Vector2i(-21, y), 2, Vector2i(tile_variant_x, 0))
	# 右门位置 (x=20, y=-2 到 y=2)
	for y: int in range(-2, 3):
		door_layer.set_cell(Vector2i(20, y), 2, Vector2i(tile_variant_x, 0))


## EventBus 清房回调
func _on_room_cleared_event(_data: Dictionary) -> void:
	open_doors()
