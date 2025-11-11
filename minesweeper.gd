extends TileMap

# -1 = empty cell
# 0 = mine
# 1-8 = number cell

const CELL_ROWS := 30
const CELL_COLUMNS := 16
const MINE_COUNT := 99

var cells : Array[int]


func _ready() -> void:
	setUpBoard()


#Grid
func setUpBoard() -> void:
	for y in range(CELL_COLUMNS):
		for x in range(CELL_ROWS):
			set_cell(0, Vector2i(x, y), 0, Vector2i(0,0))
			cells.append(-1)

#mines
func setUpMines() -> void:
	for i in range(MINE_COUNT):
		cells[i] = 0
	cells.shuffle()

#Reveal cells
func _input(event : InputEvent) -> void:
	if event.is_action_pressed("reveal"):
		var cellAtmouse : Vector2i = local_to_map(get_local_mouse_position())
		if cells.has(0):
			revealCell(cellAtmouse)
		else:
			setUpMines()
			print(cells)

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

#cell coords -> arrays
func getCellIndex(cellCoords : Vector2i) -> int:
	if cellCoords.x < CELL_ROWS and cellCoords.y < CELL_COLUMNS:
		if cellCoords.x >= 0 and cellCoords.y >= 0:
			return cellCoords.y * CELL_ROWS + cellCoords.x
		else:
			return -1
	else:
		return -1
