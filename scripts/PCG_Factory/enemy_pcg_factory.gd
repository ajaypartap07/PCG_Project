extends Node
class_name EnemyPCGFactory

# Dedicated RNG so we can control the seed per run / difficulty.
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func set_seed(seed: int) -> void:
	rng.seed = seed

# We keep this list for later (when we PCG AI types),
# but SOFT PCG won't actually swap AI scenes yet.
const AI_TYPES = [
	"EnemyAIAssassin",
	"EnemyAIBourrin",
	"EnemyAIChelou",
	"EnemyAICornichon"
]

# Difficulty-based parameter ranges.
# These are tuned around the original base_speed ≈ 2.35.
var difficulty_params := {
	"Easy": {
		"speed_min": 1.8, "speed_max": 2.2,

		# AI responsiveness
		"prediction_min": 1, "prediction_max": 2,

		# Timer durations
		"scatter_min": 4.0, "scatter_max": 6.0,
		"chase_min": 6.0,   "chase_max": 9.0,
		"frightened_min": 7.0, "frightened_max": 9.0,

		"frightened_speed_mult": 0.45,
		"direction_change_cooldown_min": 0.28,
		"direction_change_cooldown_max": 0.38,

		"spawn_delay_min": 0.0,
		"spawn_delay_max": 0.5,
	},

	"Medium": {
		"speed_min": 2.2, "speed_max": 2.6,

		"prediction_min": 3, "prediction_max": 5,

		"scatter_min": 3.0, "scatter_max": 5.0,
		"chase_min": 6.0,   "chase_max": 8.0,
		"frightened_min": 4.0, "frightened_max": 6.0,

		"frightened_speed_mult": 0.55,
		"direction_change_cooldown_min": 0.18,
		"direction_change_cooldown_max": 0.28,

		"spawn_delay_min": 0.0,
		"spawn_delay_max": 0.3,
	},

	"Hard": {
		"speed_min": 2.6, "speed_max": 3.2,

		"prediction_min": 4, "prediction_max": 8,

		"scatter_min": 2.0, "scatter_max": 4.0,
		"chase_min": 5.0,   "chase_max": 7.0,
		"frightened_min": 2.5, "frightened_max": 3.5,

		"frightened_speed_mult": 0.75,
		"direction_change_cooldown_min": 0.10,
		"direction_change_cooldown_max": 0.18,

		"spawn_delay_min": 0.0,
		"spawn_delay_max": 0.2,
	},
}

# Main generator: one config per enemy instance.
func generate_enemy(difficulty: String) -> Dictionary:
	var params: Dictionary = {}

	# SOFT PCG: no AI type swap yet, but we keep the field for later.
	params["ai_type"] = ""

	# Fallback to Medium if something weird comes in.
	var bounds: Dictionary = difficulty_params.get(difficulty, difficulty_params["Medium"])

	# SPEED
	params["speed"] = rng.randf_range(bounds["speed_min"], bounds["speed_max"])

	# PREDICTION OFFSET (how far ahead AI predicts the player)
	params["prediction_offset"] = rng.randi_range(
		bounds["prediction_min"],
		bounds["prediction_max"]
	)

	# SCATTER DURATION (seconds before switching back to chase)
	params["scatter_time"] = rng.randf_range(
		bounds["scatter_min"],
		bounds["scatter_max"]
	)
	# CHASE TIME (how long the chase will continue)
	params["chase_time"] = rng.randf_range(bounds["chase_min"], bounds["chase_max"])
	
	# FRIGHTENED TIME (how long the AI will stay frightened)
	params["frightened_time"] = rng.randf_range(bounds["frightened_min"], bounds["frightened_max"])
	
	# FRIGHTENED SPEED MULT (how fast the AI will go while frightened)
	params["frightened_speed_mult"] = bounds["frightened_speed_mult"]
	
	#
	params["direction_change_cooldown"] = rng.randf_range(
		bounds["direction_change_cooldown_min"], bounds["direction_change_cooldown_max"]
	)
	
	# Once sent back home, Spawn Delay dictates when they spawn
	params["spawn_delay"] = rng.randf_range(
		bounds["spawn_delay_min"], bounds["spawn_delay_max"]
	)

	return params
