# 水浒传 - 像素风肉鸽打斗游戏

A Water Margin themed pixel art roguelike fighting game built with Godot 4.

## 项目简介

水浒传主题的像素风 Roguelike 动作游戏。玩家从水浒 108 将中选择英雄，在程序化生成的地牢房间中战斗，击败敌人获取升级和装备，挑战层层关卡的最终 Boss。

### 核心特性

- **英雄选择** - 水浒 108 将，每位英雄拥有独特属性和技能
- **Roguelike 回合** - 每次游戏随机生成房间、敌人、奖励
- **像素风美术** - 640x360 内部分辨率，清晰的像素渲染
- **动作战斗** - 攻击、冲刺、击退、无敌帧等动作游戏手感

## 安装与运行

### 前置条件

- [Godot 4.6+](https://godotengine.org/download) (Mono 版本可选)
- Git

### 快速开始

```bash
# 克隆仓库
git clone https://github.com/wkr712/shuihu.git
cd shuihu

# 用 Godot 编辑器打开项目
# 方法1: 命令行启动
godot --path .

# 方法2: 在 Godot 编辑器中扫描并打开项目文件夹
```

### 操作方式

| 操作 | 按键 |
|---|---|
| 移动 | WASD / 方向键 |
| 攻击 | J |
| 冲刺 | K |
| 交互 | E |
| 暂停 | ESC |

## 项目结构

```
shuihu/
├── project.godot       # 项目配置
├── CLAUDE.md           # AI 开发指引
├── docs/
│   └── CONVENTIONS.md  # 代码规范
├── scenes/             # Godot 场景 (.tscn)
│   ├── main/           # 主菜单等入口场景
│   ├── game/           # 游戏世界和房间场景
│   ├── characters/     # 玩家和英雄场景
│   ├── enemies/        # 敌人场景
│   ├── combat/         # Hitbox/Hurtbox 战斗组件
│   ├── items/          # 物品拾取场景
│   ├── levels/         # 房间模板和 Tileset
│   ├── ui/             # HUD、菜单等 UI 场景
│   └── transitions/    # 场景过渡效果
├── scripts/            # GDScript 脚本
│   ├── autoload/       # 全局单例 (GameManager 等)
│   ├── characters/     # 角色控制和状态机
│   ├── enemies/        # 敌人 AI 和状态
│   ├── combat/         # 战斗系统
│   ├── roguelike/      # Roguelike 系统 (房间生成、升级)
│   ├── items/          # 物品和武器
│   ├── ui/             # UI 脚本
│   └── utils/          # 常量和工具函数
├── assets/             # 美术、音效、字体资源
└── resources/          # .tres 数据资源 (角色属性、物品数据)
```

## 技术细节

- **引擎**: Godot 4.6.2
- **渲染**: 2D, 像素完美 (Nearest 过滤, 整数缩放)
- **分辨率**: 640x360 (2x 缩放至 1280x720)
- **语言**: GDScript 4

## 许可

MIT License
