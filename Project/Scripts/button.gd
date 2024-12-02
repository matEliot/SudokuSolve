extends Area2D
@onready var inside = false
@onready var player = $button

func _ready():
	$Timer.wait_time = Sudoku.fade_out_time

func _process(_delta):
	var clicked = Input.is_action_just_pressed("ui_left_click") and inside
	if clicked or Input.is_action_just_pressed("ui_accept"):
		set_process(false)
		var tween = create_tween()
		var tween_2 = create_tween()
		var highlight_ref = get_parent().get_node("Highlight")
		tween.tween_property(self, "modulate", Color(1, 1, 1, 0), Sudoku.fade_out_time)
		tween_2.tween_property(highlight_ref, "modulate", Color(1, 1, 1, 0), Sudoku.fade_out_time)
		tween.play()
		tween_2.play()
		$Timer.start()

func _on_mouse_entered():
	player.speed_scale = 1
	player.play("press")
	inside = true

func _on_mouse_exited():
	player.speed_scale = -1
	player.play("press")
	inside = false

func _on_timer_timeout():
	await(Sudoku.solve(self))
