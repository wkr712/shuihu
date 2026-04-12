# 开发代码规范 (CONVENTIONS)

## GDScript 风格指南

基于 [Godot 官方 GDScript 风格指南](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)，以下为本项目的具体规范。

### 命名约定

| 类型 | 风格 | 示例 |
|---|---|---|
| 文件名 | snake_case | `player_controller.gd` |
| 类名 (class_name) | PascalCase | `GameConstants` |
| 节点名 | PascalCase | `PlayerBody`, `HealthBar` |
| 变量 | snake_case | `move_speed`, `current_health` |
| 常量 | SCREAMING_SNAKE_CASE | `MAX_HEALTH`, `DASH_DURATION` |
| 枚举 | PascalCase 枚举名, SCREAMING_SNAKE_CASE 值 | `enum HeroID { SONG_JIANG }` |
| 函数 | snake_case | `take_damage()`, `apply_knockback()` |
| 信号 | snake_case | `health_changed`, `enemy_killed` |
| 场景文件 | snake_case | `main_menu.tscn` |
| 资源文件 | snake_case | `song_jiang.tres` |

### 代码顺序

每个 .gd 文件应按以下顺序组织：

```gdscript
# 1. 可选: class_name
class_name MyClass

# 2. extends
extends Node

# 3. 信号
signal health_changed(new_health: float)

# 4. 枚举
enum State { IDLE, MOVE, ATTACK }

# 5. 常量
const MAX_SPEED: float = 300.0

# 6. 导出变量
@export var move_speed: float = 200.0

# 7. 公共变量
var current_health: float = 100.0

# 8. 私有变量 (以 _ 开头)
var _is_attacking: bool = false

# 9. 生命周期方法 (按执行顺序)
func _init() -> void: pass
func _ready() -> void: pass
func _process(delta: float) -> void: pass
func _physics_process(delta: float) -> void: pass

# 10. 公共方法
func take_damage(amount: float) -> void: pass

# 11. 私有方法
func _apply_knockback() -> void: pass
```

### 类型标注

- 所有函数参数和返回值必须有类型标注
- 所有变量尽可能标注类型
- 使用 `-> void` 明确无返回值函数

```gdscript
# 正确
func take_damage(amount: float, source: Node2D) -> void:
    current_health -= amount

# 错误 - 缺少类型标注
func take_damage(amount, source):
    current_health -= amount
```

### 注释规范

```gdscript
# 单行注释用 #，与代码之间留一个空格
var speed: float = 200.0

## 双井号用于文档注释（会出现在编辑器提示中）
## 移动速度，单位像素/秒
@export var move_speed: float = 200.0
```

### 信号规范

信号名使用过去时或名词短语：

```gdscript
# 正确
signal health_changed(new_health: float)
signal enemy_died(enemy: Node2D)
signal room_cleared

# 错误
signal change_health(amount)
signal onEnemyDie
```

### 场景组织规范

- 每个独立实体（玩家、敌人、房间、物品）是独立的 .tscn 场景
- 脚本放在 `scripts/` 目录，不与场景混合
- 使用组合优于继承：通过添加子节点和附加脚本实现功能

```gdscript
# 玩家场景节点结构示例:
# CharacterBody2D (player_controller.gd)
#   ├── Sprite2D
#   ├── CollisionShape2D
#   ├── Hitbox (Area2D + hitbox.gd)
#   ├── Hurtbox (Area2D + hurtbox.gd)
#   └── StateMachine (state_machine.gd)
```

### Git 提交规范

提交消息格式：

```
<type>: <简短描述>

<可选详细说明>
```

类型 (type):

| 类型 | 用途 |
|---|---|
| `feat` | 新功能 |
| `fix` | Bug 修复 |
| `refactor` | 重构（不改变行为） |
| `docs` | 文档更新 |
| `style` | 代码风格调整 |
| `asset` | 美术/音效资源 |
| `scene` | 场景文件变更 |
| `chore` | 构建/配置/工具 |

示例:
```
feat: add player dash ability with cooldown
fix: fix enemy not taking damage from projectiles
scene: add hero select screen layout
```

### 文件大小指南

- 单个脚本不超过 300 行，超过时考虑拆分为组合组件
- 状态机每个状态文件控制在 50-100 行
- Autoload 单例保持在 200 行以内
