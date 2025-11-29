extends Node2D

# Script auxiliar para criar sprites pixelados
# Usa Polygon2D e ColorRect para criar formas pixeladas

func create_pixel_rect(size: Vector2, color: Color, pixel_size: int = 4) -> Node2D:
	var container = Node2D.new()
	
	var width = int(size.x / pixel_size)
	var height = int(size.y / pixel_size)
	
	for x in range(width):
		for y in range(height):
			var pixel = ColorRect.new()
			pixel.position = Vector2(x * pixel_size, y * pixel_size)
			pixel.size = Vector2(pixel_size, pixel_size)
			pixel.color = color
			container.add_child(pixel)
	
	return container




