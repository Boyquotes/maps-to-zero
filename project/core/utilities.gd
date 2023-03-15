class_name Utilities
extends Node


static func get_all_children(node: Node, level: int = 0) -> Array[Node]:
	var nodes: Array[Node] = []
	var _level: int = level # retains local level property
	for n in node.get_children():
#		print_debug(".".repeat(_level) + n.name)
		nodes.append(n)
		if n.get_child_count() > 0:
			nodes.append_array(get_all_children(n, _level + 1))
	return nodes
