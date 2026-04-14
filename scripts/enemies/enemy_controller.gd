# scripts/enemies/enemy_controller.gd
# 敌人角色控制器。挂载在 CharacterBody2D 根节点上。
# 管理 AI 状态机、战斗交互、死亡处理。

extends CharacterBody2D


## 敌人类型
@export var enemy_type: GameConstants.EnemyType = GameConstants.EnemyType.BANDIT

## 面朝方向
var face_direction: Vector2 = Vector2.LEFT

## 无敌状态
var _is_invincible: bool = false

## 节点引用
@onready var state_machine: Node = $StateMachine
@onready var stats: Node = $Stats
@onready var hitbox: Area2D = $HitboxPivot/Hitbox
@onready var hurtbox: Area2D = $Hurtbox
@onready var sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	add_to_group("enemies")

	# 生成像素精灵
	_setup_sprite()

	# 设置 hitbox 的攻击者引用
	hitbox.attacker = self

	# 连接属性信号
	stats.died.connect(_on_died)


## 根据敌人类型生成精灵
func _setup_sprite() -> void:
	var char_id: String = "bandit"
	if enemy_type == GameConstants.EnemyType.GUARD:
		char_id = "guard"

	var frames: SpriteFrames = PixelArtGenerator.generate_sprite_frames(char_id)
	if frames:
		sprite.sprite_frames = frames
		sprite.play("idle")


func _physics_process(_delta: float) -> void:
	# 更新面朝方向和 hitbox 朝向
	if velocity.x > 1.0:
		face_direction = Vector2.RIGHT
		$HitboxPivot.scale.x = 1.0
		sprite.flip_h = false
	elif velocity.x < -1.0:
		face_direction = Vector2.LEFT
		$HitboxPivot.scale.x = -1.0
		sprite.flip_h = true


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


## 受到伤害
func take_damage(amount: float, knockback: Vector2) -> void:
	if _is_invincible or not stats.is_alive:
		return

	stats.take_damage(amount)
	velocity = knockback

	# 切换到受击状态
	if stats.is_alive:
		state_machine.transition_to("hurt")

	# 通知 UI / 系统
	EventBus.emit_event("enemy_damaged", {
		"enemy": self,
		"damage": amount,
		"health": stats.current_health,
	})


## 设置无敌状态
func set_invincible(enabled: bool) -> void:
	_is_invincible = enabled
	hurtbox.set_invincible(GameConstants.INVINCIBILITY_DURATION if enabled else 0.0)


## 死亡处理
func _on_died() -> void:
	# 通知 run_tracker
	EventBus.emit_event("enemy_died", {
		"enemy": self,
		"position": global_position,
		"enemy_type": enemy_type,
	})

	# 递增 GameManager 击杀计数
	if GameManager.current_run:
		GameManager.current_run.enemies_killed += 1

	# 切换到死亡状态
	state_machine.transition_to("death")
