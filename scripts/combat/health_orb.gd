# scripts/combat/health_orb.gd
# 治疗球：敌人死亡时概率掉落，玩家触碰恢复 HP。
# 带脉冲发光效果和磁吸吸引。

extends Area2D


@export var heal_amount: float = 10.0
@export var lifetime: float = 10.0
@export var magnet_range: float = 50.0
@export var magnet_speed: float = 200.0

var _elapsed: float = 0.0
var _pulse_tween: Tween = null


func _ready() -> void:
	# 玩家层检测
	collision_mask = 1
	body_entered.connect(_on_body_entered)

	# 脉冲发光动画
	_start_pulse()


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= lifetime:
		_fade_out()
		return

	# 轻微上下浮动
	if has_node("Sprite"):
		$Sprite.position.y = sin(_elapsed * 3.0) * 2.0

	# 磁吸效果：靠近玩家时加速飞向玩家
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	if player and player.is_inside_tree():
		var dist: float = global_position.distance_to(player.global_position)
		if dist < magnet_range:
			var dir: Vector2 = (player.global_position - global_position).normalized()
			var speed: float = magnet_speed * (1.0 - dist / magnet_range)
			global_position += dir * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if not body.has_node("Stats"):
		return

	var stats: Node = body.get_node("Stats")
	if stats.has_method("heal"):
		stats.heal(heal_amount)

	EventBus.emit_event("player_healed", {"amount": heal_amount})

	# 生成治疗数字
	var scene: PackedScene = load("res://scenes/effects/damage_number.tscn") as PackedScene
	if scene:
		var label: Label = scene.instantiate()
		label.damage_value = heal_amount
		label.is_crit = false
		label.custom_color = Color(0.3, 0.9, 0.4)
		label.global_position = body.global_position + Vector2(0, -20)
		body.get_parent().add_child(label)

	queue_free()


## 脉冲缩放动画
func _start_pulse() -> void:
	if not has_node("Sprite"):
		return
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property($Sprite, "scale", Vector2(1.2, 1.2), 0.4)
	_pulse_tween.tween_property($Sprite, "scale", Vector2(0.9, 0.9), 0.4)


func _fade_out() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
	var tween := create_tween()
	tween.tween_property($Sprite, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
	set_process(false)
