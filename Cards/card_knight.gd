class_name Knight extends CardBase


var ctric_chance : float = 0.25
var graphic : Texture2D = preload("res://Cards/Assets/KnightCard.jpg")


func _init() -> void:
	card_name = "Knight"
	pick_chance = 0.8
	hp = 3
	damage = 1
	base_damage = damage
	bonus_chance = 0.5
	bonus_multiplier = 1.25
	shield = 2
	move_cost = 3
	synergy_tag = "Knight"
	effects["additional_damage"] = 5
	effect_applied = false
	GameManager.reset_cards_stats.connect(reset_stats)
	

func on_play(count : int) -> void:
	if count >= 3:
		run_effects("additional_damage")
	_run_bonus()
		
	pass
	
func run_effects(_effect : String) -> void:
	if _effect == "additional_damage":
		damage+= effects["additional_damage"]
		effect_applied = true
		
	pass

func reset_stats() -> void:
	if effect_applied:
		damage = base_damage
		effect_applied = false
	pass

func _run_bonus() -> void:
	if randf() < bonus_chance:
		damage *= bonus_multiplier
		effect_applied = true
	pass
