extends Node2D

@export var TiledScene : PackedScene
@export var TileSize : float

@export var TileStart : Node2D
@export var TileEnd : Node2D
var tiles : Array[Node2D] = []

@export var AnimSpeed : float
var nextAnimUpdate = 0.
@export var DoAnim = true
@export var ReverseAnim = false

var lastEnd = Vector2()

func _process(delta):
	# Doesnt handle endpoint moving up
	if TileEnd.global_position != lastEnd:
		var tileCount = abs(TileEnd.global_position.y - TileStart.global_position.y) / TileSize
		if tileCount - int(tileCount) != 0:
			tileCount = int(tileCount) + 1

		for i in range(tiles.size(), tileCount):
			var t = TiledScene.instantiate()
			add_child(t)
			t.global_position = Vector2(global_position.x, TileStart.global_position.y + i * TileSize)
			tiles.append(t)

		lastEnd = TileEnd.global_position

		UpdateAnim(nextAnimUpdate)

	elif DoAnim and tiles.size() > 0:
		UpdateAnim(delta)

func UpdateAnim(delta):
	nextAnimUpdate -= delta
	if nextAnimUpdate <= 0:
		nextAnimUpdate = AnimSpeed

		var frames = tiles[0].vframes
		var a = tiles[0].frame - 1 if ReverseAnim else tiles[0].frame + 1
		if a < 0: a = frames - 1

		for t in tiles:
			if a >= frames: a = 0
			t.frame = a
			a += 1
