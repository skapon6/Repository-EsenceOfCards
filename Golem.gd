class_name Golem extends CardBase

var ctric_chance : float = 0.25
var graphic : Texture2D = preload("res://Cards/Assets/golem_card.jpg")


func _init() -> void:
	card_name = "Golem"
	move_cost = 2
	pick_chance = 0.5
	hp = 20
	damage = 3
	bonus_chance = 0.3
	bonus_multiplier = 1.2
	shield = 5
	base_shield = shield
	synergy_tag = "Golem"
	effects["additional_shield"] = 1.5

func on_play(count : int) -> void:
	if count >= 2:
		run_effects("additional_shield")
	pass
	
func run_effects(_effect : String) -> void:
	if _effect == "additional_shield":
		shield+= effects["additional_shield"]
		effect_applied = true
	pass
	
	
func reset_stats() -> void:
	if effect_applied:
		shield = base_shield
		effect_applied = false
