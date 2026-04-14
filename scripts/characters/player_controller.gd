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
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	add_to_group("player")

	# 生成像素精灵
	_setup_sprite()

	# 连接属性信号
	stats.health_changed.connect(_on_health_changed)
	stats.died.connect(_on_died)

	# 连接暂停
	GameManager.game_paused.connect(_on_game_paused)
	GameManager.game_resumed.connect(_on_game_resumed)


## 根据当前英雄生成精灵
func _setup_sprite() -> void:
	var hero_id: String = "song_jiang"
	if GameManager.current_run:
		hero_id = GameManager.current_run.hero_id

	var frames: SpriteFrames = PixelArtGenerator.generate_sprite_frames(hero_id)
	if frames:
		sprite.sprite_frames = frames
		sprite.play("idle")


func _physics_process(_delta: float) -> void:
	# 更新朝向精灵翻转
	var dir_x: float = velocity.x
	if dir_x > 1.0:
		sprite.flip_h = false
		face_direction = Vector2.RIGHT
	elif dir_x < -1.0:
		sprite.flip_h = true
		face_direction = Vector2.LEFT


## 播放动画（由状态机调用）
func play_animation(anim_name: String) -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)


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

	# 屏幕震动
	if camera and camera.has_method("shake"):
		camera.shake(3.0, 0.15)

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
	_flash_tween.tween_property(sprite, "modulate:a", 0.3, 0.1)
	_flash_tween.tween_property(sprite, "modulate:a", 1.0, 0.1)


func _stop_flash() -> void:
	if _flash_tween:
		_flash_tween.kill()
		_flash_tween = null
	if sprite:
		sprite.modulate.a = 1.0


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
	# 屏幕大震动
	if camera and camera.has_method("shake"):
		camera.shake(6.0, 0.4)
	# 延迟触发回合结束
	get_tree().create_timer(1.0).timeout.connect(func() -> void:
		GameManager.end_run(false)
	)


func _start_death_flash() -> void:
	_stop_flash()
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.15)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.15)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.15)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.15)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.2)


func _on_game_paused() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED


func _on_game_resumed() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
