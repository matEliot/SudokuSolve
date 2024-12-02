extends Node
@onready var board = []
@onready var files = []
@onready var rows = []
@onready var regions = []
@onready var references = [load("res://Sprites/Numbers/one.png"),
load("res://Sprites/Numbers/two.png"), load("res://Sprites/Numbers/three.png"),
load("res://Sprites/Numbers/four.png"), load("res://Sprites/Numbers/five.png"),
load("res://Sprites/Numbers/six.png"), load("res://Sprites/Numbers/seven.png"),
load("res://Sprites/Numbers/eight.png"), load("res://Sprites/Numbers/nine.png")]
@onready var wreferences = [load("res://Sprites/Written Numbers/written_one.png"),
load("res://Sprites/Written Numbers/written_two.png"), load("res://Sprites/Written Numbers/written_three.png"),
load("res://Sprites/Written Numbers/written_four.png"), load("res://Sprites/Written Numbers/written_five.png"),
load("res://Sprites/Written Numbers/written_six.png"), load("res://Sprites/Written Numbers/written_seven.png"),
load("res://Sprites/Written Numbers/written_eight.png"), load("res://Sprites/Written Numbers/written_nine.png")]
@onready var distance = 55
@onready var starting_position = [127 + int(float(distance) / 2), 52 + int(float(distance) / 2)]
@onready var starting_position_of_button = [375, 600]
@onready var fade_out_time = 0.5
@onready var looped = 0
@onready var region_row_control = []
@onready var region_file_control = []
@onready var wipe_controls = []
@onready var max_loop = 15
@onready var default_regional = {}
@onready var row_doubles = []
@onready var file_doubles = []
@onready var region_doubles = []
@onready var row_triples = []
@onready var file_triples = []
@onready var region_triples = []
@onready var checker = [[0, 7]]

func board_start():
	board = []
	for i in range(9):
		var sub_board = []
		for j in range(9):
			sub_board.append(0)
		board.append(sub_board)

func reset_doubles():
	row_doubles = []
	file_doubles = []
	region_doubles = []
	row_triples = []
	file_triples = []
	region_triples = []
	for i in range(9):
		row_doubles.append({})
		file_doubles.append({})
		row_triples.append({})
		file_triples.append({})
		for j in range(1, 10):
			row_doubles[-1][j] = []
			file_doubles[-1][j] = []
			row_triples[-1][j] = []
			file_triples[-1][j] = []
	for i in range(3):
		region_doubles.append([{}, {}, {}])
		region_triples.append([{}, {}, {}])
		for j in range(3):
			for k in range(1, 10):
				region_doubles[i][j][k] = []
				region_triples[i][j][k] = []

func start(board_reset=false):
	reset_doubles()
	if board_reset:
		board_start()
	looped = 0
	rows = []
	files = []
	regions = []
	region_file_control = []
	region_row_control = []
	var range_as_list = Array(range(1, 10))
	for i in range(9):
		files.append(range_as_list.duplicate())
		rows.append(range_as_list.duplicate())
		region_row_control.append({})
		region_file_control.append({})
		for j in range(1, 10):
			region_row_control[-1][j] = 9
			region_file_control[-1][j] = 9
	for i in range(3):
		regions.append([[], [], []])
		for j in range(3):
			regions[-1][j] = range_as_list.duplicate()

func _ready():
	start(true)
	wipe_controls = region_row_control.duplicate()
	for i in range(1, 10):
		default_regional[i] = Vector2(9, 9)

func get_region(list, place, already_third=false):
	var virtual_place = []
	if already_third:
		virtual_place += place.duplicate()
	else:
		virtual_place.append(floor(float(place[0]) / 3))
		virtual_place.append(floor(float(place[1]) / 3))
	var region_list = []
	for i in range(3):
		var sub_region_list = []
		for j in range(3):
			sub_region_list.append(list[i + 3 * virtual_place[0]][j + 3 * virtual_place[1]])
		region_list.append(sub_region_list)
	return region_list

func not_solved():
	for row in board:
		for value in row:
			if value == 0:
				return true
	return false

func intersect(array1, array2, reverse=false):
	var intersection = []
	for item in array1:
		if array2.has(item):
			intersection += [item]
	if reverse:
		var reverse_intersection = array1 + array2
		for item in intersection:
			while item in reverse_intersection:
				reverse_intersection.erase(item)
		return reverse_intersection
	else:
		return intersection

func write_number(numbers_ref, x:int, y:int, arg):
	if numbers_ref.has_node("cell" + str(x) + str(y)):
		return
	rows[x].erase(arg)
	files[y].erase(arg)
	regions[x / 3][y / 3].erase(arg)
	board[x][y] = arg
	var new_number = Sprite2D.new()
	new_number.name = "cell" + str(x) + str(y)
	new_number.texture = wreferences[arg - 1]
	new_number.position.y = starting_position[1] + Sudoku.distance * y + (y / 3) * 1
	new_number.position.x = starting_position[0] + Sudoku.distance * x + (y / 3) * 1
	numbers_ref.add_child(new_number)
	reset_doubles()

func cell_possible(x:int, y:int):
	if board[x][y] != 0:
		return []
	var common_items = intersect(rows[x], files[y])
	common_items = intersect(common_items, regions[x / 3][y / 3])
	var possible = []
	for to_remove in region_row_control[y]:
		var key = to_remove
		to_remove = region_row_control[y][key]
		var to_remove_doubles = row_doubles[y][key]
		var to_remove_triples = row_triples[y][key]
		if (to_remove != x / 3 and to_remove < 4 and key in common_items
		or to_remove_doubles != [] and x not in to_remove_doubles
		or to_remove_triples != [] and x not in to_remove_triples):
			common_items.erase(key)
		if to_remove_doubles != [] and x in to_remove_doubles:
			possible.append(key)
		if to_remove_triples != [] and x in to_remove_triples:
			possible.append(key)
	if len(possible):
		return possible
	for to_remove in region_file_control[x]:
		var key = to_remove
		to_remove = region_file_control[x][key]
		var to_remove_doubles = file_doubles[x][key]
		var to_remove_triples = file_triples[x][key]
		if (to_remove != y / 3 and to_remove < 4 and key in common_items 
		or to_remove_doubles != [] and y not in to_remove_doubles
		or to_remove_triples != [] and y not in to_remove_triples):
			common_items.erase(key)
		if to_remove_doubles != [] and y in to_remove_doubles:
			possible.append(key)
		if to_remove_triples != [] and y in to_remove_triples:
			possible.append(key)
	if len(possible):
		return possible
	for to_remove in range(1, 10):
		var key = to_remove
		var to_remove_doubles = region_doubles[x / 3][y / 3][key]
		var to_remove_triples = region_triples[x / 3][y / 3][key]
		if to_remove_doubles != []:
			if Vector2(x, y) not in to_remove_doubles:
				common_items.erase(key)
			else:
				possible.append(key)
		if to_remove_triples != []:
			if Vector2(x, y) not in to_remove_triples:
				common_items.erase(key)
			else:
				possible.append(key)
	if len(possible):
		return possible
	return common_items.duplicate()

func evaluation(numbers_ref, x, y):
	var possible = {}
	var rows_possible = {}
	var files_possible = {}
	for i in range(1, 10):
		possible[i] = []
		rows_possible[i] = []
		files_possible[i] = []
	for x_2 in range(3):
		for y_2 in range(3):
			var loc = [x * 3 + x_2, y * 3 + y_2]
			var possible_for_cell = cell_possible(loc[0], loc[1])
			if len(possible_for_cell) == 1:
				write_number(numbers_ref, loc[0], loc[1], possible_for_cell[0])
				possible[possible_for_cell[0]] = []
			if board[loc[0]][loc[1]] == 0:
				for i in possible_for_cell:
					possible[i].append(loc)
	for key in possible:
		if len(possible[key]) == 1:
			write_number(numbers_ref, possible[key][0][0], possible[key][0][1], key)
	for i in range(9):
		var rows_loc = [i, x * 3 + y]
		var possible_for_row = cell_possible(rows_loc[0], rows_loc[1])
		if len(possible_for_row) == 1:
			write_number(numbers_ref, rows_loc[0], rows_loc[1], possible_for_row[0])
			rows_possible[possible_for_row[0]] = []
		if board[rows_loc[0]][rows_loc[1]] == 0:
			for i_2 in possible_for_row:
				rows_possible[i_2].append(rows_loc)
	for key in rows_possible:
		if len(rows_possible[key]) == 1:
			write_number(numbers_ref, rows_possible[key][0][0], rows_possible[key][0][1], key)
	for i in range(9):
		var files_loc = [x * 3 + y, i]
		var possible_for_file = cell_possible(files_loc[0], files_loc[1])
		if len(possible_for_file) == 1:
			write_number(numbers_ref, files_loc[0], files_loc[1], possible_for_file[0])
			files_possible[possible_for_file[0]] = []
		if board[files_loc[0]][files_loc[1]] == 0:
			for i_2 in possible_for_file:
				files_possible[i_2].append(files_loc)
	for key in files_possible:
		if len(files_possible[key]) == 1:
			write_number(numbers_ref, files_possible[key][0][0], files_possible[key][0][1], key)

func triple_seeker(triple_list, possible_list, t1, t2, addition=Vector2(4, 4)):
	var t1l = possible_list[t1]
	var t2l = possible_list[t2]
	if len(intersect(t1l, t2l)) != 1:
		return
	var t3l = intersect(t1l, t2l, true)
	var t3 = possible_list.find(t3l)
	if t3 != -1:
		var possible_spots = [t1, t2, t3]
		if addition != Vector2(4, 4):
			for spot in range(len(possible_spots)):
				var item: int = possible_spots[spot]
				possible_spots[spot] = Vector2(addition.x * 3 + item / 3, addition.y * 3 + item % 3)
		for digit in t1l:
			triple_list[digit].append(possible_spots[0])
		for digit in t2l:
			triple_list[digit].append(possible_spots[1])
		for digit in t3l:
			triple_list[digit].append(possible_spots[2])

func obvious_double_seeker(doubles_list, possibles, addition=Vector2(4, 4)):
	for digits in possibles:
		if len(digits) != possibles.count(digits) or len(digits) == 0:
			continue
		if len(doubles_list[digits[0]]):
			continue
		var spots = find_all(possibles, digits)
		for spot in spots:
			if addition != Vector2(4, 4):
				spot = Vector2(addition.x * 3 + spot / 3, addition.y * 3 + spot % 3)
			for digit in digits:
				doubles_list[digit].append(spot)

func find_all(array, item):
	var spots = []
	for i in range(len(array)):
		if array[i] == item:
			spots.append(i)
	return spots

func doubles_n_triples(x, y):
	var allowed = {}
	var allowed_row = {}
	var allowed_file = {}
	var possibles = []
	var possibles_row = []
	var possibles_file = []
	var index = x * 3 + y
	for i in range(1, 10):
		possibles_row.append([])
		possibles_file.append([])
		possibles.append([])
		allowed[i] = []
		allowed_row[i] = []
		allowed_file[i] = []
	for i in range(9):
		var possible_for_cell = cell_possible(i, index)
		var possible_for_cell_ = cell_possible(index, i)
		if len(possible_for_cell) == 2:
			possibles_row[i] = possible_for_cell.duplicate()
		if len(possible_for_cell_) == 2:
			possibles_file[i] = possible_for_cell_.duplicate()
		for digit in possible_for_cell:
			allowed_row[digit].append(i)
		for digit in possible_for_cell_:
			allowed_file[digit].append(i)
	for x_2 in range(3):
		for y_2 in range(3):
			var loc = Vector2(x * 3 + x_2, y * 3 + y_2)
			var possible_for_cell = cell_possible(loc.x, loc.y)
			if len(possible_for_cell) == 2:
				possibles[x_2 * 3 + y_2] = possible_for_cell.duplicate()
			for digit in possible_for_cell:
				allowed[digit].append(loc)
	var shared_row = {}
	var shared_file = {}
	var shared = {}
	for cell in range(9):
		for cell_2 in range(cell + 1, 9):
			triple_seeker(row_triples[index], possibles_row, cell, cell_2)
			triple_seeker(file_triples[index], possibles_file, cell, cell_2)
			triple_seeker(region_triples[x][y], possibles, cell, cell_2, Vector2(x, y))
	for key in allowed_row:
		var item = allowed_row[key]
		if item not in shared_row:
			shared_row[item] = []
		shared_row[item].append(key)
	for key in shared_row:
		var item = shared_row[key]
		if len(key) == len(item):
			for i in key:
				for digit in item:
					row_doubles[index][digit].append(i)
	for key in allowed_file:
		var item = allowed_file[key]
		if item not in shared_file:
			shared_file[item] = []
		shared_file[item].append(key)
	for key in shared_file:
		var item = shared_file[key]
		if len(key) == len(item):
			for i in key:
				for digit in item:
					file_doubles[index][digit].append(i)
	for key in allowed:
		var item = allowed[key]
		if item not in shared:
			shared[item] = []
		shared[item].append(key)
	for key in shared:
		var item = shared[key]
		if len(key) == len(item):
			for i in key:
				for digit in item:
					region_doubles[x][y][digit].append(i)
	for list in shared:
		var key = shared[list]
		var x_list = []
		var y_list = []
		for place in list:
			x_list.append(place.x)
			y_list.append(place.y)
		if len(list) == len(key):
			x_list.sort()
			y_list.sort()
			if x_list[0] == x_list[-1]:
				for digit in key:
					region_file_control[x_list[0]][digit] = floor(y_list[0] / 3)
			elif y_list[0] == y_list[-1]:
				for digit in key:
					region_row_control[y_list[0]][digit] = floor(x_list[0] / 3)
	for i in range(9):
		obvious_double_seeker(row_doubles[index], possibles_row)
		obvious_double_seeker(file_doubles[index], possibles_file)
		obvious_double_seeker(region_doubles[x][y], possibles, Vector2(x, y))

func region_control(x, y):
	var region_control_list_rows = default_regional.duplicate()
	var region_control_list_files = default_regional.duplicate()
	for x_2 in range(3):
		for y_2 in range(3):
			var loc = Vector2(x * 3 + x_2, y * 3 + y_2)
			if board[loc.x][loc.y] == 0:
				for digit in cell_possible(loc.x, loc.y):
					var rclrdy = region_control_list_rows[digit].y
					if rclrdy == 9 or rclrdy == loc.y:
						region_control_list_rows[digit] = loc
					else:
						region_control_list_rows[digit] = Vector2(10, 10)
					var rclfdy = region_control_list_files[digit].x
					if rclfdy == 9 or rclfdy == loc.x:
						region_control_list_files[digit] = loc
					else:
						region_control_list_files[digit] = Vector2(10, 10)
	for digit in region_control_list_rows:
		var rclr = region_control_list_rows[digit]
		if rclr.y < 9:
			region_row_control[rclr.y][digit] = floor(rclr.x / 3)
	for digit in region_control_list_files:
		var rclf = region_control_list_files[digit]
		if rclf.x < 9:
			region_file_control[rclf.x][digit] = floor(rclf.y / 3)

func solve(catalyst):
	for x in range(9):
		for y in range(9):
			if board[x][y] != 0:
				var num = board[x][y]
				if num in rows[x]:
					rows[x].erase(num)
				if num in files[y]:
					files[y].erase(num)
				if num in regions[x / 3][y / 3]:
					regions[x / 3][y / 3].erase(num)
	while not_solved():
		if looped >= max_loop:
			var failed = Sprite2D.new()
			failed.name = "Unsolved"
			failed.texture = load("res://Sprites/Misc/unsolved.png")
			failed.position.x = starting_position_of_button[0]
			failed.position.y = starting_position_of_button[1]
			catalyst.get_parent().add_child(failed)
			break
		var numbers_ref = catalyst.get_parent().get_node("Numbers")
		looped += 1
		reset_doubles()
		for x in range(3):
			for y in range(3):
				doubles_n_triples(x, y)
				region_control(x, y)
		for x in range(3):
			for y in range(3):
				evaluation(numbers_ref, x, y)
	var shortcuts = Sprite2D.new()
	shortcuts.name = "Shortcuts"
	shortcuts.texture = load("res://Sprites/Misc/shortcuts.png")
	shortcuts.position = Vector2(97, 728)
	catalyst.get_parent().add_child(shortcuts)
	print("Loops Taken: ", looped)
