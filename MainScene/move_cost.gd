class_name MoveCost extends HBoxContainer
@onready var cards_in_game: CardsInGame = $"../CardsInGame"
@onready var move_cost_sound: AudioStreamPlayer2D = $"../../MoveCostSound"

func _ready() -> void:
	cards_in_game.update_tour.connect(_update_move_cost)
	GameManager.started_tour.connect(_update_move_cost)
	await get_tree().process_frame
	for i in range(10):
		var seg = TextureRect.new()
		seg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		seg.texture = preload("res://Cards/Assets/move_cost_bar.png")
		seg.custom_minimum_size = Vector2(100, 60) 
		seg.modulate.a = 0.7
		add_child(seg)
	
	
func _update_move_cost(prediction : bool, _card: CardBase = null ) -> void:
	if _card == null:
		update_segments()
		return
		
	var total_move_cost := 0
	
	if prediction == false:
		print("no prediction")
		total_move_cost = GameManager.pending_move_cost
		GameManager.player.current_move_cost -= total_move_cost
		GameManager.player.current_move_cost = max(0, GameManager.player.current_move_cost)
		GameManager.player.current_move_cost_temp = GameManager.player.current_move_cost
	else:
		for c in GameManager.cards_on_table:
			total_move_cost += c.move_cost
		print("predict")
		GameManager.player.current_move_cost_temp = GameManager.player.current_move_cost - total_move_cost
		GameManager.player.current_move_cost_temp = max(0, GameManager.player.current_move_cost_temp)
		
	update_segments()
	
	
func update_segments(temp : bool = true) -> void:
	for i in range(get_child_count()):
		if i < GameManager.player.current_move_cost_temp:
			show_segments(true, i)
		else:
			show_segments(false, i)
		
	
	
	
	
	
func show_segments(show : bool, child) -> void:
	var tween = create_tween()
	if show:
		tween.tween_property(get_child(child),"modulate:a", 1, 0.5)
	else:
		tween.tween_property(get_child(child),"modulate:a", 0, 0.5)
		
	
func play_sound(is_increase : bool ) -> void:
	var sound_played : bool = false
	if is_increase:
		move_cost_sound.pitch_scale = 1.3
	else:
		move_cost_sound.pitch_scale = 0.75
	if not sound_played:
		move_cost_sound.play()
		sound_played = true
