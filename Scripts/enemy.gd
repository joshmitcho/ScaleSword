extends RigidBody2D
class_name Enemy

const MAX_HP_BAR_SIZE: int = 80
const ENEMY_TYPES: Array = [
	[100, 50000, 10, 100, 100],
	[10, 20000, 20, 50, 150],
	[1000, 450000, 40, 300, 300],
]


@onready var sprite: Sprite2D = $EnemySprite
@onready var hp_bar: ColorRect = %HPBar
@onready var hp_bar_outline: NinePatchRect = $Node2D/HPBarOutline
@onready var damage_label: Label = %DamageLabel
@onready var damage_label_start_position: Vector2 = damage_label.position

var speed: float
var damage: int
var max_hp: int
var current_hp: int
var xp: int

var flashing: bool = false
var flash_amount: float = 0
var flash_time: int = 0


func _ready() -> void:
	Autoload.enemy_hit.connect(take_hit)
	Autoload.restart.connect(game_restart)
	hp_bar.color = Color.RED
	hp_bar.size.x = MAX_HP_BAR_SIZE
	hp_bar.position.x = -MAX_HP_BAR_SIZE / 2
	hp_bar.pivot_offset.x = hp_bar.position.x
	hp_bar_outline.size.x = MAX_HP_BAR_SIZE + 8
	hp_bar_outline.position.x = -(hp_bar_outline.size.x) / 2
	hp_bar_outline.pivot_offset.x = hp_bar_outline.position.x
	damage_label.modulate = Color.TRANSPARENT


func initialize(enemy_type: int) -> void:
	mass = ENEMY_TYPES[enemy_type][0]
	sprite.frame = enemy_type + 1
	speed = ENEMY_TYPES[enemy_type][1]
	damage = ENEMY_TYPES[enemy_type][2]
	max_hp = ENEMY_TYPES[enemy_type][3]
	current_hp = max_hp
	xp = ENEMY_TYPES[enemy_type][4]


func take_hit(enemy: Enemy, incoming_damage: int) -> void:
	if enemy == self:
		current_hp -= incoming_damage
		var hp_percent: float = (float(current_hp) / max_hp)
		hp_bar.size.x = MAX_HP_BAR_SIZE * hp_percent
		hp_bar.color = Color.RED.lerp(Color.WEB_MAROON, 1 - hp_percent)
		damage_number(incoming_damage)
		if current_hp <= 0:
			die()
		flashing = true
		await get_tree().create_timer(0.8).timeout
		flashing = false
		sprite.modulate = Color.WHITE


func damage_number(incoming_damage: int) -> void:
	damage_label.text = "-" + str(incoming_damage)
	damage_label.modulate = Color.RED
	damage_label.position = damage_label_start_position
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(damage_label, "position", damage_label.position + Vector2(0, -40), 1)
	tween.parallel().tween_property(damage_label, "modulate", Color(1, 0, 0, 0), 1)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var player_seeking_force: Vector2 = (Autoload.player.global_position - position).normalized()
	state.apply_central_force(player_seeking_force * speed)
	
	#rotation = linear_velocity.angle()
	rotation = player_seeking_force.angle()
	hp_bar.get_parent().global_rotation = 0
	
	flash_amount = sin(Time.get_ticks_msec() / 50)
	if flashing:
		sprite.modulate = Color.RED.lerp(Color.WHITE, flash_amount)
		


func die() -> void:
	Autoload.enemy_killed.emit(self)
	queue_free()


func game_restart() -> void:
	queue_free()
	
	
