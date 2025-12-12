class_name CardBase extends Node

var card_name : String 

var damage : float = 1
var base_damage : float = 1

var bonus_chance : float
var bonus_multiplier : float

var hp : float = 1
var base_hp : float = 1 

var shield : float = 1
var base_shield : float = 1

var move_cost : int = 1
var pick_chance = 1
var level : int = 1

var synergy_tag : String
var effects : Dictionary = {}
var effect_applied : bool = false


func on_play(count : int) -> void:
	if count >= 0:
		run_effects("")
		
	pass
	
func run_effects(_effect : String) -> void:
	print("run effect")
	if _effect == "additional_shield":
		pass
	pass
	
	
func reset_stats() -> void:
	# Resetowanie statystyk po zakończeniu tury, jeśli efekty były aktywne
	if effect_applied:
		# Tutaj należy dodać logikę resetującą modyfikatory
		pass
	effect_applied = false
	pass
	
func _run_bonus() -> void:
	# Mechanika losowego efektu/bonusu
	if randf() < bonus_chance:
		# Logika uruchomienia bonusa
		pass
		effect_applied = true
