extends Control


func _on_Start_pressed() -> void:
	print("Start")
	get_tree().change_scene_to_file("res://Sence/Opening.tscn")

func _on_options_pressed() -> void:
	print("options")


func _on_exit_pressed() -> void:
	print("exit")
	get_tree().quit()
