class_name ComponentScene
extends Node2D

@export var scene: PackedScene
var node: Node
var actor: Node2D

func _init() -> void:
	node = scene.instantiate()

func _ready() -> void:
	add_child(node)
	if "actor" in node:
		node.actor = actor
