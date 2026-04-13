# scripts/ui/hud.gd
# 游戏内 HUD 界面逻辑

extends CanvasLayer


## 节点引用
@onready var health_bar: ProgressBar = $HealthBar
@onready var dash_label: Label = $DashLabel
@onready var floor_label: Label = $FloorLabel
@onready var enemy_label: Label = $EnemyLabel


func _ready() -> void:
	EventBus.subscribe("player_health_changed", _on_player_health_changed)
	EventBus.subscribe("player_damaged", _on_player_damaged)
	EventBus.subscribe("room_changed", _on_room_changed)


func _on_player_health_changed(data: Dictionary) -> void:
	var current: float = data.get("current", 0.0)
	var max_val: float = data.get("max", 100.0)
	health_bar.max_value = max_val
	health_bar.value = current


func _on_player_damaged(_data: Dictionary) -> void:
	_update_dash_display()


func _on_room_changed(data: Dictionary) -> void:
	var room: int = data.get("room", 1)
	var floor: int = data.get("floor", 1)
	floor_label.text = "Floor: %d  Room: %d" % [floor, room]


func _process(_delta: float) -> void:
	_update_dash_display()
	_update_enemy_count()


func _update_dash_display() -> void:
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if player and player.has_node("Stats"):
		var stats: Node = player.get_node("Stats")
		dash_label.text = "Dash: %d/%d" % [stats.dash_charges, stats.max_dash_charges]


func _update_enemy_count() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	enemy_label.text = "Enemies: %d" % enemies.size()
