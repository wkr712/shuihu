# scripts/utils/pixel_art_generator.gd
# 程序化像素精灵生成器：用像素数组定义角色外观，生成 ImageTexture 和 SpriteFrames。

class_name PixelArtGenerator


## 颜色调色板 —— 字符映射到颜色
const PALETTE: Dictionary = {
	".": Color.TRANSPARENT,
	"B": Color(0.30, 0.65, 0.95),   # 蓝色（宋江）
	"b": Color(0.20, 0.45, 0.75),   # 深蓝
	"G": Color(0.25, 0.78, 0.35),   # 绿色（林冲）
	"g": Color(0.15, 0.55, 0.22),   # 深绿
	"O": Color(0.92, 0.62, 0.12),   # 橙色（鲁智深）
	"o": Color(0.72, 0.45, 0.08),   # 深橙
	"R": Color(0.88, 0.22, 0.18),   # 红色（武松）
	"r": Color(0.62, 0.14, 0.12),   # 深红
	"P": Color(0.52, 0.22, 0.58),   # 紫色（护卫）
	"p": Color(0.36, 0.14, 0.40),   # 深紫
	"S": Color(0.95, 0.78, 0.62),   # 肤色
	"s": Color(0.82, 0.65, 0.50),   # 深肤
	"K": Color(0.12, 0.10, 0.10),   # 黑色
	"D": Color(0.28, 0.22, 0.18),   # 深棕（靴子）
	"W": Color(1.00, 1.00, 1.00),   # 白色
	"Y": Color(0.95, 0.82, 0.28),   # 黄色/金色
	"T": Color(0.55, 0.42, 0.32),   # 棕色
	"L": Color(0.68, 0.58, 0.48),   # 浅棕
	"M": Color(0.78, 0.48, 0.38),   # 嘴/红
	"C": Color(0.55, 0.55, 0.60),   # 银灰（铠甲）
	"c": Color(0.38, 0.38, 0.42),   # 深银灰
}


## 角色基础精灵定义 (16 宽 x 18 高)
## 每个字符对应 PALETTE 中的一个颜色，'.' 为透明

const SONG_JIANG: PackedStringArray = [
	"......BB.......",  # 0  帽顶
	".....BBBB......",  # 1  帽子
	"....BBBBBB.....",  # 2  帽檐
	"....SSSSSS.....",  # 3  脸上部
	"....S.KK.S.....",  # 4  眼睛
	"....SSSSSS.....",  # 5  脸下部
	"....S.MM.S.....",  # 6  嘴
	"...BBBBBBB.....",  # 7  铠甲肩
	"..BBbBBBbBB....",  # 8  铠甲+臂
	"...BBYYYBB.....",  # 9  腰带
	"...BBBBBBB.....",  # 10 长袍
	"....BBBBB......",  # 11 长袍
	"....BBBBB......",  # 12 长袍下
	"....BB.BB......",  # 13 腿
	"....BB.BB......",  # 14 腿
	"...DD...DD.....",  # 15 靴子
	"................",  # 16
	"................",  # 17
]

const LIN_CHONG: PackedStringArray = [
	"......GG.......",  # 0  头巾
	".....GGGG......",  # 1  头巾
	"....SSSSSS.....",  # 2  脸上
	"....S.KK.S.....",  # 3  眼睛
	"....SSSSSS.....",  # 4  脸下
	"....S.MM.S.....",  # 5  嘴
	"...GGGGGGG.....",  # 6  战袍肩
	"..GGgGGGgGG....",  # 7  战袍+臂
	"...GGYYYGG.....",  # 8  腰带
	"...GGGGGGG.....",  # 9  战袍
	"....GGGGG......",  # 10 战袍
	"....GGGGG......",  # 11 战袍下
	"....GG.GG......",  # 12 腿
	"....GG.GG......",  # 13 腿
	"...DD...DD.....",  # 14 靴子
	"................",  # 15
	"................",  # 16
	"................",  # 17
]

const LU_ZHI_SHEN: PackedStringArray = [
	"....SSSSSS.....",  # 0  光头
	"...SSSSSSSS....",  # 1  头
	"....S.KK.S.....",  # 2  眼睛
	"....SSSSSS.....",  # 3  脸
	"....S.MM.S.....",  # 4  嘴
	"...OOOOOOO.....",  # 5  僧袍肩（宽）
	"..OOoOOOoOO....",  # 6  僧袍臂（宽）
	"..OOoOOOoOO....",  # 7  僧袍
	"...OOYYYOO.....",  # 8  腰带
	"...OOOOOOO.....",  # 9  僧袍
	"....OOOOO......",  # 10 僧袍
	"....OOOOO......",  # 11 僧袍下
	"....OO.OO......",  # 12 腿
	"....OO.OO......",  # 13 腿
	"...DD...DD.....",  # 14 靴子
	"................",  # 15
	"................",  # 16
	"................",  # 17
]

const WU_SONG: PackedStringArray = [
	"......RR.......",  # 0  头带
	".....RRRR......",  # 1  头带
	"....SSSSSS.....",  # 2  脸上
	"....S.KK.S.....",  # 3  眼睛
	"....SSSSSS.....",  # 4  脸下
	"....S.MM.S.....",  # 5  嘴
	"....SSSSSS.....",  # 6  脖子
	"...RRRRRRR.....",  # 7  红色背心
	"..RRrRRRrRR....",  # 8  背心+臂
	"...SSSSSSS.....",  # 9  腰
	"....SSSSS......",  # 10 裤
	"....SSSSS......",  # 11 裤
	"....SS.SS......",  # 12 腿
	"....SS.SS......",  # 13 腿
	"...DD...DD.....",  # 14 靴子
	"................",  # 15
	"................",  # 16
	"................",  # 17
]

const BANDIT: PackedStringArray = [
	"................",  # 0
	"......rr.......",  # 1  头巾
	".....rrrr......",  # 2  头巾
	"....SSSSSS.....",  # 3  脸上
	"....S.KK.S.....",  # 4  眼睛（凶狠）
	"....SSSSSS.....",  # 5  脸下
	"....S.MM.S.....",  # 6  嘴
	"....TTTTTT.....",  # 7  破衣
	"...TT.TT.TT....",  # 8  破衣+臂
	"....TTTTTT.....",  # 9  破衣
	"....TTTTTT.....",  # 10 破衣
	".....TTT.......",  # 11 破衣下
	".....TT.TT.....",  # 12 腿
	".....TT.TT.....",  # 13 腿
	"....DD..DD.....",  # 14 草鞋
	"................",  # 15
	"................",  # 16
	"................",  # 17
]

const GUARD: PackedStringArray = [
	".....PPPP......",  # 0  头盔顶
	"....PPPPPP.....",  # 1  头盔
	"...PPPPPPPP....",  # 2  头盔檐
	"....SSSSSS.....",  # 3  脸
	"....S.KK.S.....",  # 4  眼睛
	"....SSSSSS.....",  # 5  脸
	"....S.MM.S.....",  # 6  嘴
	"...CCCCCCc.....",  # 7  铠甲肩
	"..CC.CCC.CC....",  # 8  铠甲+臂
	"...CCYYYCC.....",  # 9  腰带
	"...CCCCCCC.....",  # 10 铠甲下
	"....CCCCC......",  # 11 裙甲
	"....CC.CC......",  # 12 腿
	"....CC.CC......",  # 13 腿
	"...DD...DD.....",  # 14 靴子
	"................",  # 15
	"................",  # 16
	"................",  # 17
]


## 从字符串数组生成 ImageTexture
static func generate_texture(pixel_data: PackedStringArray, width: int = 16, height: int = 18) -> ImageTexture:
	var img := Image.create(width, height, false, Image.FORMAT_RGBA8)
	for y: int in range(mini(pixel_data.size(), height)):
		var row: String = pixel_data[y]
		for x: int in range(mini(row.length(), width)):
			var ch: String = row[x]
			if PALETTE.has(ch):
				img.set_pixel(x, y, PALETTE[ch])
			else:
				img.set_pixel(x, y, Color.TRANSPARENT)
	var tex := ImageTexture.create_from_image(img)
	return tex


## 整体上移 n 行（用于 idle 呼吸动画）
static func shift_rows_up(data: PackedStringArray, n: int, width: int = 16, height: int = 18) -> PackedStringArray:
	var result: PackedStringArray = []
	var empty: String = ".".repeat(width)
	# 前面补空行
	for i: int in range(n):
		result.append(empty)
	# 原始数据
	for i: int in range(data.size()):
		if result.size() < height:
			result.append(data[i])
	# 截断到 height
	while result.size() > height:
		result.pop_back()
	return result


## 替换底部行（用于 walk 腿部动画）
static func replace_rows(data: PackedStringArray, start_row: int, new_rows: PackedStringArray) -> PackedStringArray:
	var result: PackedStringArray = []
	for i: int in range(data.size()):
		var row_idx: int = i - start_row
		if row_idx >= 0 and row_idx < new_rows.size():
			result.append(new_rows[row_idx])
		else:
			result.append(data[i])
	return result


## 全白色版本（hurt 帧）
static func whiten(data: PackedStringArray, width: int = 16) -> PackedStringArray:
	var result: PackedStringArray = []
	for row: String in data:
		var new_row: String = ""
		for x: int in range(mini(row.length(), width)):
			if row[x] == ".":
				new_row += "."
			else:
				new_row += "W"
		result.append(new_row)
	return result


## 生成角色 SpriteFrames（含 idle/walk/attack/hurt 动画）
static func generate_sprite_frames(character_id: String) -> SpriteFrames:
	var base: PackedStringArray = _get_base(character_id)
	if base.is_empty():
		return null

	var frames := SpriteFrames.new()
	frames.remove_animation("default")

	var w: int = 16
	var h: int = base.size()

	# --- idle: 2 帧（微微呼吸） ---
	frames.add_animation("idle")
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", 3.0)
	frames.add_frame("idle", generate_texture(base, w, h))
	var idle_2: PackedStringArray = shift_rows_up(base, 1, w, h)
	# 还原底部为空行
	frames.add_frame("idle", generate_texture(idle_2, w, h))

	# --- walk: 4 帧（腿部交替） ---
	frames.add_animation("walk")
	frames.set_animation_loop("walk", true)
	frames.set_animation_speed("walk", 6.0)
	var walk_legs_1: PackedStringArray = _make_walk_frame(base, 0)
	var walk_legs_2: PackedStringArray = _make_walk_frame(base, 1)
	var walk_legs_3: PackedStringArray = _make_walk_frame(base, 2)
	var walk_legs_4: PackedStringArray = _make_walk_frame(base, 3)
	frames.add_frame("walk", generate_texture(walk_legs_1, w, h))
	frames.add_frame("walk", generate_texture(walk_legs_2, w, h))
	frames.add_frame("walk", generate_texture(walk_legs_3, w, h))
	frames.add_frame("walk", generate_texture(walk_legs_4, w, h))

	# --- attack: 3 帧（抬手→挥击→收招） ---
	frames.add_animation("attack")
	frames.set_animation_loop("attack", false)
	frames.set_animation_speed("attack", 8.0)
	var atk_1: PackedStringArray = _make_attack_frame(base, 0)
	var atk_2: PackedStringArray = _make_attack_frame(base, 1)
	var atk_3: PackedStringArray = _make_attack_frame(base, 2)
	frames.add_frame("attack", generate_texture(atk_1, w, h))
	frames.add_frame("attack", generate_texture(atk_2, w, h))
	frames.add_frame("attack", generate_texture(atk_3, w, h))

	# --- hurt: 1 帧（白色闪烁） ---
	frames.add_animation("hurt")
	frames.set_animation_loop("hurt", false)
	frames.set_animation_speed("hurt", 4.0)
	frames.add_frame("hurt", generate_texture(whiten(base, w), w, h))

	return frames


## 根据 character_id 返回基础精灵数据
static func _get_base(character_id: String) -> PackedStringArray:
	match character_id:
		"song_jiang":
			return SONG_JIANG
		"lin_chong":
			return LIN_CHONG
		"wu_song":
			return WU_SONG
		"lu_zhi_shen":
			return LU_ZHI_SHEN
		"bandit":
			return BANDIT
		"guard":
			return GUARD
		_:
			return PackedStringArray()


## 生成 walk 帧（修改腿部行）
## step 0: 左前右后, 1: 并拢, 2: 右前左后, 3: 并拢
static func _make_walk_frame(base: PackedStringArray, step: int) -> PackedStringArray:
	# 从 base 精灵获取腿部主色调字符
	var main_ch: String = _get_main_color(base)

	# 用角色颜色动态构建腿部行
	var leg_rows: PackedStringArray
	var lc: String = main_ch + main_ch  # 两个主色字符
	match step:
		0:
			leg_rows = PackedStringArray([
				"...." + lc + ".." + lc + ".....",
				"...DD....DD....",
			])
		1:
			leg_rows = PackedStringArray([
				"...." + lc + "." + lc + "......",
				"...DD...DD.....",
			])
		2:
			leg_rows = PackedStringArray([
				"...." + lc + ".." + lc + ".....",
				"....DD...DD....",
			])
		_:
			leg_rows = PackedStringArray([
				"...." + lc + "." + lc + "......",
				"...DD...DD.....",
			])

	# 替换腿部行（倒数第 5, 4 行，即 row 12, 13）
	var result: PackedStringArray = base.duplicate()
	var start_replace: int = result.size() - 5
	if start_replace < 0:
		start_replace = 0
	for i: int in range(leg_rows.size()):
		var idx: int = start_replace + i
		if idx < result.size():
			result[idx] = leg_rows[i]
	return result


## 生成 attack 帧（修改臂部行）
## phase 0: 抬手, 1: 挥击（手伸出）, 2: 收招（原样）
static func _make_attack_frame(base: PackedStringArray, phase: int) -> PackedStringArray:
	var result: PackedStringArray = base.duplicate()

	# 找到臂部行（通常是 row 8 附近有 ".BB." 模式）
	var arm_row: int = -1
	for i: int in range(result.size()):
		var row: String = result[i]
		# 检测是否有臂部特征（".." 开头的多字符色块）
		if row.find("..") >= 0 and row.find("..") < 4 and row.strip_edges().length() > 6:
			arm_row = i
			break

	if arm_row < 0:
		return result

	var original: String = result[arm_row]
	match phase:
		0:
			# 抬手：右侧臂部像素上移一行
			if arm_row > 0:
				var above: String = result[arm_row - 1]
				# 简化：在上方行添加一个臂部像素
				var chars: PackedStringArray = PackedStringArray()
				for c: int in range(above.length()):
					chars.append(above[c])
				var new_above: String = ""
				for c: int in range(chars.size()):
					new_above += chars[c]
				# 在右侧添加延伸
				if new_above.length() > 11:
					var ch: String = _get_main_color(result)
					new_above = new_above.substr(0, 11) + ch + ch + new_above.substr(13)
					result[arm_row - 1] = new_above
		1:
			# 挥击：臂部向右延伸
			var ch: String = _get_main_color(result)
			var row: String = original
			if row.length() > 12:
				# 在右侧添加攻击延伸像素
				row = row.substr(0, 12) + ch + ch + ch + row.substr(15)
				result[arm_row] = row
		2:
			# 收招：保持原样
			pass

	return result


## 获取角色主色调字符
static func _get_main_color(data: PackedStringArray) -> String:
	var counts: Dictionary = {}
	for row: String in data:
		for ch: String in row:
			if ch != "." and ch != "S" and ch != "s" and ch != "K" and ch != "D":
				counts[ch] = counts.get(ch, 0) + 1
	var best: String = "B"
	var best_count: int = 0
	for ch: String in counts:
		if counts[ch] > best_count:
			best = ch
			best_count = counts[ch]
	return best


## 生成升级图标纹理（16x16 简约图标）
static func generate_upgrade_icon(icon_type: String) -> ImageTexture:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	match icon_type:
		"health_up":
			# 红色十字
			_fill_rect(img, 6, 2, 4, 12, Color(0.9, 0.3, 0.3))
			_fill_rect(img, 2, 6, 12, 4, Color(0.9, 0.3, 0.3))
		"attack_up", "attack_big":
			# 剑图标
			_fill_rect(img, 7, 1, 2, 10, Color(0.8, 0.8, 0.85))
			_fill_rect(img, 5, 10, 6, 2, Color(0.6, 0.4, 0.2))
			_fill_rect(img, 4, 11, 8, 1, Color(0.6, 0.4, 0.2))
		"speed_up":
			# 闪电图标
			for v: Vector2i in [
				Vector2i(9, 1), Vector2i(8, 2), Vector2i(7, 3), Vector2i(6, 4),
				Vector2i(9, 4), Vector2i(8, 5), Vector2i(7, 6), Vector2i(6, 7),
				Vector2i(5, 8), Vector2i(6, 9), Vector2i(7, 10), Vector2i(8, 11),
				Vector2i(7, 5), Vector2i(6, 6), Vector2i(8, 7),
			]:
				if v.x < 16 and v.y < 16:
					img.set_pixel(v.x, v.y, Color(1.0, 0.9, 0.2))
		"heal_small":
			# 绿色药瓶
			_fill_rect(img, 6, 1, 4, 2, Color(0.6, 0.6, 0.6))
			_fill_rect(img, 5, 3, 6, 8, Color(0.3, 0.85, 0.4))
			_fill_rect(img, 6, 4, 2, 2, Color(0.5, 0.95, 0.5))
		"dash_charge_up":
			# 冲刺箭头
			_fill_rect(img, 2, 6, 8, 4, Color(0.3, 0.7, 1.0))
			for v: Vector2i in [
				Vector2i(10, 4), Vector2i(11, 5), Vector2i(12, 6),
				Vector2i(13, 7), Vector2i(12, 8), Vector2i(11, 9), Vector2i(10, 10),
			]:
				img.set_pixel(v.x, v.y, Color(0.3, 0.7, 1.0))
		"lifesteal":
			# 红色心+箭头
			_fill_rect(img, 3, 3, 3, 4, Color(0.9, 0.2, 0.3))
			_fill_rect(img, 8, 3, 3, 4, Color(0.9, 0.2, 0.3))
			_fill_rect(img, 2, 5, 10, 3, Color(0.9, 0.2, 0.3))
			_fill_rect(img, 3, 8, 8, 2, Color(0.9, 0.2, 0.3))
			_fill_rect(img, 4, 10, 6, 2, Color(0.9, 0.2, 0.3))
			_fill_rect(img, 5, 12, 4, 1, Color(0.9, 0.2, 0.3))
		"crit_chance":
			# 星星
			_fill_rect(img, 7, 2, 2, 4, Color(1.0, 0.85, 0.2))
			_fill_rect(img, 4, 5, 8, 2, Color(1.0, 0.85, 0.2))
			_fill_rect(img, 3, 7, 3, 2, Color(1.0, 0.85, 0.2))
			_fill_rect(img, 10, 7, 3, 2, Color(1.0, 0.85, 0.2))
			_fill_rect(img, 5, 9, 2, 4, Color(1.0, 0.85, 0.2))
			_fill_rect(img, 9, 9, 2, 4, Color(1.0, 0.85, 0.2))
		"armor_up":
			# 盾牌
			_fill_rect(img, 5, 2, 6, 2, Color(0.55, 0.55, 0.60))
			_fill_rect(img, 4, 4, 8, 4, Color(0.55, 0.55, 0.60))
			_fill_rect(img, 5, 8, 6, 2, Color(0.55, 0.55, 0.60))
			_fill_rect(img, 6, 10, 4, 2, Color(0.55, 0.55, 0.60))
			_fill_rect(img, 7, 12, 2, 1, Color(0.55, 0.55, 0.60))
		"vampiric_blade":
			# 紫色刀
			for v: Vector2i in [
				Vector2i(8, 2), Vector2i(9, 3), Vector2i(10, 4), Vector2i(11, 5),
				Vector2i(12, 6), Vector2i(13, 7),
			]:
				img.set_pixel(v.x, v.y, Color(0.55, 0.2, 0.6))
			_fill_rect(img, 5, 8, 6, 2, Color(0.4, 0.15, 0.4))
			_fill_rect(img, 4, 10, 8, 1, Color(0.4, 0.15, 0.4))

	var tex := ImageTexture.create_from_image(img)
	return tex


## 辅助：在 Image 上填充矩形
static func _fill_rect(img: Image, x: int, y: int, w: int, h: int, color: Color) -> void:
	for py: int in range(y, y + h):
		for px: int in range(x, x + w):
			if px >= 0 and px < img.get_width() and py >= 0 and py < img.get_height():
				img.set_pixel(px, py, color)
