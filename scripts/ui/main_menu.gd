# scripts/ui/main_menu.gd
# 主菜单界面逻辑

extends Control


func _ready() -> void:
	GameTheme.apply_to(self)
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)


func _on_start_pressed() -> void:
	SceneManager.change_scene("res://scenes/ui/hero_select.tscn")


func _on_quit_pressed() -> void:
	SceneManager.quit_game()
