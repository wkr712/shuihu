# scripts/effects/hit_particles.gd
# 受击粒子效果：在碰撞点生成彩色碎片，散射后淡出。

extends CPUParticles2D


func _ready() -> void:
	emitting = true
	one_shot = true
	explosiveness = 0.9
	amount = 6
	lifetime = 0.3
	direction = Vector2(0, -1)
	spread = 60.0
	gravity = Vector2(0, 80)
	initial_velocity_min = 40.0
	initial_velocity_max = 80.0
	scale_amount_min = 1.0
	scale_amount_max = 2.0

	# 自动销毁
	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(queue_free)


## 设置粒子颜色
func set_color(color: Color) -> void:
	color_r = color.r
	color_g = color.g
	color_b = color.b
