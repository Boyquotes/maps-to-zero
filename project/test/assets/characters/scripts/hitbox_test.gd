
# GdUnit generated TestSuite
class_name HitboxTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://assets/characters/scripts/hitbox.gd'


var _hitbox: Hitbox
var _hitbox_character: Character


func before_test():
	_hitbox = auto_free(Hitbox.new()) as Hitbox
	
	# Set up hitbox character
	_hitbox_character = auto_free(Character.new()) as Character
	var stats := auto_free(CharacterStats.new()) as CharacterStats
	stats.set_max_stat(CharacterStats.Types.MP, 100)
	stats.set_stat(CharacterStats.Types.MP, 50)
	_hitbox_character._stats = stats
	
	_hitbox.set_character(_hitbox_character)


func test__ready() -> void:
	_hitbox._ready()
	assert_int(_hitbox.collision_layer, 0 | GameUtilities.PhysicsLayers.FLOORS_WALLS)
	assert_int(_hitbox.collision_mask, 0 | GameUtilities.PhysicsLayers.FLOORS_WALLS)


func test_set_character() -> void:
	assert_object(_hitbox._character).is_same(_hitbox_character)
	var character_2 := auto_free(Character.new()) as Character
	assert_object(_hitbox._character).is_not_same(character_2)
	_hitbox.set_character(character_2)
	assert_object(_hitbox._character).is_not_same(_hitbox_character)
	assert_object(_hitbox._character).is_same(character_2)


func test_set_team() -> void:
	_hitbox.set_team(GameUtilities.Teams.NEUTRAL)
	assert_int(_hitbox.team).is_equal(GameUtilities.Teams.NEUTRAL)
	_hitbox.set_team(GameUtilities.Teams.TEAM_1)
	assert_int(_hitbox.team).is_equal(GameUtilities.Teams.TEAM_1)
	_hitbox.set_team(GameUtilities.Teams.TEAM_2)
	assert_int(_hitbox.team).is_equal(GameUtilities.Teams.TEAM_2)


func test_confirm_hit() -> void:
	_hitbox.on_hit_resource_gain_type = CharacterStats.Types.MP
	_hitbox.on_hit_resource_gain_amount = 1
	var original_mp = _hitbox._character.get_stat(CharacterStats.Types.MP)
	
	# Setup character to hit
	var character_to_hit := auto_free(Character.new()) as Character
	
	# Test case
	var called_back := false
	_hitbox.hit.connect(func(hit_character: Character):
		called_back = true
		assert_object(hit_character).is_same(character_to_hit)
	)
	_hitbox.confirm_hit(character_to_hit)
	assert_bool(called_back, true)
	assert_float(_hitbox._character.get_stat(CharacterStats.Types.MP), \
			original_mp + _hitbox.on_hit_resource_gain_amount)


func test__reset_hitbox_collision() -> void:
	_hitbox._reset_hitbox_collision()
	assert_int(_hitbox.collision_layer, 0 | GameUtilities.PhysicsLayers.FLOORS_WALLS)
	assert_int(_hitbox.collision_mask, 0 | GameUtilities.PhysicsLayers.FLOORS_WALLS)


