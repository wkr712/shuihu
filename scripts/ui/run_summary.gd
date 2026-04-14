# scripts/ui/run_summary.gd
# 回合结算界面：显示本局统计数据，提供返回主菜单按钮。

extends Control


## 节点引用
@onready var result_label: Label = $VBoxContainer/ResultLabel
@onready var hero_label: Label = $VBoxContainer/HeroLabel
@onready var floor_label: Label = $VBoxContainer/FloorLabel
@onready var rooms_label: Label = $VBoxContainer/RoomsLabel
@onready var kills_label: Label = $VBoxContainer/KillsLabel
@onready var upgrades_label: Label = $VBoxContainer/UpgradesLabel
@onready var time_label: Label = $VBoxContainer/TimeLabel
@onready var return_button: Button = $VBoxContainer/ReturnButton


func _ready() -> void:
	GameTheme.apply_to(self)
	return_button.pressed.connect(_on_return_pressed)
	_display_summary()


## 显示回合总结
func _display_summary() -> void:
	var summary: Dictionary = GameManager.get_run_summary()

	if summary.is_empty():
		result_label.text = "无数据"
		return

	# 判断胜负
	var is_victory: bool = summary.get("floor", 0) >= GameConstants.MAX_FLOOR
	result_label.text = "胜利！" if is_victory else "战败"
	result_label.add_theme_color_override(
		"font_color", Color(0.2, 0.9, 0.3) if is_victory else Color(0.9, 0.2, 0.2)
	)

	# 英雄名称
	var hero_id: String = summary.get("hero", "")
	var hero_names: Dictionary = {
		"song_jiang": "宋江",
		"lin_chong": "林冲",
		"lu_zhi_shen": "鲁智深",
		"wu_song": "武松",
	}
	hero_label.text = "英雄: %s" % hero_names.get(hero_id, hero_id)

	floor_label.text = "到达楼层: %d" % summary.get("floor", 0)
	rooms_label.text = "清除房间: %d" % summary.get("rooms_cleared", 0)
	kills_label.text = "击杀敌人: %d" % summary.get("enemies_killed", 0)
	upgrades_label.text = "获得强化: %d" % summary.get("upgrades", 0)

	var time: float = summary.get("time", 0.0)
	time_label.text = "用时: %s" % Helpers.format_time(time)


## 返回主菜单
func _on_return_pressed() -> void:
	GameManager.change_state(GameManager.GameState.MAIN_MENU)
	SceneManager.change_scene("res://scenes/main/main_menu.tscn")
