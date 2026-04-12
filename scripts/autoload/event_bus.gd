# scripts/autoload/event_bus.gd
# 全局事件系统，用于系统间的解耦通信。
# Autoload 单例: EventBus
#
# 用法:
#   EventBus.subscribe("player_damaged", _on_player_damaged)
#   EventBus.emit_event("player_damaged", {"damage": 10, "source": "bandit"})
#   func _on_player_damaged(data: Dictionary) -> void:
#       health -= data.damage

extends Node

## 订阅者存储: event_name -> Array[Callable]
var _subscribers: Dictionary = {}
## 一次性订阅者
var _once_subscribers: Dictionary = {}


## 订阅事件
func subscribe(event_name: String, callback: Callable) -> void:
	if not _subscribers.has(event_name):
		_subscribers[event_name] = []
	if not _subscribers[event_name].has(callback):
		_subscribers[event_name].append(callback)


## 订阅事件（触发一次后自动取消）
func subscribe_once(event_name: String, callback: Callable) -> void:
	if not _once_subscribers.has(event_name):
		_once_subscribers[event_name] = []
	_once_subscribers[event_name].append(callback)


## 取消订阅
func unsubscribe(event_name: String, callback: Callable) -> void:
	if _subscribers.has(event_name):
		_subscribers[event_name].erase(callback)
	if _once_subscribers.has(event_name):
		_once_subscribers[event_name].erase(callback)


## 发射事件
func emit_event(event_name: String, data: Dictionary = {}) -> void:
	# 通知常驻订阅者
	if _subscribers.has(event_name):
		for callback in _subscribers[event_name]:
			if callback.is_valid():
				callback.call(data)

	# 通知一次性订阅者并清除
	if _once_subscribers.has(event_name):
		var callbacks := _once_subscribers[event_name].duplicate()
		_once_subscribers[event_name].clear()
		for callback in callbacks:
			if callback.is_valid():
				callback.call(data)


## 清除指定事件的所有订阅者
func clear_event(event_name: String) -> void:
	_subscribers.erase(event_name)
	_once_subscribers.erase(event_name)


## 清除所有订阅者
func clear_all() -> void:
	_subscribers.clear()
	_once_subscribers.clear()


## 调试: 打印所有注册事件
func debug_print_events() -> void:
	print("=== EventBus Debug ===")
	for event_name in _subscribers:
		var count: int = _subscribers[event_name].size()
		print("  %s: %d subscribers" % [event_name, count])
	for event_name in _once_subscribers:
		var count: int = _once_subscribers[event_name].size()
		print("  %s (once): %d subscribers" % [event_name, count])
