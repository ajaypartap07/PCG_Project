extends EnemyAI
class_name EnemyAIAssassin


func __update_chase_target_position() -> void:
	chase_target_position = chase_target.global_position + (chase_target.direction * tile_size * 4)

func set_prediction_offset(value: int) -> void:
	prediction_offset = value

func set_scatter_time(value: float) -> void:
	scatter_duration = value
