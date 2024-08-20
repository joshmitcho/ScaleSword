extends RigidBody2D
class_name Sword

@onready var sprite: NinePatchRect = $SwordSprite
@onready var hit_box: CollisionShape2D = $HitBox

var damage: int
var num_upgrades: Array = [0, 0]


func reset() -> void:
	damage = 20
	sprite.size = Vector2(64, 64)
	sprite.position = Vector2(-32, -139)
	hit_box.shape.size = Vector2(25, 60)
	hit_box.position = Vector2(0, -104)
	angular_damp = 0


func upgrade(upgrade_type: int) -> void:
	#length
	if upgrade_type == 0 and num_upgrades[0] < 20:
		sprite.size.y += 16
		hit_box.shape.size.y += 16
		hit_box.position.y += 8
		damage += 5
		num_upgrades[0] += 1
		if num_upgrades[0] >= 20:
			Autoload.max_upgrade_reached.emit(0)
	#width
	elif upgrade_type == 1 and num_upgrades[1] < 20:
		sprite.size.x += 8
		sprite.position.x -= 4
		hit_box.shape.size.x += 8
		damage += 5
		num_upgrades[1] += 1
		if num_upgrades[1] >= 20:
			Autoload.max_upgrade_reached.emit(1)
