extends CharacterBody2D
class_name Player

const MAX_POSSIBLE_HP: int = 300
const I_FRAMES_MSEC: int = 250
const SWORD_HIT: AudioStream = preload("res://Sound/sword hit.wav")
const HURT = preload("res://Sound/damage.wav")
const KILL = preload("res://Sound/kill.wav")
const HEAL = preload("res://Sound/heal.wav")

@onready var sprite: Sprite2D = $PlayerSprite
@onready var sword: Sword = $Sword
@onready var damage_label: Label = %DamageLabel
@onready var damage_label_start_position: Vector2 = damage_label.position
@onready var xp_label: Label = %XPLabel
@onready var xp_label_start_position: Vector2 = xp_label.position

var sword_weight: int = 0

var time_last_hurt: int = 0

var time_last_hit: int = 0
var last_enemy_hit: Enemy = Enemy.new()

var max_hp: int
var current_hp: int
var speed: float
var damage: int
var flashing: bool

var current_xp: int = 0


func _ready() -> void:
	Autoload.player = self
	Autoload.player_hurt.connect(hurt)
	Autoload.enemy_killed.connect(enemy_killed)
	Autoload.upgrade_chosen.connect(upgrade)
	Autoload.restart.connect(reset)
	reset()


func enemy_killed(enemy: Enemy) -> void:
	SoundManager.play_shuffled_pitch_sfx(KILL)
	current_xp += enemy.xp
	xp_number(enemy.xp)


func hurt(enemy: Enemy):
	SoundManager.play_sfx(HURT)
	current_hp -= enemy.damage
	damage_number(enemy.damage)
	Autoload.update_hp.emit(current_hp, false)
	
	if current_hp <= 0:
		Autoload.game_over.emit()
		return
	
	flashing = true
	await get_tree().create_timer(0.8).timeout
	flashing = false
	sprite.modulate = Color.WHITE


func upgrade(upgrade_index: int, cost: int) -> void:
	current_xp -= cost
	if upgrade_index == 0:
		SoundManager.play_shuffled_pitch_sfx(SWORD_HIT)
		sword.upgrade(0)
	elif upgrade_index == 1:
		SoundManager.play_shuffled_pitch_sfx(SWORD_HIT)
		sword.upgrade(1)
	else:
		if max_hp < MAX_POSSIBLE_HP:
			SoundManager.play_shuffled_pitch_sfx(HEAL)
			max_hp += 25
			current_hp = max_hp
			Autoload.update_hp.emit(max_hp, true)
			if max_hp >= MAX_POSSIBLE_HP:
				Autoload.max_upgrade_reached.emit(2)


func _physics_process(_delta: float) -> void:
	var target_rotation = get_global_mouse_position() - position
	var lerp_speed: float = 0.2 - (0.01 * sword_weight)
	sprite.rotation = lerp_angle(sprite.rotation, target_rotation.angle(), lerp_speed)
	position = position.lerp(get_global_mouse_position(), lerp_speed)
	move_and_slide()
	
	var flash_amount: float = sin(Time.get_ticks_msec() / 50.0)
	if flashing:
		sprite.modulate = Color.WHITE.lerp(Color.RED, flash_amount)


func damage_number(incoming_damage: int) -> void:
	damage_label.text = "-" + str(incoming_damage)
	damage_label.modulate = Color.RED
	damage_label.position = damage_label_start_position
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(damage_label, "position", damage_label.position + Vector2(0, -40), 1)
	tween.parallel().tween_property(damage_label, "modulate", Color(1, 0, 0, 0), 1)


func xp_number(xp: int, cost: bool = false) -> void:
	var ending_colour: Color
	if cost:
		xp_label.text = "-" + str(xp) + "XP"
		xp_label.modulate = Color.RED
		ending_colour = Color(1, 0, 0, 0)
	else:
		xp_label.text = "+" + str(xp) + "XP"
		xp_label.modulate = Color.GREEN
		ending_colour = Color(0, 1, 0, 0)
	xp_label.position = xp_label_start_position
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(xp_label, "position", damage_label.position + Vector2(0, -40), 1)
	tween.parallel().tween_property(xp_label, "modulate", ending_colour, 1)


func reset() -> void:
	sword.reset()
	max_hp = 100
	current_xp = 0
	current_hp = max_hp
	speed = 10
	damage_label.modulate = Color.TRANSPARENT
	xp_label.modulate = Color.TRANSPARENT
	flashing = false
	sprite.modulate = Color.WHITE
	Autoload.update_hp.emit(current_hp, true)


func _on_sword_body_entered(body: Node) -> void:
	SoundManager.play_shuffled_pitch_sfx(SWORD_HIT, -6)
	var successful_hit: bool = false
	if body is Enemy:
		if body == last_enemy_hit:
			if Time.get_ticks_msec() > (time_last_hit + I_FRAMES_MSEC):
				successful_hit = true
		else:
			successful_hit = true
	
	if successful_hit:
		time_last_hit = Time.get_ticks_msec()
		last_enemy_hit = body
		Autoload.enemy_hit.emit(body, (sword.damage / 2) + abs(sword.angular_velocity * 1.2) + abs(sword.linear_velocity.length()/200))


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body is Enemy:
		if Time.get_ticks_msec() < (time_last_hurt + I_FRAMES_MSEC):
			return
		
		time_last_hurt = Time.get_ticks_msec()
		hurt(body)
