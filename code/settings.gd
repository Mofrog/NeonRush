extends Resource
class_name Settings


var settings : Dictionary = {
	"Language" : 0,
	"WSize" : 4,
	"WMode" : 2,
	"VSync" : 1,
	"MaxFPS" : 2.0,
	"MSens" : 1.0,
	"Graphics" : 2,
	"Blur" : 1,
	"Distance" : 12,
	"Master volume" : 1.0,
	"Music volume" : 1.0,
	"Effect volume" : 1.0,
	"FPSCounter" : 0
}
var default_settings = settings.duplicate()


func get_data():
	var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
	if file == null: return null
	var settings_data = JSON.parse_string(file.get_as_text())
	if settings_data == null: return null
	return settings_data


func load_settings():
	var data = get_data()
	if data != null: 
		settings = data.duplicate()
		default_settings = settings.duplicate()
	set_settings()


func set_settings():
	match int(settings["Language"]):
		0: TranslationServer.set_locale("en")
		1: TranslationServer.set_locale("ru")
	match int(settings["WMode"]):
		0: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		2: 
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	match int(settings["WSize"]):
		0: DisplayServer.window_set_size(Vector2i(1360,768))
		1: DisplayServer.window_set_size(Vector2i(1440,900))
		2: DisplayServer.window_set_size(Vector2i(1600,900))
		3: DisplayServer.window_set_size(Vector2i(1680,1050))
		4: DisplayServer.window_set_size(Vector2i(1920,1080))
		5: DisplayServer.window_set_size(Vector2i(2560,1600))
		6: DisplayServer.window_set_size(Vector2i(2560,1440))
		7: DisplayServer.window_set_size(Vector2i(3440,1440))
		8: DisplayServer.window_set_size(Vector2i(3840,2160))
	match int(settings["VSync"]):
		0: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		1: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	match int(settings["MaxFPS"]):
		0: Engine.set_max_fps(30)
		1: Engine.set_max_fps(45)
		2: Engine.set_max_fps(60)
		3: Engine.set_max_fps(75)
		4: Engine.set_max_fps(90)
		5: Engine.set_max_fps(120)
		6: Engine.set_max_fps(144)
	ProjectSettings.set_setting("config/mouse_sens", settings["MSens"])
	#settings["Graphics"]
	ProjectSettings.set_setting("config/is_motion_blur_enabled", settings["Blur"])
	ProjectSettings.set_setting("config/visible_radius", settings["Distance"])
	#settings["Master volume"]
	#settings["Music volume"]
	#settings["Effect volume"]
	#settings["FPSCounter"]


func is_settings_changed():
	for i in settings: if settings[i] != default_settings[i]: return true
	return false


func save_settings():
	var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	file.store_string(JSON.stringify(settings))
