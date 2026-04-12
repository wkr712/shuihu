# scripts/autoload/scene_manager.gd
# 处理带过渡效果的场景切换。
# Autoload 单例: SceneManager

extends Node

## 信号
signal transition_started
signal transition_finished

## 配置
var default_transition_duration: float = 0.5

## 内部状态
var _is_transitioning: bool = false
var _transition_overlay: ColorRect = null


func _ready() -> void:
	# 创建全屏 ColorRect 用于过渡遮罩
	_transition_overlay = ColorRect.new()
	_transition_overlay.color = Color.BLACK
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_overlay.z_index = 100
	_transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_transition_overlay.modulate.a = 0.0

	# 添加到 CanvasLayer 使其绘制在最上层
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	canvas.add_child(_transition_overlay)
	add_child(canvas)


func is_transitioning() -> bool:
	return _is_transitioning


## 带淡入淡出的场景切换
func change_scene(target_scene: String, duration: float = -1.0) -> void:
	if _is_transitioning:
		push_warning("SceneManager: Transition already in progress")
		return

	if duration < 0.0:
		duration = default_transition_duration

	_is_transitioning = true
	transition_started.emit()
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var tween := create_tween()
	# 淡出到黑屏
	tween.tween_property(_transition_overlay, "modulate:a", 1.0, duration * 0.5)
	tween.tween_callback(func() -> void:
		get_tree().change_scene_to_file(target_scene)
	)
	# 从黑屏淡入
	tween.tween_property(_transition_overlay, "modulate:a", 0.0, duration * 0.5)
	tween.tween_callback(func() -> void:
		_is_transitioning = false
		_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		transition_finished.emit()
	)


## 重新加载当前场景
func reload_current_scene(duration: float = -1.0) -> void:
	var current := get_tree().current_scene.scene_file_path
	change_scene(current, duration)


## 退出游戏
func quit_game() -> void:
	get_tree().quit()
