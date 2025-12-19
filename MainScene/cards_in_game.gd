class_name CardsInGame extends Container

@onready var player_hand: PlayerHand = $"../PlayerHand"
@onready var h_box_container: HFlowContainer = $HBoxContainer
 

signal update_tour(prediction : bool, card: CardBase)

func _ready() -> void:
	GameManager.cards_in_game = self
	update_tour.connect(GameManager.update_tour_in_tab)


func add_card_and_delete_slot(slot: TextureButton, card: CardBase):
	slot.disabled = true
	slot.visible = false

	GameManager.cards_on_table.append(card)
	
	update_tour.emit(true, card)
	
	var slot_on_table = TextureButton.new()
	slot_on_table.modulate.a = 0
	var tween2 = create_tween()
	tween2.tween_property(slot_on_table,"modulate:a", 1, 0.75)
	
	add_label(slot_on_table, card)
	
	slot_on_table.custom_minimum_size = Vector2(140, 140)
	slot_on_table.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	slot_on_table.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slot_on_table.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	slot_on_table.ignore_texture_size = true
	slot_on_table.texture_normal = card.graphic
	slot_on_table.connect("pressed", Callable(self, "enable_slot_and_return_card").bind(slot, slot_on_table, card))
	
	h_box_container.add_child(slot_on_table)
	player_hand.can_start_tour.emit(true)



func enable_slot_and_return_card(slot: TextureButton, slot_on_table : TextureButton, card : CardBase, prediction : bool = true) -> void:
	var tween = create_tween()
	var slot_global_pos = slot.get_parent().global_position + slot.get_meta("base_pos")
	tween.tween_property(slot_on_table,"global_position", slot_global_pos,0.75)
	tween.parallel().tween_property(slot_on_table,"modulate:a", 0, 0.75)
	await  tween.finished
	
	
	GameManager.cards_on_table.erase(card)
	
	if prediction:
		update_tour.emit(true,card)
	
	slot.disabled = false
	slot.visible = true
	if slot_on_table:
		slot_on_table.queue_free()
	
	
	
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


var slot_number = null
var help_array = []
func return_all_cards_on_table(array : Array) -> void:
	for i in range(len(array)):
		var element = array[i] as CardBase
		for j in player_hand.get_child(0).get_children():
				if j.disabled:
					help_array.append(j)
					slot_number = help_array[0]
		var player_hand_container = slot_number
		var cards_in_game = h_box_container.get_child(i)
		enable_slot_and_return_card(player_hand_container, cards_in_game, element,false)
		help_array.pop_front()

func update_cards_hp(cards: Array[CardBase]) -> void:
	var card_slots = h_box_container.get_children()
	# Iterujemy po slotach na stole i aktualizujemy ich etykiety HP
	for i in range(min(cards.size(), card_slots.size())):
		var hp_label = card_slots[i].get_node_or_null("HpLabel")
		if hp_label:
			hp_label.text = str(int(cards[i].hp))
		if cards[i].hp <= 0:
			pass

func cards_died() -> void:
	pass
