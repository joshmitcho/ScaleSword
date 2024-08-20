extends Control
class_name UI

const PIXELS_PER_HP: int = 3
const UNSHEATH = preload("res://Sound/unsheath.wav")
const LEVEL_COMPLETE = preload("res://Sound/level_complete.wav")
const STARTING_UPGRADE_COSTS: Array = [75, 100, 25]

@onready var title_screen: CenterContainer = %TitleScreen
@onready var pause_menu: CenterContainer = %PauseMenu
@onready var level_complete_menu: CenterContainer = %LevelCompleteMenu
@onready var game_over_menu: CenterContainer = %GameOverMenu
@onready var rounds_label: Label = $GameOverMenu/VBoxContainer/RoundsLabel

@onready var player_max_hp: int = Autoload.player.max_hp
@onready var hp_bar: ColorRect = $HPBar
@onready var hp_bar_outline: NinePatchRect = $HPBarOutline
@onready var xp_label: Label = $XPLabel
@onready var current_round_label: Label = $CurrentRoundLabel

@onready var upgrade_container: GridContainer = $LevelCompleteMenu/VBoxContainer/UpgradeContainer
@onready var length_upgrade: TextureButton = $LevelCompleteMenu/VBoxContainer/UpgradeContainer/LengthUpgrade
@onready var width_upgrade: TextureButton = $LevelCompleteMenu/VBoxContainer/UpgradeContainer/WidthUpgrade
@onready var hp_upgrade: TextureButton = $LevelCompleteMenu/VBoxContainer/UpgradeContainer/HPUpgrade
@onready var length_cost: Label = $LevelCompleteMenu/VBoxContainer/UpgradeContainer/LengthCost
@onready var width_cost: Label = $LevelCompleteMenu/VBoxContainer/UpgradeContainer/WidthCost
@onready var hp_cost: Label = $LevelCompleteMenu/VBoxContainer/UpgradeContainer/HPCost

@onready var upgrade_buttons: Array = [length_upgrade, width_upgrade, hp_upgrade]
@onready var cost_displays: Array = [length_cost, width_cost, hp_cost]

var upgrade_costs: Array = STARTING_UPGRADE_COSTS.duplicate()
var current_level: int


func _ready() -> void:
	Autoload.update_hp.connect(update_hp)
	Autoload.max_upgrade_reached.connect(max_upgrade_reached)
	Autoload.enemy_killed.connect(update_xp)
	Autoload.level_complete.connect(level_complete)
	Autoload.game_over.connect(game_over)
	reset_ui()


func max_upgrade_reached(upgrade_index: int) -> void:
	upgrade_container.get_children()[upgrade_index].disabled = true
	upgrade_buttons[upgrade_index] = Button.new()
	cost_displays[upgrade_index].text = ""
	cost_displays[upgrade_index] = Label.new()


func update_hp(new_hp: int, new_max: bool) -> void:
	var hp_percent: float = (float(new_hp) / player_max_hp)
	hp_bar.size.x = PIXELS_PER_HP * new_hp
	hp_bar.color = Color.LIME_GREEN.lerp(Color.RED, 1 - hp_percent)
	if new_max:
		hp_bar_outline.size.x = hp_bar.size.x + 9


func update_xp(_enemy: Enemy = Enemy.new()) -> void:
	xp_label.text = "XP: " + str(Autoload.player.current_xp)


func set_upgrade_costs() -> void:
	for i in range(cost_displays.size()):
		cost_displays[i].text = str(upgrade_costs[i]) + " XP"
		if Autoload.player.current_xp < upgrade_costs[i]:
			cost_displays[i].modulate = Color.RED
			upgrade_buttons[i].disabled = true
		else:
			cost_displays[i].modulate = Color("2a2a2a")
			upgrade_buttons[i].disabled = false
	
	update_xp()


func level_complete(level: int) -> void:
	Autoload.paused = true
	current_level = level
	SoundManager.play_shuffled_pitch_sfx(LEVEL_COMPLETE)
	set_upgrade_costs()
	level_complete_menu.visible = true


func game_over() -> void:
	get_tree().paused = true
	rounds_label.text = "Rounds Complete: " + str(current_level + 1)
	game_over_menu.visible = true


func reset_ui() -> void:
	var hp_percent: float = (float(Autoload.player.current_hp) / player_max_hp)
	hp_bar.color = Color.LIME_GREEN.lerp(Color.RED, 1 - hp_percent)
	hp_bar.size.x = PIXELS_PER_HP * Autoload.player.current_hp
	hp_bar_outline.size.x = PIXELS_PER_HP * Autoload.player.max_hp + 9
	game_over_menu.visible = false
	level_complete_menu.visible = false
	set_upgrade_costs()


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			Autoload.paused = false
			get_tree().paused = false
			pause_menu.visible = false
		elif not Autoload.paused:
			Autoload.paused = true
			get_tree().paused = true
			pause_menu.visible = true


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	SoundManager.play_sfx(UNSHEATH)
	upgrade_costs = STARTING_UPGRADE_COSTS.duplicate()
	current_level = 0
	reset_ui()
	Autoload.restart.emit()
	update_xp()
	current_round_label.text = "Round 1"


func _on_sword_upgrade_pressed() -> void:
	if Autoload.player.current_xp >= upgrade_costs[0]:
		Autoload.upgrade_chosen.emit(0, upgrade_costs[0])
		Autoload.player.xp_number(upgrade_costs[0], true)
		upgrade_costs[0] += 100

		set_upgrade_costs()

func _on_width_upgrade_pressed() -> void:
	if Autoload.player.current_xp >= upgrade_costs[1]:
		Autoload.upgrade_chosen.emit(1, upgrade_costs[1])
		Autoload.player.xp_number(upgrade_costs[1], true)
		upgrade_costs[1] += 100
		set_upgrade_costs()

func _on_hp_upgrade_pressed() -> void:
	if Autoload.player.current_xp >= upgrade_costs[2]:
		Autoload.upgrade_chosen.emit(2, upgrade_costs[2])
		Autoload.player.xp_number(upgrade_costs[2], true)
		upgrade_costs[2] += 100
		set_upgrade_costs()

func _on_next_level_button_pressed() -> void:
	Autoload.paused = false
	current_round_label.text = "Round " + str(current_level + 2)
	Autoload.next_level.emit()
	reset_ui()

func _on_start_button_pressed() -> void:
	Autoload.paused = false
	title_screen.visible = false
	SoundManager.play_sfx(UNSHEATH)
	
