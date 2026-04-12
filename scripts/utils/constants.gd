# scripts/utils/constants.gd
# 全局常量和枚举定义

class_name GameConstants

## 游戏版本
const GAME_VERSION: String = "0.1.0"

## 分辨率
const VIEWPORT_WIDTH: int = 640
const VIEWPORT_HEIGHT: int = 360

## 物理层
const LAYER_PLAYER: int = 1
const LAYER_ENEMIES: int = 2
const LAYER_ENVIRONMENT: int = 3
const LAYER_PLAYER_PROJECTILES: int = 4
const LAYER_ENEMY_PROJECTILES: int = 5
const LAYER_ITEMS: int = 6
const LAYER_TRIGGERS: int = 7

## 渲染层
const RENDER_BACKGROUND: int = 1
const RENDER_TILES: int = 2
const RENDER_ITEMS: int = 3
const RENDER_CHARACTERS: int = 4
const RENDER_EFFECTS: int = 5
const RENDER_FOREGROUND: int = 6
const RENDER_UI: int = 7

## 英雄 ID
enum HeroID {
	SONG_JIANG,
	LIN_CHONG,
	LU_ZHI_SHEN,
	WU_SONG,
}

## 敌人类型
enum EnemyType {
	BANDIT,
	GUARD,
	BOSS_GAO_QIU,
}

## 武器类型
enum WeaponType {
	SWORD,
	SPEAR,
	STAFF,
	BOW,
}

## 稀有度
enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY,
}

## 战斗常量
const MAX_HEALTH: float = 100.0
const DEFAULT_ATTACK: float = 10.0
const DEFAULT_SPEED: float = 200.0
const DEFAULT_DASH_SPEED: float = 500.0
const DASH_DURATION: float = 0.2
const DASH_COOLDOWN: float = 1.0
const INVINCIBILITY_DURATION: float = 0.5
const HITSTOP_DURATION: float = 0.05

## Roguelike 常量
const ROOMS_PER_FLOOR: int = 5
const MAX_FLOOR: int = 10
const UPGRADE_CHOICES: int = 3
