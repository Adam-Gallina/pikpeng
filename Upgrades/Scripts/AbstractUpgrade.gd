class_name AbstractUpgrade
extends Node

@export var level : int = 0
@export var base : float
@export var cost_upgrade : AbstractUpgrade

func calc():
	return calc_at(level)

func calc_at(_lvl : int):
	return base

func cost():
	return cost_upgrade.calc_at(level)

func copy_to(target : AbstractUpgrade):
	target.level = level
