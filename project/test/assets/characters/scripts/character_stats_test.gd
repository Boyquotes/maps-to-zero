# GdUnit generated TestSuite
class_name CharacterStatsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://assets/characters/scripts/character_stats.gd'
const STAT_TYPE = CharacterStats.Types.HP

var _stats: CharacterStats
var _original_hp: float = 50.0
var _original_max_hp: float = 100.0


func before_test():
	_stats = auto_free(CharacterStats.new()) as CharacterStats
	_stats._stats[STAT_TYPE] = _original_hp
	_stats._max_stats[STAT_TYPE] = _original_max_hp


func test_set_stat() -> void:
	var target_value := 0.0
	_stats.set_stat(STAT_TYPE, target_value)
	var hp = _stats._stats[STAT_TYPE]
	assert_float(hp).is_equal(target_value)


func test_get_stat() -> void:
	var direct_hp = _stats._stats[STAT_TYPE]
	var get_stat_hp = _stats.get_stat(STAT_TYPE)
	assert_float(direct_hp).is_equal(get_stat_hp)


func test_change_stat_by() -> void:
	var target_hp_change_amount = _original_max_hp + 1
	var hp: float
	
	_stats.set_stat(STAT_TYPE, _original_hp)
	hp = _stats.change_stat_by(STAT_TYPE, target_hp_change_amount)
	assert_float(hp).is_equal(_original_max_hp)
	
	_stats.set_stat(STAT_TYPE, _original_hp)
	hp = _stats.change_stat_by(STAT_TYPE, target_hp_change_amount, true)
	assert_float(hp).is_equal(_original_max_hp)
	
	_stats.set_stat(STAT_TYPE, _original_hp)
	hp = _stats.change_stat_by(STAT_TYPE, target_hp_change_amount, false)
	assert_float(hp).is_equal(_original_hp + target_hp_change_amount)


func test_set_max_stat() -> void:
	var hp
	var max_hp
	var target_max_stat = 10
	
	_stats.set_max_stat(STAT_TYPE, target_max_stat)
	hp = _stats.get_stat(STAT_TYPE)
	assert_float(hp).is_equal(_original_hp)
	max_hp = _stats.get_max_stat(STAT_TYPE)
	assert_float(max_hp).is_equal(target_max_stat)
	
	_stats.set_max_stat(STAT_TYPE, target_max_stat, false)
	hp = _stats.get_stat(STAT_TYPE)
	assert_float(hp).is_equal(_original_hp)
	max_hp = _stats.get_max_stat(STAT_TYPE)
	assert_float(max_hp).is_equal(target_max_stat)
	
	_stats.set_max_stat(STAT_TYPE, target_max_stat, true)
	hp = _stats.get_stat(STAT_TYPE)
	assert_float(hp).is_equal(target_max_stat)
	max_hp = _stats.get_max_stat(STAT_TYPE)
	assert_float(max_hp).is_equal(target_max_stat)


func test_get_max_stat() -> void:
	assert_float(_stats._max_stats[STAT_TYPE]).is_equal(_stats.get_max_stat(STAT_TYPE))


func test_max_out() -> void:
	_stats.max_out(STAT_TYPE)
	assert_float(_stats.get_stat(STAT_TYPE)).is_equal(_stats.get_max_stat(STAT_TYPE))
