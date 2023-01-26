extends Control


func _ready():
	$M/C/Body/Menu/BtnAbout.grab_focus()


func _on_btn_about_pressed():
	get_parent().remove_child(self)
	queue_free()


func _on_btn_cancel_btn_pressed():
	get_parent().remove_child(self)
	queue_free()


# Buttons
func _on_btn_discord_pressed(): OS.shell_open("https://discord.com/invite/qKznMrpdnw")
func _on_btn_git_hub_pressed(): OS.shell_open("https://github.com/Mofrog/NeonRush")
func _on_btn_license_pressed(): OS.shell_open(ProjectSettings.globalize_path("res://LICENSE"))
func _on_btn_godot_license_pressed(): OS.shell_open("https://godotengine.org/license/")
func _on_btn_scroll_license_pressed(): OS.shell_open("https://github.com/SpyrexDE/SmoothScroll/blob/godot-3/LICENSE")
func _on_btn_sql_license_pressed(): OS.shell_open("https://github.com/2shady4u/godot-sqlite/blob/master/LICENSE.md")
func _on_btn_blur_license_pressed(): OS.shell_open("https://github.com/Bauxitedev/godot-motion-blur/blob/master/LICENSE")
func _on_btn_audio_import_license_pressed(): OS.shell_open("https://github.com/Gianclgar/GDScriptAudioImport/blob/master/LICENSE")
func _on_btn_sen_license_pressed(): OS.shell_open(ProjectSettings.globalize_path("res://art/fonts/Sen/OFL.txt"))
func _on_btn_deja_vu_sans_license_pressed(): OS.shell_open(ProjectSettings.globalize_path("res://art/fonts/dejavu-sans/LICENSE.txt"))
