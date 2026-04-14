# scripts/utils/tileset_generator.gd
# 程序化生成 TileSet 资源：地板砖、墙壁砖、门框砖。

class_name TilesetGenerator


## 生成地牢 TileSet
static func generate_dungeon_tileset() -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(16, 16)
	ts.resource_name = "DungeonTileSet"

	# --- 地板图集 ---
	var floor_atlas: TileSetAtlasSource = _create_atlas_source(_generate_floor_texture(), "floors")
	ts.add_source(floor_atlas)

	# --- 墙壁图集 ---
	var wall_atlas: TileSetAtlasSource = _create_atlas_source(_generate_wall_texture(), "walls")
	ts.add_source(wall_atlas)

	# --- 门框图集 ---
	var door_atlas: TileSetAtlasSource = _create_atlas_source(_generate_door_texture(), "doors")
	ts.add_source(door_atlas)

	# --- 装饰图集 ---
	var deco_atlas: TileSetAtlasSource = _create_atlas_source(_generate_deco_texture(), "deco")
	ts.add_source(deco_atlas)

	return ts


## 创建 Atlas Source 并定义 tile
static func _create_atlas_source(texture: ImageTexture, prefix: String) -> TileSetAtlasSource:
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(16, 16)
	# 4 列 x 4 行 = 16 个 tile
	source.columns = 4
	source.rows = 4

	# 为每个 tile 创建 shape（墙壁需要物理碰撞）
	for y: int in range(4):
		for x: int in range(4):
			var tile_id: int = y * 4 + x
			source.create_tile(Vector2i(x, y))

	return source


## 生成地板纹理图集 (64x64 = 4x4 tiles, 每个 16x16)
static func _generate_floor_texture() -> ImageTexture:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Tile 0: 石砖地板
	_draw_stone_floor(img, 0, 0, Color(0.25, 0.24, 0.28), Color(0.18, 0.17, 0.20))
	# Tile 1: 石砖变体（稍亮）
	_draw_stone_floor(img, 16, 0, Color(0.28, 0.27, 0.31), Color(0.20, 0.19, 0.22))
	# Tile 2: 裂纹地板
	_draw_stone_floor(img, 32, 0, Color(0.25, 0.24, 0.28), Color(0.18, 0.17, 0.20))
	_draw_crack(img, 36, 6)
	# Tile 3: 血迹地板
	_draw_stone_floor(img, 48, 0, Color(0.25, 0.24, 0.28), Color(0.18, 0.17, 0.20))
	_draw_blood_stain(img, 52, 4)

	# Tile 4: 暗红石砖 (arena)
	_draw_stone_floor(img, 0, 16, Color(0.28, 0.20, 0.20), Color(0.20, 0.15, 0.15))
	# Tile 5: 深色石砖 (narrow)
	_draw_stone_floor(img, 16, 16, Color(0.20, 0.22, 0.26), Color(0.15, 0.16, 0.19))

	var tex := ImageTexture.create_from_image(img)
	return tex


## 生成墙壁纹理图集
static func _generate_wall_texture() -> ImageTexture:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	var wall_color: Color = Color(0.35, 0.30, 0.25)
	var wall_dark: Color = Color(0.25, 0.20, 0.18)
	var mortar: Color = Color(0.18, 0.14, 0.12)

	# Tile 0: 上墙
	_draw_wall(img, 0, 0, wall_color, wall_dark, mortar)
	# Tile 1: 下墙
	_draw_wall(img, 16, 0, wall_color, wall_dark, mortar)
	# Tile 2: 左墙
	_draw_wall(img, 32, 0, wall_color, wall_dark, mortar)
	# Tile 3: 右墙
	_draw_wall(img, 48, 0, wall_color, wall_dark, mortar)
	# Tile 4: 左上角
	_draw_wall(img, 0, 16, wall_color, wall_dark, mortar)
	# Tile 5: 右上角
	_draw_wall(img, 16, 16, wall_color, wall_dark, mortar)
	# Tile 6: 左下角
	_draw_wall(img, 32, 16, wall_color, wall_dark, mortar)
	# Tile 7: 右下角
	_draw_wall(img, 48, 16, wall_color, wall_dark, mortar)
	# Tile 8: 柱子
	_draw_pillar(img, 0, 32, wall_color, wall_dark)

	var tex := ImageTexture.create_from_image(img)
	return tex


## 生成门框纹理图集
static func _generate_door_texture() -> ImageTexture:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Tile 0: 门框左
	_fill_tile(img, 0, 0, Color(0.45, 0.35, 0.20))
	# Tile 1: 门框右
	_fill_tile(img, 16, 0, Color(0.45, 0.35, 0.20))
	# Tile 2: 关闭的门 (棕色木板)
	_draw_wood_door(img, 32, 0)
	# Tile 3: 打开的门 (黑色通道)
	_fill_tile(img, 48, 0, Color(0.06, 0.06, 0.10))

	var tex := ImageTexture.create_from_image(img)
	return tex


## 生成装饰纹理图集
static func _generate_deco_texture() -> ImageTexture:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# Tile 0: 中心圆标记 (arena)
	_draw_center_mark(img, 0, 0)
	# Tile 1: 柱子底座
	_fill_tile(img, 16, 0, Color(0.30, 0.26, 0.22))

	var tex := ImageTexture.create_from_image(img)
	return tex


## --- 绘制辅助函数 --- ##

## 绘制石砖地板 tile
static func _draw_stone_floor(img: Image, ox: int, oy: int, stone: Color, mortar: Color) -> void:
	# 填充灰浆底色
	_fill_rect_img(img, ox, oy, 16, 16, mortar)
	# 画砖块
	_fill_rect_img(img, ox + 1, oy + 1, 6, 6, stone)
	_fill_rect_img(img, ox + 9, oy + 1, 6, 6, stone)
	_fill_rect_img(img, ox + 1, oy + 9, 6, 6, stone)
	_fill_rect_img(img, ox + 9, oy + 9, 6, 6, stone)


## 绘制裂纹
static func _draw_crack(img: Image, ox: int, oy: int) -> void:
	var crack_color: Color = Color(0.12, 0.11, 0.14)
	for v: Vector2i in [
		Vector2i(0, 0), Vector2i(1, 1), Vector2i(2, 1),
		Vector2i(3, 2), Vector2i(4, 3), Vector2i(5, 2),
		Vector2i(6, 1),
	]:
		if ox + v.x < img.get_width() and oy + v.y < img.get_height():
			img.set_pixel(ox + v.x, oy + v.y, crack_color)


## 绘制血迹
static func _draw_blood_stain(img: Image, ox: int, oy: int) -> void:
	var blood: Color = Color(0.45, 0.12, 0.10, 0.6)
	for v: Vector2i in [
		Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2),
		Vector2i(2, 1), Vector2i(2, 2), Vector2i(3, 2),
	]:
		if ox + v.x < img.get_width() and oy + v.y < img.get_height():
			img.set_pixel(ox + v.x, oy + v.y, blood)


## 绘制墙壁 tile
static func _draw_wall(img: Image, ox: int, oy: int, wall: Color, dark: Color, mortar: Color) -> void:
	_fill_rect_img(img, ox, oy, 16, 16, mortar)
	# 砖块图案
	for row: int in range(2):
		var offset: int = 4 if row % 2 == 1 else 0
		for col: int in range(2):
			var bx: int = ox + col * 8 + offset
			var by: int = oy + row * 8
			_fill_rect_img(img, bx, by, 7, 7, wall)
			# 高光
			_fill_rect_img(img, bx, by, 7, 1, dark)


## 绘制柱子
static func _draw_pillar(img: Image, ox: int, oy: int, wall: Color, dark: Color) -> void:
	_fill_rect_img(img, ox + 2, oy, 12, 16, wall)
	_fill_rect_img(img, ox + 2, oy, 12, 2, dark)
	_fill_rect_img(img, ox + 2, oy + 14, 12, 2, dark)


## 绘制木门
static func _draw_wood_door(img: Image, ox: int, oy: int) -> void:
	var wood: Color = Color(0.45, 0.32, 0.18)
	var dark_wood: Color = Color(0.35, 0.24, 0.12)
	_fill_rect_img(img, ox, oy, 16, 16, wood)
	# 木纹
	_fill_rect_img(img, ox, oy + 4, 16, 1, dark_wood)
	_fill_rect_img(img, ox, oy + 8, 16, 1, dark_wood)
	_fill_rect_img(img, ox, oy + 12, 16, 1, dark_wood)
	# 门把手
	img.set_pixel(ox + 12, oy + 8, Color(0.7, 0.6, 0.3))


## 绘制中心标记
static func _draw_center_mark(img: Image, ox: int, oy: int) -> void:
	var mark_color: Color = Color(0.30, 0.22, 0.22, 0.5)
	_fill_rect_img(img, ox + 4, oy + 4, 8, 8, mark_color)
	# 四角
	img.set_pixel(ox + 6, oy + 4, mark_color)
	img.set_pixel(ox + 9, oy + 4, mark_color)
	img.set_pixel(ox + 6, oy + 11, mark_color)
	img.set_pixel(ox + 9, oy + 11, mark_color)


## 填充整个 tile
static func _fill_tile(img: Image, ox: int, oy: int, color: Color) -> void:
	_fill_rect_img(img, ox, oy, 16, 16, color)


## 在 Image 上填充矩形区域
static func _fill_rect_img(img: Image, x: int, y: int, w: int, h: int, color: Color) -> void:
	for py: int in range(y, y + h):
		for px: int in range(x, x + w):
			if px >= 0 and px < img.get_width() and py >= 0 and py < img.get_height():
				img.set_pixel(px, py, color)
