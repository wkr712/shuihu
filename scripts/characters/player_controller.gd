# scripts/characters/player_controller.gd
# 玩家角色控制器。挂载在 CharacterBody2D 根节点上。
# 管理输入、状态机通信、战斗交互。

extends CharacterBody2D

## 面朝方向
var face_direction: Vector2 = Vector2.RIGHT

## 无敌状态
var _is_invincible: bool = false

## 节点引用
@onready var state_machine: Node = $StateMachine
@onready var stats: Node = $Stats
@onready var hitbox: Area2D = $HitboxPivot/Hitbox
@onready var hurtbox: Area2D = $Hurtbox
@onready var sprite: ColorRect = $Sprite


func _ready() -> void:
	add_to_group("player")

	# 连接属性信号
	stats.health_changed.connect(_on_health_changed)
	stats.died.connect(_on_died)

	# 连接暂停
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_resumed.connect(_on_game_resumed)


func _physics_process(_delta: float) -> void:
	pass


## 攻击开始（由攻击状态调用）
func attack_started() -> void:
	hitbox.activate()


## 攻击结束（由攻击状态调用）
func attack_finished() -> void:
	hitbox.deactivate()


## 受到伤害（由 CombatSystem 调用）
func take_damage(amount: float, knockback: Vector2) -> void:
	if _is_invincible or not stats.is_alive:
		return

	stats.take_damage(amount)
	velocity = knockback

	# 播放受击音效
	AudioManager.play_sfx("res://assets/audio/sfx/combat/hit.wav", 0.1)

	# 切换到受击状态
	if stats.is_alive:
		state_machine.transition_to("hurt")

	# 通知 UI
	EventBus.emit_event("player_damaged", {"damage": amount, "health": stats.current_health})


## 设置无敌状态
func set_invincible(enabled: bool) -> void:
	_is_invincible = enabled
	hurtbox.set_invincible(GameConstants.INVINCIBILITY_DURATION if enabled else 0.0)

	# 无敌闪烁效果
	if enabled:
		_start_flash()
	else:
		_stop_flash()


## 无敌闪烁
var _flash_tween: Tween = null

func _start_flash() -> void:
	_stop_flash()
	_flash_tween = create_tween().set_loops()
	_flash_tween.tween_property(sprite, "color:a", 0.3, 0.1)
	_flash_tween.tween_property(sprite, "color:a", 1.0, 0.1)


func _stop_flash() -> void:
	if _flash_tween:
		_flash_tween.kill()
		_flash_tween = null
	if sprite:
		sprite.color.a = 1.0


func _on_health_changed(current: float, max_val: float) -> void:
	EventBus.emit_event("player_health_changed", {
		"current": current,
		"max": max_val,
	})


func _on_died() -> void:
	EventBus.emit_event("player_died", {"position": global_position})
	# 禁用输入和碰撞
	set_physics_process(false)
	if hurtbox:
		hurtbox.monitorable = false
	# 死亡闪烁效果
	_start_death_flash()
	# 延迟触发回合结束
	get_tree().create_timer(1.0).timeout.connect(func() -> void:
		GameManager.end_run(false)
	)


func _start_death_flash() -> void:
	_stop_flash()
	var tween := create_tween()
	tween.tween_property(sprite, "color:a", 0.0, 0.15)
	tween.tween_property(sprite, "color:a", 1.0, 0.15)
	tween.tween_property(sprite, "color:a", 0.0, 0.15)
	tween.tween_property(sprite, "color:a", 1.0, 0.15)
	tween.tween_property(sprite, "color:a", 0.0, 0.2)


func _on_game_paused() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED


func _on_game_resumed() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
