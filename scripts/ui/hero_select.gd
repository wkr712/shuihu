# scripts/ui/hero_select.gd
# 英雄选择界面：展示 4 位英雄卡片，玩家选择后确认进入游戏。

extends Control


## 英雄数据路径
const HERO_DATA_PATHS: Array[String] = [
	"res://resources/characters/hero_data/song_jiang.tres",
	"res://resources/characters/hero_data/lin_chong.tres",
	"res://resources/characters/hero_data/lu_zhi_shen.tres",
	"res://resources/characters/hero_data/wu_song.tres",
]


## 已加载的英雄数据
var _hero_datas: Array[HeroDataResource] = []
var _selected_index: int = -1

## 节点引用
@onready var hero_grid: GridContainer = $VBoxContainer/HeroGrid
@onready var confirm_button: Button = $VBoxContainer/ConfirmButton
@onready var hero_preview: ColorRect = $VBoxContainer/PreviewPanel/HeroPreview
@onready var stats_label: Label = $VBoxContainer/PreviewPanel/StatsLabel
@onready var desc_label: Label = $VBoxContainer/PreviewPanel/DescLabel
@onready var back_button: Button = $VBoxContainer/BackButton


func _ready() -> void:
	_load_hero_data()
	_create_hero_cards()
	confirm_button.disabled = true
	confirm_button.pressed.connect(_on_confirm_pressed)
	back_button.pressed.connect(_on_back_pressed)


## 加载英雄数据资源
func _load_hero_data() -> void:
	for path: String in HERO_DATA_PATHS:
		if ResourceLoader.exists(path):
			var data: HeroDataResource = load(path) as HeroDataResource
			if data:
				_hero_datas.append(data)


## 创建英雄卡片
func _create_hero_cards() -> void:
	for i: int in range(_hero_datas.size()):
		var data: HeroDataResource = _hero_datas[i]
		var card: Panel = Panel.new()
		card.custom_minimum_size = Vector2(120, 100)

		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER

		# 英雄颜色预览
		var preview: ColorRect = ColorRect.new()
		preview.custom_minimum_size = Vector2(32, 32)
		preview.color = data.sprite_color

		# 英雄名字
		var name_label: Label = Label.new()
		name_label.text = data.display_name
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		vbox.add_child(preview)
		vbox.add_child(name_label)
		card.add_child(vbox)

		# 点击选择
		var button: Button = Button.new()
		button.text = "选择"
		button.pressed.connect(_on_hero_selected.bind(i))
		vbox.add_child(button)

		hero_grid.add_child(card)


## 英雄被选中
func _on_hero_selected(index: int) -> void:
	_selected_index = index
	confirm_button.disabled = false

	var data: HeroDataResource = _hero_datas[index]
	hero_preview.color = data.sprite_color
	stats_label.text = "HP:%.0f  SPD:%.0f  ATK:%.0f  Dash:%d" % [
		data.max_health, data.move_speed, data.attack_power, data.max_dash_charges
	]
	desc_label.text = data.description


## 确认选择
func _on_confirm_pressed() -> void:
	if _selected_index < 0 or _selected_index >= _hero_datas.size():
		return

	var data: HeroDataResource = _hero_datas[_selected_index]
	GameManager.start_run(data.hero_id)
	SceneManager.change_scene("res://scenes/game/game_world.tscn")


## 返回主菜单
func _on_back_pressed() -> void:
	SceneManager.change_scene("res://scenes/main/main_menu.tscn")
