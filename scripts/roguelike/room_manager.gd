# scripts/roguelike/room_manager.gd
# 房间管理器：管理房间边界、门（视觉指示）和房间刷新。

extends Node2D


## 节点引用
@onready var walls: StaticBody2D = $RoomWalls
@onready var floor_rect: ColorRect = $FloorRect
@onready var run_tracker: Node = $RunTracker
@onready var door_left: ColorRect = $DoorLeft
@onready var door_right: ColorRect = $DoorRight


func _ready() -> void:
	close_doors()

	# 监听房间事件
	run_tracker.room_cleared.connect(_on_room_cleared)


## 关闭门（战斗进行中）
func close_doors() -> void:
	if door_left:
		door_left.visible = true
	if door_right:
		door_right.visible = true


## 打开门（房间已清除）
func open_doors() -> void:
	if door_left:
		door_left.visible = false
	if door_right:
		door_right.visible = false


## 房间清除回调
func _on_room_cleared(_room: int, _floor: int) -> void:
	open_doors()
