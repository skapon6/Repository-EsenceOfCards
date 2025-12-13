class_name PlayerHand extends Container

@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var cards_in_game: CardsInGame = $"../CardsInGame"
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var timer: Timer = $Timer
var can_play_sound : bool = true

const SLOT := 7
var is_hovered : bool = false
var can_move_card : bool = true
var slot_base_positions := {}

signal can_move_card_changed
signal can_start_tour(can : bool)


func _init() -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_B and event.pressed:
			for i in h_box_container.get_children():
				var button := i as TextureButton
				


func _ready() -> void:
	GameManager.player_hand = self

	create_slot()

	call_deferred("save_base_positions")


func create_slot():
	for i in range(SLOT):
		var slot = TextureButton.new()
		slot.name = "slot_" + str(i)
		slot.custom_minimum_size = Vector2(160, 160)
		slot.size_flags_horizontal = Control.SIZE_FILL
		slot.size_flags_vertical = Control.SIZE_FILL
		slot.stretch_mode = TextureButton.STRETCH_SCALE
		slot.ignore_texture_size = true
		slot.connect("mouse_entered", Callable(self, "on_hover").bind(slot))
		slot.connect("mouse_exited", Callable(self, "on_unhover").bind(slot))
		slot.connect("pressed", Callable(self, "on_pressed").bind(slot))
		slot.set_meta("is_hovered", false)
		h_box_container.add_child(slot)
		


func save_base_positions():
	for slot in h_box_container.get_children():
		if slot is TextureButton:
			slot.set_meta("base_pos", slot.position)
			slot_base_positions[slot.name] = slot.position


func add_card(card: CardBase = null) -> void:
	if card and card.graphic:
		for slot in h_box_container.get_children():
			if not slot.has_node("CardGraphic") and slot is TextureButton:
				var card_graphic = TextureRect.new()
				card_graphic.name = "CardGraphic"
				card_graphic.texture = card.graphic
				card_graphic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				card_graphic.custom_minimum_size = Vector2(200,200)
				card_graphic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				slot.add_child(card_graphic)
				slot.set_meta("Card", card)
				
				setup_labels(slot, card)
				
				if not slot.has_meta("base_pos"):
					slot.set_meta("base_pos", slot.position)
				
				return


func on_hover(slot: TextureButton) -> void:
	if slot.get_meta("is_hovered") or not can_move_card :
		if not can_move_card:
			await can_move_card_changed
			if slot.get_meta("is_hovered"):
				return
	play_sound()
	slot.set_meta("is_hovered", true)
	slot.z_index = 2

	var tween = create_tween()
	var base_pos = slot.get_meta("base_pos")
	var new_pos = base_pos + Vector2(-50, -150)
	tween.parallel().tween_property(slot, "position", new_pos, 0.2)
	tween.parallel().tween_property(slot, "scale", Vector2(1.5, 1.5), 0.2)


func on_unhover(slot: TextureButton) -> void:
	if not slot.get_meta("is_hovered") or not can_move_card:
		if not can_move_card:
			await can_move_card_changed
			if slot.get_meta("is_hovered"):
				return
	slot.set_meta("is_hovered", false)
	slot.z_index = 1

	var tween = create_tween()
	var base_pos = slot.get_meta("base_pos")
	tween.tween_property(slot, "position", base_pos, 0.2)
	tween.parallel().tween_property(slot, "scale", Vector2(1, 1), 0.2)


func on_pressed(slot: TextureButton) -> void:
	var card = get_card(slot)
	if card and can_move_card:
		if GameManager.player.current_move_cost_temp < card.move_cost :
			higlight_card(slot)
			return
		can_move_card = false
		can_start_tour.emit(false)
		var tween = create_tween()
		var target : Vector2 = get_last_slot_in_ingame()
		tween.parallel().tween_property(slot,"global_position",target+Vector2(210,-250),0.3)
		tween.parallel().tween_property(slot,"modulate:a",0,0.75)
		tween.parallel().tween_property(slot,"scale", Vector2(1,1), 0.75)
		await tween.finished
		can_move_card = true
		can_move_card_changed.emit()
		cards_in_game.add_card_and_delete_slot(slot, card)
		call_deferred("update_slot_positions")


func get_card(slot: TextureButton) -> CardBase:
	if slot.has_meta("Card"):
		return slot.get_meta("Card")
	return null


func update_slot_positions():
	for slot in h_box_container.get_children():
		if slot is TextureButton:
			slot.modulate.a = 1
			if slot.has_meta("base_pos"):
				slot.position = slot.get_meta("base_pos")


func get_last_slot_in_ingame() -> Vector2:
	var child_count = cards_in_game.h_box_container.get_child_count()
	if  child_count == 0:
		return cards_in_game.h_box_container.global_position - Vector2(200,-200)
	if child_count == 4:
		return cards_in_game.h_box_container.global_position - Vector2(200,-400)
	var last_child = cards_in_game.h_box_container.get_child(child_count - 1)
	var last_child_pos = last_child.global_position - Vector2(+100,-200)
	return last_child_pos


	
func higlight_card(slot : TextureButton) -> void:
	var tween = create_tween()
	tween.tween_property(slot,"modulate", Color("Red"), 0.5)
	tween.chain().tween_property(slot,"modulate", Color("White"), 0.5)


func play_sound() -> void:
	if not can_play_sound:
		return
	timer.start()
	can_play_sound = false
	audio_stream_player.stream = preload("res://Cards/Assets/flip card.mp3")
	audio_stream_player.pitch_scale = randf_range(0.9,1.3)
	audio_stream_player.play()

func _on_timer_timeout() -> void:
	can_play_sound = true




func setup_labels(slot : TextureButton,card : CardBase) -> void:
	var hp_label = Label.new()
	hp_label.text = str(int(card.hp))
	hp_label.name = "HpLabel"
	hp_label.position = Vector2(70, 170) 
	hp_label.scale = Vector2(0.8,0.8)
	hp_label.add_theme_font_size_override("font_size", 24)
	hp_label.add_theme_color_override("font_color", Color.DARK_RED)
	slot.add_child(hp_label)
	
	var move_cost = Label.new()
	move_cost.text = str(card.move_cost)
	move_cost.name = "MoveCostLabel"
	move_cost.position = Vector2(130, 153) 
	move_cost.scale = Vector2(0.8,0.8)
	move_cost.add_theme_font_size_override("font_size", 24)
	move_cost.add_theme_color_override("font_color", Color8(148, 108, 7))
	slot.add_child(move_cost)
	
	var attack_dmg = Label.new()
	attack_dmg.text = str(card.damage)
	attack_dmg.name = "AttackDmg"
	attack_dmg.position = Vector2(123, 173) 
	attack_dmg.scale = Vector2(0.7,0.7)
	attack_dmg.add_theme_font_size_override("font_size", 24)
	attack_dmg.add_theme_color_override("font_color", Color8(114, 120, 118))
	slot.add_child(attack_dmg)
	
	var shield = Label.new()
	shield.text = str(card.shield)
	shield.name = "Shield"
	shield.position = Vector2(65, 155) 
	shield.scale = Vector2(0.7,0.7)
	shield.add_theme_font_size_override("font_size", 24)
	shield.add_theme_color_override("font_color", Color8(50, 54, 52))
	slot.add_child(shield)
	
	var level = Label.new()
	level.text = str(card.level)
	level.name = "Shield"
	level.position = Vector2(97, 155) 
	level.scale = Vector2(0.7,0.7)
	level.add_theme_font_size_override("font_size", 24)
	level.add_theme_color_override("font_color", Color8(29, 31, 30))
	slot.add_child(level)
	
