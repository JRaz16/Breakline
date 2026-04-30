class_name Util
## Auxiliary class containing useful static utility functions.

## Create a Vector2 from its string representation.
static func str_to_vec2(s:String) -> Vector2:
	s = s.trim_prefix("(")
	s = s.trim_suffix(")")
	var coords = s.split(",")
	return Vector2(int(coords[0]), int(coords[1]))
