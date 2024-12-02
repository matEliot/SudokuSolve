extends Sprite2D
@onready var cooldowns = []
@onready var cooldown = 0.15
@onready var mouse_in_board = false

func _ready():
	for i in range(4):
		cooldowns.append(Time.get_unix_time_from_system())

func allowed(arg, direction=1):
	if direction == 1:
		return int(arg / Sudoku.distance + 1) < 9
	else:
		return int(arg / Sudoku.distance + 1) > 1

func additional(arg, direction=1):
	if direction == 1:
		return int(arg / Sudoku.distance + 1) % 3 == 0
	else:
		return int(arg / Sudoku.distance) % 3 == 0

func cooldown_check(arg):
	return Time.get_unix_time_from_system() - cooldowns[arg] > cooldown

func number(preset, arg):
	var place = [int(preset[0] / Sudoku.distance), int(preset[1] / Sudoku.distance)]
	for i in range(9):
		if Sudoku.board[place[0]][i] == arg or Sudoku.board[i][place[1]] == arg:
			return
	var region = Sudoku.get_region(Sudoku.board, place)
	for i in range(3):
		for j in range(3):
			if region[i][j] == arg:
				return
	if Sudoku.board[place[0]][place[1]] == 0:
		Sudoku.board[place[0]][place[1]] = arg
		var new_number = Sprite2D.new()
		new_number.name = "cell" + str(place[0]) + str(place[1])
		new_number.texture = Sudoku.references[arg - 1]
		new_number.position.x = preset[0] + Sudoku.starting_position[0]
		new_number.position.y = preset[1] + Sudoku.starting_position[1]
		get_parent().get_node("Numbers").add_child(new_number)
	else:
		Sudoku.board[place[0]][place[1]] = arg
		get_parent().get_node("Numbers").get_node("cell" + str(place[0]) + str(place[1])).texture = Sudoku.references[arg - 1]

func destroy_number(preset):
	var place = [int(preset[0] / Sudoku.distance), int(preset[1] / Sudoku.distance)]
	if get_parent().get_node("Numbers").has_node("cell" + str(place[0]) + str(place[1])):
		Sudoku.board[place[0]][place[1]] = 0
		get_parent().get_node("Numbers").get_node("cell" + str(place[0]) + str(place[1])).queue_free()

func relocate_highlight():
	var mouse_position = get_viewport().get_mouse_position()
	mouse_position.x = floor((mouse_position.x - Sudoku.starting_position[0] + floor(float(Sudoku.distance) / 2)) / Sudoku.distance)
	mouse_position.y = floor((mouse_position.y - Sudoku.starting_position[1] + floor(float(Sudoku.distance) / 2)) / Sudoku.distance)
	if mouse_position.x < 0 or mouse_position.y < 0 or mouse_position.x > 8 or mouse_position.y > 8:
		return
	position.x = mouse_position.x * Sudoku.distance + Sudoku.starting_position[0] + floor(mouse_position.x / 3) * 1
	position.y = mouse_position.y * Sudoku.distance + Sudoku.starting_position[1] + floor(mouse_position.y / 3) * 1

func _process(_delta):
	var preset = [position.x - Sudoku.starting_position[0], position.y - Sudoku.starting_position[1]]
	if Input.is_action_just_pressed("ui_debuff"):
		Sudoku.max_loop = 10
	if Input.is_action_just_pressed("ui_board_reset"):
		for child in get_parent().get_node("Numbers").get_children():
			child.queue_free()
		Sudoku.board_start()
	if Input.is_action_just_pressed("ui_reset"):
		var parent_ref = get_parent()
		for child in parent_ref.get_node("Numbers").get_children():
			if child.texture in Sudoku.wreferences:
				Sudoku.board[int(str(child.name)[4])][int(str(child.name)[5])] = 0
				child.queue_free()
		if parent_ref.has_node("Unsolved"):
			parent_ref.get_node("Unsolved").queue_free()
		if parent_ref.has_node("Shortcuts"):
			parent_ref.get_node("Shortcuts").queue_free()
		var tween = create_tween()
		var tween_2 = create_tween()
		parent_ref.get_node("Button").set_process(true)
		tween.tween_property(parent_ref.get_node("Button"), "modulate", Color(1, 1, 1, 1), Sudoku.fade_out_time)
		tween_2.tween_property(self, "modulate", Color(1, 1, 1, 1), Sudoku.fade_out_time)
		tween.play()
		tween_2.play()
		Sudoku.start()
	if mouse_in_board and Input.is_action_pressed("ui_left_click"):
		relocate_highlight()
	if Input.is_action_pressed("ui_one"):
		number(preset, 1)
	elif Input.is_action_pressed("ui_two"):
		number(preset, 2)
	elif Input.is_action_pressed("ui_three"):
		number(preset, 3)
	elif Input.is_action_pressed("ui_four"):
		number(preset, 4)
	elif Input.is_action_pressed("ui_five"):
		number(preset, 5)
	elif Input.is_action_pressed("ui_six"):
		number(preset, 6)
	elif Input.is_action_pressed("ui_seven"):
		number(preset, 7)
	elif Input.is_action_pressed("ui_eight"):
		number(preset, 8)
	elif Input.is_action_pressed("ui_nine"):
		number(preset, 9)
	elif Input.is_action_pressed("ui_cancel"):
		destroy_number(preset)
	preset[0] -= int(preset[0] / Sudoku.distance / 3)
	preset[1] -= int(preset[1] / Sudoku.distance / 3)
	if Input.is_action_pressed("ui_right") and cooldown_check(0):
		if allowed(preset[0]):
			position.x += Sudoku.distance
			if additional(preset[0]):
				position.x += 1
			cooldowns[0] = Time.get_unix_time_from_system()
	if Input.is_action_pressed("ui_left") and cooldown_check(1):
		if allowed(preset[0], -1):
			position.x -= Sudoku.distance
			if additional(preset[0], -1):
				position.x -= 1
			cooldowns[1] = Time.get_unix_time_from_system()
	if Input.is_action_pressed("ui_down") and cooldown_check(2):
		if allowed(preset[1]):
			position.y += Sudoku.distance
			if additional(preset[1]):
				position.y += 1
			cooldowns[2] = Time.get_unix_time_from_system()
	if Input.is_action_pressed("ui_up") and cooldown_check(3):
		if allowed(preset[1], -1):
			position.y -= Sudoku.distance
			if additional(preset[1], -1):
				position.y -= 1
			cooldowns[3] = Time.get_unix_time_from_system()
	if int(preset[0]) % Sudoku.distance > Sudoku.distance - 4:
		position.x += Sudoku.distance - (int(preset[0]) % Sudoku.distance)
	elif int(preset[0]) % Sudoku.distance > 0:
		position.x -= int(preset[0]) % Sudoku.distance
	if int(preset[1]) % Sudoku.distance > Sudoku.distance - 4:
		position.y += Sudoku.distance - (int(preset[1]) % Sudoku.distance)
	elif int(preset[1]) % Sudoku.distance > 0:
		position.y -= int(preset[1]) % Sudoku.distance
	if position.x > Sudoku.starting_position[0] + Sudoku.distance * 8 + 2:
		position.x = Sudoku.starting_position[0] + Sudoku.distance * 8 + 2
	if position.y > Sudoku.starting_position[1] + Sudoku.distance * 8 + 2:
		position.y = Sudoku.starting_position[1] + Sudoku.distance * 8 + 2

func _on_mouse_detection_mouse_entered():
	mouse_in_board = true

func _on_mouse_detection_mouse_exited():
	mouse_in_board = false
