# scripts/effects/damage_number.gd
# 伤害数字：在受伤位置显示伤害值，上飘淡出后自动销毁。

extends Label


## 伤害值
var damage_value: float = 0.0
## 是否暴击
var is_crit: bool = false
## 自定义颜色（由外部设置，如治疗用绿色）
var custom_color: Color = Color.TRANSPARENT

var _elapsed: float = 0.0
var _duration: float = 0.6
var _start_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	text = str(int(damage_value))
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 像素字体
	var font_path: String = "res://assets/fonts/DotGothic16-Regular.ttf"
	if ResourceLoader.exists(font_path):
		add_theme_font_override("font", load(font_path) as FontFile)

	if is_crit:
		add_theme_font_size_override("font_size", 14)
		add_theme_color_override("font_color", Color(1.0, 0.6, 0.1))
		_start_pos = position + Vector2(randf_range(-4, 4), -8)
	elif custom_color != Color.TRANSPARENT:
		add_theme_font_size_override("font_size", 10)
		add_theme_color_override("font_color", custom_color)
		_start_pos = position + Vector2(randf_range(-4, 4), -4)
	else:
		add_theme_font_size_override("font_size", 10)
		add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		_start_pos = position + Vector2(randf_range(-4, 4), -4)

	position = _start_pos
	z_index = 100


func _process(delta: float) -> void:
	_elapsed += delta

	# 上飘
	position.y = _start_pos.y - _elapsed * 30.0

	# 淡出
	var progress: float = _elapsed / _duration
	modulate.a = 1.0 - progress

	if _elapsed >= _duration:
		queue_free()
