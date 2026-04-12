# scripts/ui/hud.gd
# 游戏内 HUD 界面逻辑

extends CanvasLayer

## 节点引用
@onready var health_bar: ProgressBar = $HealthBar
@onready var dash_label: Label = $DashLabel


func _ready() -> void:
	EventBus.subscribe("player_health_changed", _on_player_health_changed)
	EventBus.subscribe("player_damaged", _on_player_damaged)


func _on_player_health_changed(data: Dictionary) -> void:
	var current: float = data.get("current", 0.0)
	var max_val: float = data.get("max", 100.0)
	health_bar.max_value = max_val
	health_bar.value = current


func _on_player_damaged(_data: Dictionary) -> void:
	# 更新冲刺次数显示（从玩家获取）
	_update_dash_display()


func _process(_delta: float) -> void:
	_update_dash_display()


func _update_dash_display() -> void:
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if player and player.has_node("Stats"):
		var stats: Node = player.get_node("Stats")
		dash_label.text = "Dash: %d/%d" % [stats.dash_charges, stats.max_dash_charges]
