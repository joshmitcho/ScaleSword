extends Node

signal enemy_hit(enemy: Enemy, damage: int)
signal player_hurt(enemy: Enemy)
signal update_hp(new_hp: int, new_max: int)
signal enemy_killed(enemy: Enemy)
signal level_complete(current_level: int)
signal upgrade_chosen(upgrade_index: int, cost: int)
signal max_upgrade_reached(upgrade_index: int)
signal next_level()
signal game_over()
signal restart()

var player: Player
var paused: bool = true
