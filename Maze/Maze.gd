extends Node3D

@onready var controlled = load("res://Player/Player.gd")
@onready var passive = load("res://Player/Player_Passive.gd")

const N = 1 					# binary 0001
const E = 2 					# binary 0010
const S = 4 					# binary 0100
const W = 8 					# binary 1000

var cell_walls = {
	Vector2(0, -1): N, 			# cardinal directions for NESW
	Vector2(1, 0): E,
	Vector2(0, 1): S, 
	Vector2(-1, 0): W
}

var map = []

var tiles = [
	preload("res://Maze/Tile0.tscn")	# all the tiles we created
	,preload("res://Maze/Tile1.tscn")
	,preload("res://Maze/Tile2.tscn")
	,preload("res://Maze/Tile3.tscn")
	,preload("res://Maze/Tile4.tscn")
	,preload("res://Maze/Tile5.tscn")
	,preload("res://Maze/Tile6.tscn")
	,preload("res://Maze/Tile7.tscn")
	,preload("res://Maze/Tile8.tscn")
	,preload("res://Maze/Tile9.tscn")
	,preload("res://Maze/Tile10.tscn")
	,preload("res://Maze/Tile11.tscn")
	,preload("res://Maze/Tile12.tscn")
	,preload("res://Maze/Tile13.tscn")
	,preload("res://Maze/Tile14.tscn")
	,preload("res://Maze/Tile15.tscn")
]

var tile_size = 2 						# 2-meter tiles
var dim_x = 6  						# width of map (in tiles)
var dim_z = 6  						# height of map (in tiles)

func _ready():
	randomize()
	make_maze()


func make_maze():
	var unvisited = []  # array of unvisited tiles
	var stack = []
	# fill the map with solid tiles
	for x in range(dim_x):
		map.append([])
		map[x].resize(dim_z)
		for z in range(dim_z):
			unvisited.append(Vector2(x, z))
			map[x][z] = N|E|S|W 		# 15
	var current = Vector2(0, 0)
	unvisited.erase(current)
	while unvisited:
		var neighbors = check_neighbors(current, unvisited)
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			stack.append(current)
			var dir = next - current
			var current_walls = map[current.x][current.y] - cell_walls[dir]
			var next_walls = map[next.x][next.y] - cell_walls[-dir]
			map[current.x][current.y] = current_walls
			map[next.x][next.y] = next_walls
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()
	map[0][0] &= N|E|S
	for x in range(dim_x):
		for z in range(dim_z):
			var tile = tiles[map[x][z]].instantiate()
			tile.position = Vector3(x*tile_size,0,z*tile_size)
			tile.name = "Tile" + str(x) + "_" + str(z)
			add_child(tile)



func check_neighbors(current, unvisited):
	# returns an array of cell's unvisited neighbors
	var list = []
	for n in cell_walls.keys():
		if current + n in unvisited:
			list.append(current + n)
	return list
