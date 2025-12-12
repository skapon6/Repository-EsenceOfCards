class_name HUD extends CanvasLayer


@onready var start: TextureButton = $CenterContainer/Start
@onready var attack: TextureButton = $Control/HBoxContainer/Attack
@onready var defence: TextureButton = $Control/HBoxContainer/Defence

@onready var whose_turn_label: Label = $whose_turn


@onready var player_hand: PlayerHand = $Control/PlayerHand
@onready var cards_in_game: CardsInGame = $Control/CardsInGame

func _ready() -> void:
	player_hand.can_start_tour.connect(_disable_button)
	start.connect("button_down", GameManager.resolve_tour)
	GameManager.can_start_tour.connect(_can_start_tour)
	start.connect("button_down", start_button_aim)
	attack.connect("button_down", _on_attack_pressed)
	attack.connect("button_down", Callable(self, "_on_button_pressed").bind(attack))
	defence.connect("button_down", _on_defence_pressed)
	defence.connect("button_down", Callable(self, "_on_button_pressed").bind(defence))
	GameManager.whose_turn.connect(display_whose_turn)


func _disable_button(can : bool) -> void:
	if can:
		start.disabled = false
	else:
		start.disabled = true


func _on_attack_pressed() -> void:
	#defence.modulate = Color("white")
	#attack.modulate = Color("red")
	attack.modulate.a = 1
	GameManager.current_action=GameManager.ACTION.ATTACK
	defence.modulate.a = 0.3
	
func _on_defence_pressed() -> void:
	#attack.modulate = Color("white")
	#defence.modulate = Color("blue")
	defence.modulate.a = 1
	attack.modulate.a = 0.3
	GameManager.current_action=GameManager.ACTION.DEFENCE


func start_button_aim() -> void:
	start.pivot_offset = start.size / 2
	var tween = create_tween()
	tween.tween_property(start, "scale", Vector2(1.5,1.5), 0.3)
	tween.chain().tween_property(start, "scale", Vector2(1,1), 0.3)


func _on_button_pressed(button : TextureButton) -> void:
	button.pivot_offset = button.size / 2
	
	for b in [attack,defence]:
		if b != button:
			var tween = create_tween()
			tween.tween_property(b,"scale", Vector2(1,1),0.3)
		
	if button.pressed:
		var tween = create_tween()
		tween.tween_property(button,"scale", Vector2(1.7,1.7),0.3)
	else:
		button.scale = Vector2(1,1)


func display_whose_turn(who : GameManager.TOUR):
	whose_turn_label.modulate.a = 0
	if who == 0 :
		whose_turn_label.modulate = Color("White")
		whose_turn_label.text = "Player's turn"
	elif who == 1:
		whose_turn_label.text = "Oponent's turn"
		whose_turn_label.modulate = Color("Red")
		
	var tween = create_tween()
	tween.tween_property(whose_turn_label,"modulate:a", 1, 3)
	tween.chain().tween_property(whose_turn_label,"modulate:a", 0, 3)


func _can_start_tour(can : bool) -> void:
	if can:
		start.disabled = false
		start.modulate.a = 1
	else:
		start.disabled = true
		start.modulate.a = 0.5
	
