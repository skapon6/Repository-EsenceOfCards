class_name Oponent extends Node2D

var hp : float = 5
@onready var oponent_cards_in_game: OponentCardsInGame = $CanvasLayer/Control/OponentCardsInGame

func _ready() -> void:
	GameManager.oponent = self
	

func decrease_hp(amount : float) -> void:
	var cards_on_table = GameManager.oponent_cards_on_table
	var length = len(cards_on_table)
	
	if length == 0:
		return
	
	var damage_per_card = amount / float(length)
	
	for card in cards_on_table:
		card.hp -= damage_per_card
		card.hp = max(0, card.hp)
		print("Card: ", card.card_name, " HP: ", card.hp)
	
	# Update HP labels on cards
	oponent_cards_in_game.update_cards_hp(cards_on_table)
	
	# Update UI display
	if cards_on_table.size() > 0:
		GameManager.pass_stats_to_board.emit(
			GameManager.calculate_player_damage(),
			GameManager.calculate_player_shield(),
			GameManager.calculate_opponent_shield(),
			cards_on_table[0].hp if cards_on_table[0] else 0,
			hp
		)
	
func _pick_random_card() -> void:
	GameManager.oponent_cards_on_table.clear()
	for card in range(3):
		GameManager.oponent_cards_on_table.append(GameManager.oponent_cards.pick_random())
	
func show_oponents_cards():
	for card in GameManager.oponent_cards_on_table:
		oponent_cards_in_game.add_card(card)


func _return_cards_from_table() -> void:
	var cards_to_return = GameManager.oponent_cards_on_table.duplicate()
	GameManager.oponent_cards_on_table.clear()
	oponent_cards_in_game.return_all_cards()
