extends TileMap

# -1 = empty cell
# 0 = mine
# 1-8 = number cell

const CELL_ROWS := 30
const CELL_COLUMNS := 16
const MINE_COUNT := 99

var cells : Array[int]
var surroundingCells : Array[int]
var offsetCoords : Vector2i
var gameEnded := false
var lastMove : Array[Vector2i]

func _ready() -> void:
	setUpBoard()


#Grid
func setUpBoard() -> void:
	for y in range(CELL_COLUMNS):
		for x in range(CELL_ROWS):
			set_cell(0, Vector2i(x, y), 0, Vector2i(0,0))
			cells.append(-1)

#mines
func setUpMines(avoid : Vector2i) -> void:
	for i in range(MINE_COUNT):
		cells[i] = 0
	cells.shuffle()
	while getSurroundingCell(avoid, 5).has(0):
		cells.shuffle()
	
	#numbered cells setup
	for y in range(CELL_COLUMNS):
		for x in range(CELL_ROWS):
			if not cells[getCellIndex(Vector2i(x, y))] == 0:
				var mineCount := 0
				for i in getSurroundingCell(Vector2i(x, y), 3):
					if i == 0:
						mineCount += 1
				if mineCount > 0:
					cells[getCellIndex(Vector2i(x, y))] = mineCount
		
		
		
#Reveal cells
func _input(event : InputEvent) -> void:
	if gameEnded == false:
		if event.is_action_pressed("reveal"):
			var cellAtmouse : Vector2i = local_to_map(get_local_mouse_position())
			lastMove = []
			if getAtlasCoords(cellAtmouse) != Vector2i(1, 0):
				if cells.has(0):
					lastMove.append(cellAtmouse)
					revealCell(cellAtmouse)
					
					#QOL: reveal surrounding cells
					if cells[getCellIndex((cellAtmouse))] >= 1:
						revealSurroundingCells(cellAtmouse, false)
					
					
					for i in lastMove:
						if cells[getCellIndex(i)] == 0:
							gameEnded = true
							revealAllMines(lastMove)
				else:
					setUpMines(cellAtmouse)
					revealCell(cellAtmouse)
		if event.is_action_pressed("flag"):
			var cellAtmouse : Vector2i = local_to_map(get_local_mouse_position())
			if getAtlasCoords(cellAtmouse) == Vector2i(0, 0):
				set_cell(0, cellAtmouse, 0, Vector2i(1, 0))
			elif getAtlasCoords(cellAtmouse) == Vector2i(1, 0):
				set_cell(0, cellAtmouse, 0, Vector2i(0,0))


#Cells when clicked
func revealCell(cellCoords : Vector2i) -> void:
	var cellIndex : int = getCellIndex(cellCoords)
	 
	var atlasCoords : Vector2i
	match cells[cellIndex]:
		-1: atlasCoords = Vector2i(3,0) #empty
		0: atlasCoords = Vector2i(0,3) #mine
		1: atlasCoords = Vector2i(0,1) #numbered cell
		2: atlasCoords = Vector2i(1,1)
		3: atlasCoords = Vector2i(2,1)
		4: atlasCoords = Vector2i(3,1)
		5: atlasCoords = Vector2i(0,2)
		6: atlasCoords = Vector2i(1,2)
		7: atlasCoords = Vector2i(2,2)
		8: atlasCoords = Vector2i(3,2)
	set_cell(0, cellCoords,0 , atlasCoords)
	
	if cells[cellIndex] == -1:
		revealSurroundingCells(cellCoords, false)

#cell coords -> arrays
func getCellIndex(cellCoords : Vector2i) -> int:
	if cellCoords.x < CELL_ROWS and cellCoords.y < CELL_COLUMNS:
		if cellCoords.x >= 0 and cellCoords.y >= 0:
			return cellCoords.y * CELL_ROWS + cellCoords.x
		else:
			return -1
	else:
		return -1

func getSurroundingCell(cellCoords : Vector2i, size : int) -> Array[int]:
	surroundingCells = []
	for y in range (-1, size - 1):
		for x in range(-1, size - 1):
			offsetCoords = cellCoords + Vector2i(x, y)
			if getCellIndex(offsetCoords) > -1:
				surroundingCells.append(cells[getCellIndex(offsetCoords)])
			else:
				surroundingCells.append(-1)
	return surroundingCells

func revealSurroundingCells(cellCoords : Vector2i, numberCanReveal : bool) -> void:
	var numberFlags := 0
	for y in range(-1, 2):
		for x in range(-1, 2):
			offsetCoords = cellCoords + Vector2i(x, y)
			
			if getCellIndex(offsetCoords) > -1:
				if cells[getCellIndex(cellCoords)] >= 1:
					
					if getAtlasCoords(offsetCoords) == Vector2i(1, 0):
						if numberCanReveal == false:
							numberFlags += 1
					else:
						if numberCanReveal == true:
							if getAtlasCoords(offsetCoords) == Vector2i(0, 0):
								lastMove.append(offsetCoords)
								revealCell(offsetCoords)
				else:
					if getAtlasCoords(offsetCoords) == Vector2i(0, 0) or getAtlasCoords(offsetCoords) == Vector2i (1, 0):
						revealCell(offsetCoords)
	
	if cells[getCellIndex(cellCoords)] >= -1:
		if numberFlags == cells[getCellIndex(cellCoords)]:
			revealSurroundingCells(cellCoords, true)


func getAtlasCoords(cellCoords : Vector2i) -> Vector2i:
	return get_cell_atlas_coords(0, cellCoords)

func revealAllMines(avoid : Array[Vector2i]) -> void:
	var cellCoords : Vector2i
	for y in range(CELL_COLUMNS):
		for x in range(CELL_ROWS):
			cellCoords = Vector2i(x, y)
			if cells[getCellIndex(cellCoords)] == 0:
				if not avoid.has(cellCoords):
					set_cell(0, cellCoords, 0, Vector2i(2, 0))
			else:
				if getAtlasCoords(cellCoords) == Vector2i(1, 0):
					set_cell(0, cellCoords, 0, Vector2i(1, 3))
