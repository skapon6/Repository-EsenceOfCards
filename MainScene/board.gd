class_name Board extends Node2D
@onready var canvas_layer: CanvasLayer = $CanvasLayer

@onready var damage: Label = $CanvasLayer/PanelContainer/Damage
@onready var shield: Label = $CanvasLayer/PanelContainer/Shield
@onready var enemy_shield: Label = $CanvasLayer/PanelContainer/EnemyShield
@onready var enemies_card_hp: Label = $CanvasLayer/PanelContainer/EnemiesCardHp
@onready var enemy_hp: Label = $CanvasLayer/PanelContainer/EnemieHp






func _ready() -> void:
	canvas_layer.visible = false
	GameManager.pass_stats_to_board.connect(_update_stats_on_board)
	pass


func _process(delta: float) -> void:
	if Input.is_action_pressed("show_stats"):
		canvas_layer.visible = true
	else:
		canvas_layer.visible = false

		

func _update_stats_on_board(_damage: float, _shield: float , _enemy_shield : float, _enemies_card_hp: float, _enemy_hp : float) -> void:
	damage.text = str(_damage)
	shield.text = str(_shield)
	enemy_shield.text = str(_enemy_shield)
	enemies_card_hp.text = str(_enemies_card_hp)
	enemy_hp.text = str(_enemy_hp)
	
