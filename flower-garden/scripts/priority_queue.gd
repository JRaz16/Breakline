class_name PriorityQueue
extends Object
## Simple heap-based min-priority queue

## Element type for differentiating the key (i.e., priority) from its corresponding data
class Element:
	var key
	var value
	func _init(k, v):
		key = k
		value = v

## Storage backed by a typed array
var heap:Array[Element]


## Initialize an empty queue
func _init() -> void:
	heap = []


## Reset the queue by removing all elements
func clear():
	heap.clear()


#region Observers

## Test for emptiness
func is_empty() -> bool:
	return heap.is_empty()


## Peek at the min-priority element
func front() -> Variant:
	return heap[0]

#endregion

#region Auxiliary observers

## Compute the index of the left-child in the heap
func left(i:int) -> int:
	return 2 * (i+1) - 1


## Compute the index of the parent in the heap
func parent(i:int) -> int:
	return floor((i - 1) / 2.0) # floor is redundant here, but retained for clarity of purpose


## Compute the index of the right-child in the heap
func right(i:int) -> int:
	return 2 * (i+1)

#endregion

#region Mutators

## Inserts an new element into the queue while preserving the heap property
func insert(x:Variant, priority:int) -> void:
	heap.push_back(null)
	update_key(heap.size() - 1, Element.new(priority, x))


## Removes and returns the element of the queue with the highest priority
func extract() -> Variant:
	if heap.size() < 1:
		return null # error “heap underflow”
	var extremum = heap[0].value
	heap[0] = heap.back()
	heap.pop_back()
	heapify(0)
	return extremum

#endregion

#region Auxiliary mutators

## Maintains the heap property by floating the root down to its proper position
func heapify(i:int) -> void:
	var l = left(i)
	var r = right(i)
	var extremum:int
	if l < heap.size() and heap[l].key < heap[i].key:
		extremum = l
	else:
		extremum = i
	if r < heap.size() and heap[r].key < heap[extremum].key:
		extremum = r
	if extremum != i:
		var tmp = heap[i]
		heap[i] = heap[extremum]
		heap[extremum] = tmp
		heapify(extremum)


## Updates the value of an element's key without violating the heap property
func update_key(i:int, elem:Element) -> void:
	#if heap[i][1] < x:
		#heapify(i)
		#return
	heap[i] = elem
	var j = parent(i)
	while i > 0 and heap[i].key < heap[j].key:
		var tmp = heap[i]
		heap[i] = heap[j]
		heap[j] = tmp
		i = j
		j = parent(i)

#endregion
