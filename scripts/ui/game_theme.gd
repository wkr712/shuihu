# scripts/ui/game_theme.gd
# 游戏主题管理器：创建并应用像素风 UI 主题。
# 调用 GameTheme.apply_to(control) 即可将主题应用到任意 Control 子树。

class_name GameTheme


## 像素字体路径
const FONT_PATH: String = "res://assets/fonts/DotGothic16-Regular.ttf"

## 颜色定义
const COLOR_BG_DARK: Color = Color(0.08, 0.08, 0.12)
const COLOR_BG_PANEL: Color = Color(0.12, 0.12, 0.18)
const COLOR_GOLD: Color = Color(0.85, 0.72, 0.28)
const COLOR_GOLD_DARK: Color = Color(0.60, 0.50, 0.18)
const COLOR_TEXT: Color = Color(0.92, 0.90, 0.85)
const COLOR_TEXT_DIM: Color = Color(0.60, 0.58, 0.55)
const COLOR_HP_RED: Color = Color(0.82, 0.22, 0.18)
const COLOR_HP_BG: Color = Color(0.30, 0.10, 0.10)

## 缓存主题
static var _theme: Theme = null


## 获取全局主题
static func get_theme() -> Theme:
	if _theme == null:
		_theme = _create_theme()
	return _theme


## 应用主题到 Control 节点
static func apply_to(control: Control) -> void:
	control.theme = get_theme()


## 创建主题
static func _create_theme() -> Theme:
	var theme := Theme.new()

	# 加载字体
	var font := _load_font()

	# --- Button ---
	var btn_normal := StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.15, 0.14, 0.20)
	btn_normal.border_color = COLOR_GOLD_DARK
	btn_normal.set_border_width_all(2)
	btn_normal.set_corner_radius_all(2)
	btn_normal.set_content_margin_all(8)

	var btn_hover := btn_normal.duplicate()
	btn_hover.bg_color = Color(0.22, 0.20, 0.30)
	btn_hover.border_color = COLOR_GOLD

	var btn_pressed := btn_normal.duplicate()
	btn_pressed.bg_color = Color(0.10, 0.10, 0.15)
	btn_pressed.border_color = COLOR_GOLD
	btn_pressed.set_border_width(Side.SIDE_TOP, 3)
	btn_pressed.set_border_width(Side.SIDE_BOTTOM, 1)

	var btn_disabled := btn_normal.duplicate()
	btn_disabled.bg_color = Color(0.10, 0.10, 0.13)
	btn_disabled.border_color = Color(0.35, 0.30, 0.20)

	theme.set_stylebox("normal", "Button", btn_normal)
	theme.set_stylebox("hover", "Button", btn_hover)
	theme.set_stylebox("pressed", "Button", btn_pressed)
	theme.set_stylebox("disabled", "Button", btn_disabled)
	theme.set_color("font_color", "Button", COLOR_TEXT)
	theme.set_color("font_hover_color", "Button", COLOR_GOLD)
	theme.set_color("font_disabled_color", "Button", COLOR_TEXT_DIM)
	theme.set_font("font", "Button", font)
	theme.set_font_size("font_size", "Button", 12)

	# --- Label ---
	theme.set_color("font_color", "Label", COLOR_TEXT)
	theme.set_font("font", "Label", font)
	theme.set_font_size("font_size", "Label", 11)

	# --- Panel ---
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.12, 0.18, 0.9)
	panel_style.border_color = COLOR_GOLD_DARK
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(3)
	theme.set_stylebox("panel", "Panel", panel_style)
	theme.set_stylebox("panel", "PanelContainer", panel_style)

	# --- ProgressBar ---
	var pb_bg := StyleBoxFlat.new()
	pb_bg.bg_color = COLOR_HP_BG
	pb_bg.border_color = COLOR_GOLD_DARK
	pb_bg.set_border_width_all(1)
	pb_bg.set_corner_radius_all(1)

	var pb_fill := StyleBoxFlat.new()
	pb_fill.bg_color = COLOR_HP_RED
	pb_fill.set_corner_radius_all(1)

	theme.set_stylebox("background", "ProgressBar", pb_bg)
	theme.set_stylebox("fill", "ProgressBar", pb_fill)

	# --- HSeparator ---
	var sep_style := StyleBoxFlat.new()
	sep_style.bg_color = COLOR_GOLD_DARK
	sep_style.set_content_margin_all(2)
	theme.set_stylebox("separator", "HSeparator", sep_style)

	return theme


## 加载像素字体
static func _load_font() -> FontFile:
	var font := FontFile.new()
	font.font_path = FONT_PATH
	return font


## 创建大号标题字体（用于标题文字）
static func get_title_font() -> FontVariation:
	var base := _load_font()
	var variation := FontVariation.new()
	variation.base_font = base
	variation.variation_transform = Transform2D.IDENTITY.scaled(Vector2(1.5, 1.5))
	return variation
