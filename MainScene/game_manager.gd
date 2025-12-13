extends Node


var player : Player = null
var player_hand: PlayerHand = null
var cards_in_game : CardsInGame = null
var cards_on_table : Array[CardBase]

var oponent : Oponent
var oponent_cards : Array[CardBase]
var oponent_cards_on_table : Array[CardBase]

var current_tour : TOUR
var current_action : ACTION

var direct_damage : float = 0
var player_selected_action : ACTION
var player_mod : Dictionary
var oponent_mod : Dictionary
var pending_move_cost : int = 0


enum TOUR {PLAYER, OPONENT}
# ACTION represents the high-level choice for a side during resolution
enum ACTION {ATTACK,DEFENCE}

var all_cards := [
	Knight,
	Golem
]



# pass_stats_to_board: used to preview stats in HUD/board when playing/removing cards
signal pass_stats_to_board(damage: float, shield : float, enemy_shield : float, enemies_card_hp: float, enemy_hp: float)
# whose_turn: emitted when a new turn starts so HUD can display whose turn it is
signal whose_turn(who : TOUR)
# reset_cards_stats: notify cards to clear temporary buffs / visuals between turns
signal reset_cards_stats
# can_start_tour: enables/disables the "Start" button in HUD
signal can_start_tour(can : bool)
signal started_tour

func _ready() -> void:
	current_tour = TOUR.PLAYER
	current_action = ACTION.ATTACK

	# Wait two frames to ensure other nodes (player_hand, hud, etc.) are ready
	await get_tree().process_frame
	await get_tree().process_frame

	for i in range(player_hand.SLOT):
		draw_cards()

	start_tour()



func draw_cards() -> void:
	if player_hand:
		player_hand.add_card(random_pick())
	if oponent:
		oponent_cards.append(random_pick())


func random_pick() -> CardBase:
	var instances := []
	var total_weight := 0.0

	for card_class in all_cards:
		var inst = card_class.new()
		instances.append(inst)
		total_weight += inst.pick_chance

	var r = randf() * total_weight

	for inst in instances:
		r -= inst.pick_chance
		if r <= 0:
			return inst

	return instances[0]

	
	
	
func get_action_modifiers(action : ACTION) -> Dictionary:
	match action:
		ACTION.ATTACK:
			return {
				"damage_multiplier" : randf_range(1.1,1.35),
				"shield_multiplier" : randf_range(0.65,0.8)
			}
			
		ACTION.DEFENCE:
			return {
				"damage_multiplier" : randf_range(0.5,0.85),
				"shield_multiplier" : randf_range(1.3,1.55)
			}
			
		_:
			return {
				"damage_multiplier" : 0,
				"shield_multiplier" : 0
			}

func start_tour() -> void:
	print("Oponents card: ", oponent_cards)
	print("Oponents cards in game", oponent_cards_on_table)
	GameManager.player.current_move_cost_temp = GameManager.player.current_move_cost
	whose_turn.emit(current_tour)
	pass
	
	
	
func end_tour() -> void:
	match current_tour:
		TOUR.PLAYER:
			current_tour = TOUR.OPONENT
			can_start_tour.emit(true)
		TOUR.OPONENT:
			current_tour = TOUR.PLAYER
			can_start_tour.emit(true)

	reset_cards_stats.emit()
	start_tour()
			

func resolve_tour() -> void:
	player_selected_action = current_action

	pending_move_cost = 0
	for c in cards_on_table:
		pending_move_cost += c.move_cost

	match current_tour:
		TOUR.PLAYER:
			await resolve_player_tour()
		TOUR.OPONENT:
			await resolve_opponent_tour()

	consume_move_cost(player_selected_action)

	cards_in_game.return_all_cards_on_table(cards_on_table)
	await get_tree().process_frame

	end_tour()
	
func consume_move_cost(player_selected_action : ACTION) -> void:
	GameManager.player.current_move_cost -= pending_move_cost
	GameManager.player.current_move_cost = max(0, GameManager.player.current_move_cost)
	GameManager.player.current_move_cost_temp = GameManager.player.current_move_cost
	
	if player_selected_action == ACTION.DEFENCE:
		pass
	
	cards_in_game.update_tour.emit(false, null)

	

func resolve_player_tour() -> void:
	oponent._pick_random_card()
	oponent.show_oponents_cards()
	await get_tree().create_timer(1.5).timeout
	var opponent_action = [ACTION.ATTACK, ACTION.DEFENCE][randi() % 2]
	run_effects_on_card(check_synergies())
	resolve_actions(current_action, opponent_action, true)
	await get_tree().create_timer(2.0).timeout
	oponent._return_cards_from_table()
	await get_tree().create_timer(1.0).timeout
	

func resolve_opponent_tour() -> void:
	print("oponents tour resolved")
	oponent._pick_random_card()
	oponent.show_oponents_cards()
	await get_tree().create_timer(1.5).timeout
	var opponent_action = [ACTION.ATTACK, ACTION.DEFENCE][randi() % 2]
	run_effects_on_card(check_synergies())
	resolve_actions(player_selected_action, opponent_action, false)
	await get_tree().create_timer(2.0).timeout
	oponent._return_cards_from_table()
	await get_tree().create_timer(1.0).timeout
	

func resolve_actions(player_act: ACTION, opponent_act: ACTION, is_player_turn: bool) -> void:
	player_mod = get_action_modifiers(player_act)
	oponent_mod = get_action_modifiers(opponent_act)

	var player_damage = snapped(calculate_player_damage() * player_mod["damage_multiplier"], 0.01)
	var player_shield = snapped(calculate_player_shield() * player_mod["shield_multiplier"], 0.01)
	var enemy_damage = snapped(calculate_opponent_damage() * oponent_mod["damage_multiplier"], 0.01)
	var enemy_shield = snapped(calculate_opponent_shield() * oponent_mod["shield_multiplier"], 0.01)

	var damage_to_enemy = calc_direct_damage(player_damage, enemy_shield)
	var damage_to_player = calc_direct_damage(enemy_damage, player_shield)

	match [player_act, opponent_act]:
		[ACTION.ATTACK, ACTION.ATTACK]:
			# both attack: both sides deal damage
			if is_player_turn:
				print("⚔️ Gracz atakuje, przeciwnik kontratakuje")
			else:
				print("⚔️ Przeciwnik atakuje, gracz kontratakuje")
			apply_damage(damage_to_enemy, damage_to_player, is_player_turn)

		[ACTION.ATTACK, ACTION.DEFENCE]:
			# attacker deals reduced damage because defender gains shield
			if is_player_turn:
				print("🗡 Gracz atakuje, przeciwnik się broni")
			else:
				print("🗡 Przeciwnik atakuje, gracz się broni")
			apply_damage(damage_to_enemy, damage_to_player, is_player_turn)

		[ACTION.DEFENCE, ACTION.ATTACK]:
			# defender regains a move point
			player.current_move_cost+=1
			if is_player_turn:
				print("🛡 Gracz się broni, przeciwnik atakuje")
			else:
				print("🛡 Przeciwnik się broni, gracz atakuje")
			apply_damage(damage_to_enemy, damage_to_player, is_player_turn)

		[ACTION.DEFENCE, ACTION.DEFENCE]:
			# both defend: no direct damage, both recover a small resource
			player.current_move_cost+=1
			print("🛡 Obie strony się bronią")

	end_tour()

func apply_damage(damage_to_enemy: float, damage_to_player : float, is_player_turn: bool) -> void:
	if is_player_turn:
		oponent.decrease_hp(damage_to_enemy)
	else:
		player.decrease_hp(damage_to_player)


func check_synergies() -> Dictionary:
	var all_synergies = {}
	for card in cards_on_table:
		var tag = card.synergy_tag
		if not all_synergies.has(tag):
			all_synergies[tag] = 0
		all_synergies[tag] += 1
	print(all_synergies)
	return all_synergies



func run_effects_on_card(synergies : Dictionary) -> void:
	for card in cards_on_table:
		var count = synergies.get(card.synergy_tag, 0)
		card.on_play(count)
		
	
	
	

func update_tour_in_tab(prediction : bool , _card : CardBase = null) -> void:
	if not _card:
		return
	check_synergies()
	pass_stats_to_board.emit(calculate_player_damage(), calculate_opponent_shield(), calculate_opponent_shield(), 2,  oponent.hp,)
	pass
	
	
func calc_direct_damage(damage, shield) -> float :
	var reduction = shield / (shield + 10.0) 
	var final_damage = damage * (1.0 - reduction)
	return snapped(max(final_damage, 0), 0.01)



func calculate_player_damage() -> float:
	var dmg := 0.0
	for c in cards_on_table:
		dmg += c.damage
	return dmg

func run_bonus() -> void:
	for card in cards_on_table:
		card._run_bonus()
	pass
	
func calculate_player_shield() -> float:
	var shield := 0.0
	for c in cards_on_table:
		shield += c.shield
	return shield
	
	
func calculate_opponent_damage() -> float:
	var damage := 0.0
	for c in oponent_cards_on_table:
		damage += c.damage
	return damage
	
	
func calculate_opponent_shield() -> float:
	var shield := 0.0
	for c in oponent_cards_on_table:
		shield += c.shield
	return shield
