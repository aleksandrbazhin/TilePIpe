extends Control

onready var text_node = $HBoxContainer/PresetContainer/RichTextLabel
onready var render_node: ViewportContainer = $HBoxContainer/TemplateContainer/ScrollContainer/ViewportContainer

const CORNER_MASK_CHECKS := [2, 10, 34, 42, 170]
const CORNER_BITS := [2, 8, 32, 128]

# compute all alternative 255 masks for 47 blob mask (with insignificant corner neighbours)
func find_mask_alternatives(mask: int) -> Array:
	var alternatives := [] 
	for check_mask in CORNER_MASK_CHECKS:
		for rotation in range(0, 8, 2):
			var neighbour_mask = Helpers.rotate_check_mask(check_mask, rotation)
			if mask & neighbour_mask != 0: # neighbour mask already in the mask
				continue
			var mask_alternative: int = mask | neighbour_mask
			if mask == mask_alternative or alternatives.has(mask_alternative):
				continue
			var skip := false
			for corner_bit in CORNER_BITS: # separate btis in neighbour mask
				if neighbour_mask & corner_bit == 0: # neighbour_mask does not has this corner
					continue
				var cw_corner_neighbour: int = Helpers.rotate_check_mask(corner_bit, 1)
				var ccw_corner_neighbour: int = Helpers.rotate_check_mask(corner_bit, 7)
				# mask has both corner neighbours for corner_bit
				if mask & cw_corner_neighbour != 0 and mask & ccw_corner_neighbour != 0:
					skip = true
					break
			if not skip:
				alternatives.append(mask_alternative)
	return alternatives


func rotate_indexes(indexes: Array, rotation: int) -> Array:
	var new_indexes := []
	for i in indexes:
		new_indexes.append((int(i) + rotation) % 4)
	return new_indexes


func fix_rotations():
	var generation_data := GenerationData.new("res://generation_data/overlay_4_full.json")
	var new_data := {
		"type": "overlay",
		"example": "overlay_4.png",
		"name": "input_overlay_4",
		"min_size": {
			"x": 4,
			"y": 1
		},
		"piece_overlap_vectors": [[0, 0], [-1, -1], [0, 1], [1, 1]],
		"piece_overlap_vectors_rotate": [false, false, true, false],
	}
	var new_tile_data := []
	for tile_data in generation_data.data["data"]:
		var mask_variants: Array = tile_data["mask_variants"]
		for i in range(mask_variants.size()):
			var mask_variant: int = mask_variants[i]
			var mask_rotation: int = tile_data["variant_rotations"][i]
			var part_indexes: Array = tile_data["generate_piece_indexes"]
			var part_rotations: Array = tile_data["generate_piece_rotations"]
			var rotated_indexes := []
			var rotated_rotations := []
			if mask_rotation == 1:
				rotated_indexes = [part_indexes[6], part_indexes[7], part_indexes[0], part_indexes[1],
					part_indexes[2], part_indexes[3], part_indexes[4], part_indexes[5]]
				rotated_rotations = [part_rotations[6], part_rotations[7], part_rotations[0], part_rotations[1],
					part_rotations[2], part_rotations[3], part_rotations[4], part_rotations[5]]
				rotated_rotations = rotate_indexes(rotated_rotations, 1)
			elif mask_rotation == 2:
				rotated_indexes = [part_indexes[4], part_indexes[5], part_indexes[6], part_indexes[7], 
					part_indexes[0], part_indexes[1], part_indexes[2], part_indexes[3]]
				rotated_rotations = [part_rotations[4], part_rotations[5], part_rotations[6], part_rotations[7], 
					part_rotations[0], part_rotations[1], part_rotations[2], part_rotations[3]]
				rotated_rotations = rotate_indexes(rotated_rotations, 2)
			elif mask_rotation == 3:
				rotated_indexes = [part_indexes[2], part_indexes[3], part_indexes[4], part_indexes[5], 
					part_indexes[6], part_indexes[7], part_indexes[0], part_indexes[1]]
				rotated_rotations = [part_rotations[2], part_rotations[3], part_rotations[4], part_rotations[5],
					part_rotations[6], part_rotations[7], part_rotations[0], part_rotations[1]]
				rotated_rotations = rotate_indexes(rotated_rotations, 3)
			else:
				rotated_indexes = part_indexes.duplicate(true)
				rotated_rotations = part_rotations.duplicate(true)
			new_tile_data.append({
				"mask_variants": [mask_variant],
				"generate_piece_indexes":   rotated_indexes,
				"generate_piece_rotations": rotated_rotations,
				"generate_piece_flip_x":    tile_data["generate_piece_flip_x"],
				"generate_piece_flip_y":    tile_data["generate_piece_flip_y"],
			})
	new_data["data"] = new_tile_data
	text_node.text = JSON.print(new_data, "\t")


func add_255_variants():
	var reference_generation_data := GenerationData.new("res://generation_data/overlay_4_full.json")
	for tile_data in reference_generation_data.data["data"]:
		var mask_variants: Array = tile_data["mask_variants"]
		var base_mask: int = mask_variants[0]
		mask_variants.append_array(find_mask_alternatives(base_mask))
	text_node.text = JSON.print(reference_generation_data.data, "\t")


func make_255_variant_template_non_symmetrical():
	var reference_generation_data := GenerationData.new("res://generation_data/overlay_13_full.json")
	var new_data := {
		"type": "overlay",
		"example": "overlay_25.png",
		"name": "input_overlay_25",
		"min_size": {
			"x": 25,
			"y": 1
		},
		"piece_overlap_vectors": [[0, 0], [-1, -1], [0, 1], [1, 1], [1, 0], [-1, -1], [0, 1], [1, 1], [1, 1], [-1, -1], [1, 0], [1, 1], [-1, -1], 
								  [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1]],
		"piece_overlap_vectors_rotate": [false, false, false, false, false, false, false, false, false, false, false, false, false, 
								false, false, false, false, false, false, false, false, false, false, false, false]}
	var new_tile_data := []
	for tile_data in reference_generation_data.data["data"]:
		var mask_variants: Array = tile_data["mask_variants"]
		var base_mask: int = tile_data["mask_variants"][0]
		var base_indexes: Array = tile_data["generate_piece_indexes"]
		var base_rotations: Array = tile_data["generate_piece_rotations"]
		for mask_variant in mask_variants:
			var mask := int(mask_variant)
			var variant_indexes := base_indexes.duplicate()
			var variant_rotations := base_rotations.duplicate()
			var bit_index := 1
			for corner_bit in CORNER_BITS:
				# base mask and variant vary in corner_bit
				if (base_mask ^ mask) & corner_bit != 0:
					var offset_1 := 0
					var cw_corner_neighbour: int = Helpers.rotate_check_mask(corner_bit, 1)
					if mask & cw_corner_neighbour != 0:
						offset_1 = 1
					var ccw_corner_neighbour: int = Helpers.rotate_check_mask(corner_bit, 7)
					if mask & ccw_corner_neighbour != 0:
						offset_1 = 2
					variant_indexes[bit_index] = 13 + 3 * (bit_index / 2) + offset_1
#					variant_rotations[bit_index] = "x"
				bit_index += 2
			new_tile_data.append({
				"mask_variants": [mask_variant],
				"generate_piece_indexes":   variant_indexes,
				"generate_piece_rotations": variant_rotations,
				"generate_piece_flip_x":    tile_data["generate_piece_flip_x"],
				"generate_piece_flip_y":    tile_data["generate_piece_flip_y"],
			})
	new_data["data"] = new_tile_data
	text_node.text = JSON.print(new_data, "\t")


func make_255_variant_template_symmetrical():
	var reference_generation_data := GenerationData.new("res://generation_data/overlay_4_full.json")
	var new_data := {
		"type": "overlay",
		"example": "overlay_7_255.png",
		"name": "input_overlay_7",
		"min_size": {
			"x": 7,
			"y": 1
		},
	"piece_overlap_vectors": [[0, 0], [-1, -1], [0, 1], [1, 1], [1, 1], [1, 1], [1, 1]],
	"piece_overlap_vectors_rotate": [false, false, true, false, false, false, false],
	}
	var new_tile_data := []
	for tile_data in reference_generation_data.data["data"]:
		var mask_variants: Array = tile_data["mask_variants"]
		var base_mask: int = tile_data["mask_variants"][0]
		var base_indexes: Array = tile_data["generate_piece_indexes"]
		var base_rotations: Array = tile_data["generate_piece_rotations"]
		for mask_variant in mask_variants:
			var mask := int(mask_variant)
			var variant_indexes := base_indexes.duplicate()
			var variant_rotations := base_rotations.duplicate()
			var bit_index := 1
			for corner_bit in CORNER_BITS:
				# base mask and variant vary in corner_bit
				if (base_mask ^ mask) & corner_bit != 0:
					var offset_1 := 0
					var cw_corner_neighbour: int = Helpers.rotate_check_mask(corner_bit, 1)
					if mask & cw_corner_neighbour != 0:
						offset_1 = 1
					var ccw_corner_neighbour: int = Helpers.rotate_check_mask(corner_bit, 7)
					if mask & ccw_corner_neighbour != 0:
						offset_1 = 2
					variant_indexes[bit_index] = 4 + offset_1
					variant_rotations[bit_index] = bit_index / 2
#					variant_rotations[bit_index] = "x"
				bit_index += 2
			new_tile_data.append({
				"mask_variants": [mask_variant],
				"generate_piece_indexes":   variant_indexes,
				"generate_piece_rotations": variant_rotations,
				"generate_piece_flip_x":    tile_data["generate_piece_flip_x"],
				"generate_piece_flip_y":    tile_data["generate_piece_flip_y"],
			})
	new_data["data"] = new_tile_data
	text_node.text = JSON.print(new_data, "\t")


func _on_PresetButton_pressed():
#	add_255_variants()
#	fix_rotations()
#	make_255_variant_template_non_symmetrical()
	make_255_variant_template_symmetrical()

func _on_TemplateButton_pressed():
	render_node.draw_data()


func _on_SaveButton_pressed():
	$TemplateFileDialog.popup_centered()
	

func _on_FileDialog_file_selected(path):
	var image: Image = render_node.get_texture().get_data()
	image.flip_y()
	image.save_png(path)


func _on_PresetFileDialog_file_selected(path):
	var data_file = File.new()
	data_file.open(path, File.WRITE)
	data_file.store_string(text_node.text)
	data_file.close()


func _on_SavePresetButton_pressed():
	$PresetFileDialog.popup_centered()
