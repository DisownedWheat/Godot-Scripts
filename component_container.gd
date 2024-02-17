class_name ComponentContainer
extends Node2D

@onready var _components: Dictionary = {}
@export var actor: Node


func _ready() -> void:
	if actor == null:
		actor = get_parent()

	child_entered_tree.connect(_on_component_added)
	child_exiting_tree.connect(_on_component_removed)

	for component: Node in get_children():
		_on_component_added(component)


## Returns the component or null if it wasn't found
func get_component(component_class: Variant) -> Node:
	return _components.get(component_class, null)


## Just chekcs for whether a component is present
func has(component_class: Variant) -> bool:
	return get_component(component_class) != null


## Adds a component to the container. It is recommended you use the actual name of
## the class you wish to add and if necessary use a ComponentScene wrapper class
## around a packed scene. You can pass in a PackedScene and it will still
## work but it may cause performance issues.
func add(component_class: Variant) -> bool:
	var component: Node
	if component_class is PackedScene:
		print(component_class)
		component = component_class.instantiate()
		if get_component(component.get_script()) != null:
			return false

	else:
		if get_component(component_class) != null:
			return false
		component = component_class.new()

	add_child(component)
	return true


## Removes a component from the container. It is recommended you use the actual name of
## the class you wish to add and if necessary use a ComponentScene wrapper class
## around a packed scene. You can pass in a PackedScene and it will still
## work but it may cause performance issues.
func remove(component_class: Variant) -> bool:
	var component: Node
	if component_class is PackedScene:
		var n: Node = component_class.instantiate()
		print(n.get_script())
		component = get_component(n.get_script())
		n.free()
	else:
		component = get_component(component_class)

	if component == null:
		return false

	remove_child(component)
	return true


## Triggers whenever a child is added to the component container in the scene tree
func _on_component_added(component: Node) -> void:
	var s: Script = component.get_script()
	if s == null:
		return
	if "actor" in s:
		component.actor = actor
	_components[s] = component


## Triggers whenever a child is removed from the component container in the scene tree
func _on_component_removed(component: Node) -> void:
	var s: Script = component.get_script()
	if s == null:
		return
	_components.erase(s)
