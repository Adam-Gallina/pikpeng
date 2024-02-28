extends Node

@export var GeodeScene : PackedScene
@export var GeodeCols : Gradient
@export var GeodeColSteps : int
@onready var MineStrength : AbstractUpgrade = $MineStrength
@onready var ChuteStrength : AbstractUpgrade = $ChuteStrength
@onready var Value : AbstractUpgrade = $Value
@export var ResourceType : int

func generate(_rng:RandomNumberGenerator, d:int):
    var g = GeodeScene.instantiate()

    g.set_color(GeodeCols.sample(float(d % GeodeColSteps) / GeodeColSteps))

    g.set_strength(MineStrength.calc_at(d))
    g.set_geode_strength(ChuteStrength.calc_at(d))
    g.set_value(Value.calc_at(d))
    g.set_resource_type(ResourceType)


    return g