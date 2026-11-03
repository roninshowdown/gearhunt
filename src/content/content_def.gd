class_name ContentDef
extends Resource
## Base class of everything loaded from res://content. `id` must equal the file
## name without extension; names and descriptions are translation keys.

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
