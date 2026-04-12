# scripts/autoload/game_manager.gd
# 管理全局游戏状态、回合追踪和持久化数据。
# Autoload 单例: GameManager

extends Node

## 信号
signal run_started
signal run_ended(victory: bool)
signal game_paused
signal game_resumed
signal hero_selected(hero_id: String)

## 游戏状态枚举
enum GameState {
	MAIN_MENU,
	HERO_SELECT,
	IN_RUN,
	PAUSED,
	RUN_SUMMARY,
}

## 当前状态
var current_state: GameState = GameState.MAIN_MENU
var is_paused: bool = false

## 回合数据
var current_run: RunData = null
var runs_completed: int = 0
var total_kills: int = 0

## 已选英雄
var selected_hero_id: String = ""

## 回合追踪数据类
class RunData:
	var hero_id: String = ""
	var current_floor: int = 1
	var current_room: int = 0
	var rooms_cleared: int = 0
	var enemies_killed: int = 0
	var upgrades_collected: Array[String] = []
	var gold_earned: int = 0
	var time_elapsed: float = 0.0
	var is_alive: bool = true

	func _init(hero: String) -> void:
		hero_id = hero


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if current_run and current_run.is_alive and current_state == GameState.IN_RUN:
		current_run.time_elapsed += delta


## 状态管理
func change_state(new_state: GameState) -> void:
	current_state = new_state


func toggle_pause() -> void:
	if current_state == GameState.IN_RUN:
		is_paused = true
		current_state = GameState.PAUSED
		get_tree().paused = true
		game_paused.emit()
	elif current_state == GameState.PAUSED:
		is_paused = false
		current_state = GameState.IN_RUN
		get_tree().paused = false
		game_resumed.emit()


## 回合管理
func start_run(hero_id: String) -> void:
	selected_hero_id = hero_id
	current_run = RunData.new(hero_id)
	current_state = GameState.IN_RUN
	run_started.emit()


func end_run(victory: bool) -> void:
	if current_run:
		current_run.is_alive = false
		runs_completed += 1
		total_kills += current_run.enemies_killed
	current_state = GameState.RUN_SUMMARY
	run_ended.emit(victory)


## 获取回合总结
func get_run_summary() -> Dictionary:
	if not current_run:
		return {}
	return {
		"hero": current_run.hero_id,
		"floor": current_run.current_floor,
		"rooms_cleared": current_run.rooms_cleared,
		"enemies_killed": current_run.enemies_killed,
		"upgrades": current_run.upgrades_collected.size(),
		"gold": current_run.gold_earned,
		"time": current_run.time_elapsed,
	}
