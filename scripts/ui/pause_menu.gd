# scripts/ui/pause_menu.gd
# 暂停菜单叠加层：显示继续/返回主菜单选项。
# 使用 PROCESS_MODE_ALWAYS 确保暂停时仍可操作。

extends CanvasLayer


func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS

	# 连接按钮
	$VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	GameTheme.apply_to($VBoxContainer)

	# 监听暂停信号
	GameManager.game_paused.connect(_on_pause)
	GameManager.game_resumed.connect(_on_resume)

	# 初始隐藏
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause"):
		GameManager.toggle_pause()
		get_viewport().set_input_as_handled()


## 暂停时显示
func _on_pause() -> void:
	visible = true


## 恢复时隐藏
func _on_resume() -> void:
	visible = false


## 继续游戏
func _on_resume_pressed() -> void:
	GameManager.toggle_pause()


## 返回主菜单
func _on_quit_pressed() -> void:
	# 先恢复暂停状态再切场景
	get_tree().paused = false
	GameManager.is_paused = false
	GameManager.change_state(GameManager.GameState.MAIN_MENU)
	SceneManager.change_scene("res://scenes/main/main_menu.tscn")
