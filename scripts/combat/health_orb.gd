# scripts/combat/health_orb.gd
# 治疗球：敌人死亡时概率掉落，玩家触碰恢复 HP。

extends Area2D


@export var heal_amount: float = 10.0
@export var lifetime: float = 10.0

var _elapsed: float = 0.0


func _ready() -> void:
	# 玩家层检测
	collision_mask = 1
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= lifetime:
		_fade_out()

	# 轻微上下浮动
	if has_node("Sprite"):
		$Sprite.position.y = sin(_elapsed * 3.0) * 2.0


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if not body.has_node("Stats"):
		return

	var stats: Node = body.get_node("Stats")
	if stats.has_method("heal"):
		stats.heal(heal_amount)

	EventBus.emit_event("player_healed", {"amount": heal_amount})
	queue_free()


func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property($Sprite, "color:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
	set_process(false)
