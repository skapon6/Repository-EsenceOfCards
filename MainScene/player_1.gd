class_name Player extends Node2D

var current_move_cost := 10
var current_move_cost_temp := 10
var hp = 10
func _ready() -> void:
	GameManager.player = self


func decrease_hp(amount : float) -> void:
	hp-= amount
	print("Player hp : ", hp)
