# scripts/ui/upgrade_select.gd
# 升级选择叠加层：清房后显示 3 个升级选项。

extends Control


## 选择回调
var _on_selected: Callable


func _ready() -> void:
	visible = false


## 显示升级选择
func show_choices(upgrades: Array[UpgradeDataResource], on_selected: Callable) -> void:
	_on_selected = on_selected
	visible = true

	# 清空旧卡片
	var container: HBoxContainer = $DimBackground/VBoxContainer/ChoiceContainer
	for child: Node in container.get_children():
		child.queue_free()

	# 创建新卡片
	for i: int in range(upgrades.size()):
		var upgrade: UpgradeDataResource = upgrades[i]
		var card: Panel = _create_upgrade_card(upgrade, i)
		container.add_child(card)


## 创建升级卡片
func _create_upgrade_card(upgrade: UpgradeDataResource, index: int) -> Panel:
	var card: Panel = Panel.new()
	card.custom_minimum_size = Vector2(150, 120)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER

	# 图标
	var icon: ColorRect = ColorRect.new()
	icon.custom_minimum_size = Vector2(24, 24)
	icon.color = upgrade.icon_color

	# 名称
	var name_label: Label = Label.new()
	name_label.text = upgrade.display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 描述
	var desc_label: Label = Label.new()
	desc_label.text = upgrade.description
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 稀有度标签
	var rarity_names: Array[String] = ["普通", "优秀", "稀有"]
	var rarity_label: Label = Label.new()
	rarity_label.text = rarity_names[upgrade.rarity] if upgrade.rarity < rarity_names.size() else ""
	rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	vbox.add_child(icon)
	vbox.add_child(name_label)
	vbox.add_child(desc_label)
	vbox.add_child(rarity_label)

	# 选择按钮
	var button: Button = Button.new()
	button.text = "选择"
	button.pressed.connect(_on_upgrade_chosen.bind(index))
	vbox.add_child(button)

	card.add_child(vbox)
	return card


## 选择了一个升级
func _on_upgrade_chosen(index: int) -> void:
	visible = false
	if _on_selected.is_valid():
		_on_selected.call(index)
