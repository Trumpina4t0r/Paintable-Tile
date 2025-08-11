##Used to paint and erase part of the grid of you world
extends Node2D

#attach this script onto a Node2D under your original Tile Map Layer
@onready var _tileMapLayer: TileMapLayer = get_parent()

##how big is the grid size gonna be on the x axie
@export var GridSizeX = 128
##how big is the grid size gonna be on the y axie
@export var GridSizeY = 128
##create a second TileMapLayer and add your brush texture onlysupport one texture with atlas coordinate of (0,0) Note: Make sur your original tile map and the Brush Layer map are set at the same world coordinate
@export var BrushHighlight: TileMapLayer
#used to store the original grid before any change were made
var originalGridDic: Dictionary
#used to store which tile are painted
var paintedDic: Dictionary

#assign a value to these variables maybe with a UI Button where you can choose what to paint
var tileAtlasCoordinateToPaint:= Vector2i(0,0)
var tileSetAtlasIDToPaint:= 0

#assign the value of these variable maybe with a UI Button where you can choose to paint or erase
var IsPainting: bool = false
var IsErasing: bool = false

var mousePressed: bool

var brush_size := 1  # 1 means 1x1, 2 means 2x2, etc.

#region [Debug Variables]
##debug only please deactivate when not debugin
@export_category("Debug")
##if this is false no value below it will work 
@export var enableDebugGrid: bool
##if true it will only fill the tiles that are not painted in the editor
@export var fillUnPaintedTile: bool
##the ID of your debug atlas tile set
@export var debugAtlasID: int = 1
##here you can assign the atlas coordinate of your debug tile 
@export var debugAtlasCoord:= Vector2i(0,0)
#endregion
func _ready() -> void:
	var directions = [
		Vector2i(1, 1),   # SE
		Vector2i(-1, 1),  # SW
		Vector2i(1, -1),  # NE
		Vector2i(-1, -1)  # NW
	]
	for dir in directions:
		CreateGrid(dir)

	#on ready stop the process function it doesnt need to tick right away
	set_process(false)
	
	bindingEvent()
		
func CreateGrid(direction: Vector2i) -> void:
#create an empty grid behind the one you create
	for x in GridSizeX:
		for y in GridSizeY:
			#assign the tile location
			var pos = Vector2i(x * direction.x, y * direction.y)
			#assign the tileSetID
			var tileSetID = _tileMapLayer.get_cell_source_id(pos)
			#assign the atlasCoordinate
			var atlasCoordinate = _tileMapLayer.get_cell_atlas_coords(pos)
			originalGridDic[pos] = {"atlasSetID": tileSetID, "atlasCoordinate": atlasCoordinate}

			#only use to visualize the grid should not be used in actual game
			if enableDebugGrid:
				if fillUnPaintedTile:
					#if a tile is unpainted in the editor it will create a debug tile to visualize
					if tileSetID == -1:
						_tileMapLayer.set_cell(pos,debugAtlasID,debugAtlasCoord)
				else:
					#will fill the entire grid with a debug tile
					_tileMapLayer.set_cell(pos,debugAtlasID,debugAtlasCoord)

func _process(delta: float) -> void:
	var local_mouse_pos = to_local(get_global_mouse_position())
	var tileUnderMouse = _tileMapLayer.local_to_map(local_mouse_pos)
	update_brush_highlight(tileUnderMouse)
	if mousePressed:
		paintBrush(tileUnderMouse)

#region [Painting Functionality]
func eraseTile(tile):
	if IsErasing:
		#in erase mode it find the original atlas data to reverse to what they were before painting
		#first check if it is a tile that has been painted and if it is on the paintable grid
		if paintedDic.has(tile):
			#store the value into variable
			var atlas_id = originalGridDic[tile]["atlasSetID"]
			var atlasCoordinate =  originalGridDic[tile]["atlasCoordinate"]
			#then set cell with the value above
			_tileMapLayer.set_cell(tile, atlas_id, atlasCoordinate)
			#and finally remove it from the paintedDic because it is no more painted
			paintedDic.erase(tile)

func paintTile(tile: Vector2i) -> void:
	if IsPainting:
		if originalGridDic.has(tile):
			_tileMapLayer.set_cell(tile, tileSetAtlasIDToPaint, tileAtlasCoordinateToPaint)
			paintedDic[tile] = {
				"atlas_coord": tileAtlasCoordinateToPaint,
				"tileset_id": tileSetAtlasIDToPaint
			}

func paintBrush(tile_center: Vector2i) -> void:
	var half_size := brush_size / 2
	for x_offset in range(-half_size, half_size + (brush_size % 2)):
		for y_offset in range(-half_size, half_size + (brush_size % 2)):
			var tile := tile_center + Vector2i(x_offset, y_offset)
			if IsPainting:
				paintTile(tile)
			if IsErasing:
				eraseTile(tile)

func update_brush_highlight(tile_center: Vector2i) -> void:
	#create and transparent brush to visualize where the paint is going
	#it has the same functionality has the paint brush
	BrushHighlight.clear()
	var half_size := brush_size / 2
	for x_offset in range(-half_size, half_size + (brush_size % 2)):
		for y_offset in range(-half_size, half_size + (brush_size % 2)):
			var tile := tile_center + Vector2i(x_offset, y_offset)
			BrushHighlight.set_cell(tile, 0,Vector2i(0,0))
#endregion


#region [Input]
func _input(event: InputEvent) -> void:
	if get_viewport().gui_get_hovered_control():
		mousePressed = false
		return
	#detect when the left mouse button is pressed and released
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mousePressed = true
		else:
			mousePressed = false

	#alternate between is painting and is erasing mode assign this part to a UI Button ?
	#maybe with a signal ?
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			IsErasing = !IsErasing
			IsPainting = !IsPainting
#endregion

#region Signals Connection
func bindingEvent():
	SignalBus.onOpenPaintMode.connect(activatePaintMode)
	SignalBus.onPaintModeChange.connect(changePaintMode)
	SignalBus.onBrushSizeChanged.connect(changeBrushSize)
	SignalBus.onNewMaterialSelected.connect(ChangeMaterial)

#this open the Paint Panel and activate the Script Process function
func activatePaintMode(activate: bool):
	if activate:
		set_process(true)
		IsPainting = true
	else:
		set_process(false)
		IsPainting = false
		IsErasing = false
		BrushHighlight.clear()

func changePaintMode(willPaint):
	if willPaint:
		IsPainting = true
		IsErasing = false
	else:
		IsPainting = false
		IsErasing = true

func changeBrushSize(value: float):
	brush_size = value

func ChangeMaterial(coordinate: Vector2i):
	tileAtlasCoordinateToPaint = coordinate
#endregion
