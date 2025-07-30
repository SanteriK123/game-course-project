extends Label

@onready var timer = $Timer
var run_time = 0

func _on_timer_timeout() -> void:
	run_time += timer.wait_time
	run_time = snappedf(run_time, 0.1)
	text = str(run_time)
