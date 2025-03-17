extends Marker3D

signal offset_changed

var offset = position :
	get:
		return offset
	set(o):
		offset = o
		offset_changed.emit(o)
