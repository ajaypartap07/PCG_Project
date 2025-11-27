extends Node
class_name PCGManager

@onready var enemies_node: Enemies = get_tree().get_root().get_node("Level/Actors/Enemies")

var factory: EnemyPCGFactory
var _applied: bool = false

func _ready() -> void:
	# Create the factory and attach it under this manager.
	factory = EnemyPCGFactory.new()
	add_child(factory)

	# Use difficulty as the seed source.
	var difficulty: String = Global.selected_difficulty
	var seed_value: int = difficulty.hash()
	factory.set_seed(seed_value)

	# Give the scene one frame so all Enemy nodes finish _ready().
	await get_tree().process_frame

	_apply_pcg_to_all_enemies(difficulty)


func _apply_pcg_to_all_enemies(difficulty: String) -> void:
	if _applied:
		return
	_applied = true

	if enemies_node == null:
		push_warning("PCGManager: Enemies node not found at Level/Actors/Enemies.")
		return

	for child in enemies_node.get_children():
		if child is Enemy:
			var enemy: Enemy = child
			var params: Dictionary = factory.generate_enemy(difficulty)

			# This is the hook you already have in enemy.gd
			enemy.init_from_pcg(params)

			# Optional debug log (comment out later if noisy)
			print("[PCG] ", difficulty, " enemy: ",
				enemy.name, " speed=", params["speed"],
				" pred=", params["prediction_offset"],
				" scatter=", params["scatter_time"]
			)
