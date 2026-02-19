extends Object
## Various tests for 2D and 3D points
##
## Due to floating-point imprecision, we cannot get exact solutions in most
## situations when a point lies "on" a line, plane, or surface. To account
## for this, we use GDScrpit's is_zero_arrox() global function.

## Test where a point is in relation to a line.
##
## Returns an integer indicating whether a given point is on the line (zero)
## "below" the line (negative), or "above" the line (positive), relative to 
## the direction of the normal vector, n.
static func on_line(p:Vector2, e:Vector2, n:Vector2) -> int:
	var d:float = n.dot(p-e)
	return sign_approx(d)
	
static func on_line_fuzzy(p:Vector2, e:Vector2, n:Vector2, epsilon:float = 0) -> int:
	var d:float = n.dot(p-e)
	if d > epsilon:
		return 1
	elif d < -epsilon:
		return -1
	return 0

## Determines the sign of number
static func sign_approx(a:float) -> int:
	if is_zero_approx(a):
		return 0
	elif a > 0:
		return 1
	else:
		return -1
		
static func on_circle(p:Vector2, c:Vector2, r:float) -> int:
	var n:Vector2 = p - c
	var d:float = n.dot(n) - (r * r)
	return sign_approx(d)
