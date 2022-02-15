extends ColorRect

class_name TemplateView

onready var texture_rect := $VBoxContainer/TextureRect
onready var name_label := $VBoxContainer/CenterContainer/HBoxContainer/TemplateNameLabel


func load_data(tile: TileInTree):
	if tile.template_path != "":
		name_label.text = tile.template_path.get_file()
		texture_rect.texture = tile.loaded_template