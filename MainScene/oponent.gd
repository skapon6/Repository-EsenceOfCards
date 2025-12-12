class_name Oponent extends Node2D

var hp : float = 5
@onready var oponent_cards_in_game: OponentCardsInGame = $CanvasLayer/Control/OponentCardsInGame
var cards = GameManager.oponent_cards_on_table
func _ready() -> void:
	GameManager.oponent = self
	

func decrease_hp(amount : float) -> void:
	var lenght = len(cards)
	print(lenght)
	print(amount)
	var decrease_value = amount / lenght
	print(decrease_value)
	for i in cards:
		i.hp-= decrease_value
		print("name ", i.card_name , "hp: ", i.hp)
	
func _pick_random_card() -> void:
	GameManager.oponent_cards_on_table.clear()
	for card in range(3):
		GameManager.oponent_cards_on_table.append(GameManager.oponent_cards.pick_random())
	
func show_oponents_cards():
	for card in GameManager.oponent_cards_on_table:
		oponent_cards_in_game.add_card(card)


func _return_cards_from_table() -> void:
	GameManager.oponent_cards_on_table.clear()
	for card in GameManager.oponent_cards_on_table:
		oponent_cards_in_game.return_all_cards()
