class_name OponentCardsInGame extends Container

@onready var h_box_container: HFlowContainer = $HBoxContainer
#@onready var move_cost: MoveCost = $"../MoveCost"

signal update_tour(card: CardBase)

func _ready() -> void:
	pass
	
func add_card(card : CardBase) -> void:
	var slot_on_table = TextureButton.new()
	add_label(slot_on_table, card)
	slot_on_table.custom_minimum_size = Vector2(140, 140)
	slot_on_table.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	slot_on_table.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slot_on_table.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	slot_on_table.ignore_texture_size = true
	slot_on_table.texture_normal = card.graphic	
	h_box_container.add_child(slot_on_table)
	
func add_label(slot : TextureButton, card : CardBase) -> void:
	var hp_label = Label.new()
	hp_label.text = str(card.hp)
	hp_label.name = "HpLabel"
	hp_label.position = Vector2(50, 150) 
	hp_label.scale = Vector2(0.8,0.8)
	hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hp_label.add_theme_font_size_override("font_size", 24)
	hp_label.add_theme_color_override("font_color", Color.RED)
	slot.add_child(hp_label)


	
func return_all_cards() -> void:
	print("returnssss")
	for card in h_box_container.get_children():
		print("cardssssssss", card)
		card.queue_free()
		
