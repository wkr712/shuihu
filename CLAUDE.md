# CLAUDE.md - 水浒传像素风肉鸽打斗游戏

## 项目概述

水浒传主题的像素风 Roguelike 动作游戏，基于 Godot 4.6.2 开发。玩家从水浒 108 将中选择英雄，在程序化生成的地牢中战斗，收集升级和装备，挑战 Boss。

## 技术栈

- **引擎**: Godot 4.6.2 (Mono/C# 版本，当前使用 GDScript)
- **渲染**: 2D 像素风格 (640x360 内部分辨率, Nearest 纹理过滤)
- **语言**: GDScript 4 (未来性能关键模块可用 C#)

## 架构

### Autoload 单例

| 单例 | 路径 | 职责 |
|---|---|---|
| GameManager | `scripts/autoload/game_manager.gd` | 游戏状态、回合追踪、暂停管理 |
| AudioManager | `scripts/autoload/audio_manager.gd` | 音乐淡入淡出、SFX 对象池、总线管理 |
| SceneManager | `scripts/autoload/scene_manager.gd` | 场景切换过渡效果 |
| EventBus | `scripts/autoload/event_bus.gd` | 全局事件订阅/发布 |

### 核心模式

- **状态机 (FSM)**: 角色和敌人使用 `state_machine.gd`，每个状态是独立脚本
- **Hitbox/Hurtbox**: 战斗使用 Area2D 碰撞检测，分层管理 (player/enemies/projectiles)
- **数据驱动**: 英雄/敌人/物品属性通过 `.tres` 资源文件定义，运行时加载
- **事件总线**: 系统间通过 `EventBus` 解耦通信

### 游戏流程

主菜单 → 英雄选择 → 开始回合 → 房间生成 → 战斗 → 清房奖励(升级选择) → 下一房间/楼层 → 死亡/Boss击败 → 回合总结

## 目录约定

- `scenes/` - .tscn 场景文件，按功能分子目录
- `scripts/` - .gd 脚本，与场景对应但不嵌套在场景内
- `assets/` - 美术、音效、字体等原始资源
- `resources/` - .tres 数据资源文件
- `docs/` - 开发文档

## 物理层分配

1. player - 玩家碰撞
2. enemies - 敌人碰撞
3. environment - 地形障碍
4. player_projectiles - 玩家投射物/攻击判定
5. enemy_projectiles - 敌人投射物/攻击判定
6. items - 可拾取物品
7. triggers - 触发器区域

## 输入映射

| 动作 | 按键 |
|---|---|
| move_left | A / Left |
| move_right | D / Right |
| move_up | W / Up |
| move_down | S / Down |
| attack | J |
| dash | K |
| interact | E |
| pause | Escape |

## 开发注意事项

- 所有纹理使用 Nearest 过滤，不要在导入设置中改为 Linear
- 角色精灵分辨率建议 16x16 或 32x32，保持像素风一致性
- 新英雄只需创建 .tres 资源文件 + 精灵资源，无需改代码
- 状态机中每个状态必须有 `enter()`, `exit()`, `physics_update(delta)` 方法
