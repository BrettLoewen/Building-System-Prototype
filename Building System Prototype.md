#Godot 

One of the core features I will need in Dragontown is a grid based building system.

## Starting

I took some screenshots of Into the Breach as that will be the main reference for the game's art and recreated its grass tile sprite in Aseprite.

I created a new Tile scene and added a sprite 2d node to it. I set the sprite's image to be the newly created tile sprite and set up the positions so the pivot of the Tile scene would be at the bottom center point of the tile sprite.

However, the sprite is rather blurry. I remember something about special import settings for pixel art so I guess I'll look into that. I found that the setting I want is found in Project Settings > General > Rendering > Textures and is Default Texture Filter. Its default value is Linear but for pixel art it should be Nearest. I changed to use Nearest and now the pixel looks nice. Good to know about this.

I created 4 instances of the tile scene in my currently empty Main scene to see how nicely the tiles would line up and work together. They fit together really nicely and were easy to position at whole coordinates so I think this is going to work out.

## Spawning Tiles

Now I need to start spawning them in via code. I created a main script to control the spawning. I added some variables to track the tiles and provide the necessary references and info.

I created a spawn tiles function and called it in ready. I looped through the dimensions of the grid I defined and spawned tiles and then added them to a dictionary. After some fiddling I got it working. The fiddling mainly included:
- Learning to use `range()` for the loop count
- Learning to use -y since it's inverted in 2D
- Figuring out how to print the number of elements in a dictionary
- Figuring out how to export vector2s
- Figuring out where to position the camera
- Figuring out the correct size of the tiles
- Learning that the only way to modify the position of the tiles was from inside a tile script
	- Actually turns out it can be done, but the position variable doesn't show up in intellisense, odd
	- I'll stick with a setup method because I might need it later for other purposes

I learned that the camera can be moved in the editor while the game is running and it affects the game so I used that to get a good camera position. I also learned there is a camera button in the scene editor toolbar which makes the editor camera control the game camera so that was also helpful.

Now they spawn in a grid, but not the kind of grid I want. They spawn with their points touching with gaps in between them since the tiles are isometric and they aren't spawned according to that. I'll need to adjust my spawn code to make them spawn isometrically.

I made offset vectors for the left and right directions each containing the distance the tile needs to move as it moves in the left and right directions. I then made left and right multipliers that are just the index of the loop minus 1 (left = y, right = x). I then multiplied the offsets by the multipliers and added the vectors together to get the position of the tiles. Using this new position for the tiles worked and they now spawn isometrically. Awesome.

Here's the code so far for spawning the tiles:
`Main.gd`:
```
extends Node2D

@export var tileScene: PackedScene			# Defines the tile that will be spawned
@export var gridSize := Vector2i(6, 6)		# Defines how many tiles will be spawned
@export var tileSize := Vector2i(56, 42)	# Defines how much space a tile takes up

# Stores references to all of the tiles
var tiles: Dictionary

# The Node that the tiles should be spawned as children of
@export var tileParent: Node2D

# Called to spawn the grid of tiles
func SpawnTiles():
	# Define how much the tiles need to move in order to sit beside each other correctly
	var rightOffset = Vector2i(tileSize.x/2, -tileSize.y/2)
	var leftOffset = Vector2i(-tileSize.x/2, -tileSize.y/2)
	
	# Loop through the grid and spawn all the tiles
	for x in range(gridSize.x):
		for y in range(gridSize.y):
			# Use the tile's grid position and the offsets to determine this tile's position
			var right = x - 1
			var left = y - 1
			var tilePos = (left * leftOffset) + (right * rightOffset)
			
			# Spawn the tile and set it's position
			var newTile = tileScene.instantiate()
			newTile.Setup(tilePos)
			tileParent.add_child(newTile)
			
			# Store references to the tiles for future calculations
			tiles[tilePos] = newTile
```

`Tile.gd`:
```
extends Node2D

func Setup(pos: Vector2):
	position = pos
```

## Tile Cursor

In order to be able to place a building on the tiles I'll need to know which tile the mouse is over. Ideally this would be accompanied by a visual change to highlight the tile that is currently being hovered over.

Into the Breach has different tile outline colors for normal tiles, edge tiles, and the currently selected tiles. I think something like this would work well for Dragontown and this prototype, so I'll go with this.

First I need to update the tile sprite and create some new art for the outlines. Then I can add more sprite nodes to the tile scene and I can enable and color them as needed.

I added new line layers to the sprite and exported them as individual images. I also adjusted the color of the lines that the base tile sprite has so they're less pronounced. I setup new sprite 2d nodes in the tile scene to display the lines and made an array in the tile script to reference them. I might need to switch to direct variables in the future, but I'm not sure, so I'll start with this.

I made the lines white so I can adjust their color at runtime to handle edges and selection. This should be doable using the sprite's parent node of canvas item and its visibility > modulate property, but I'll need to figure out how exactly to do this.

I created a setup lines method in the tile script and from it I call a setup line method 4 times, once for each line, passing it the necessary grid offset and array index for that line. I call this setup lines method from a loop through the tiles dictionary in the main script after spawning them all and pass the tiles dictionary through this series of functions.

If a line should not exist, I could use this code `lines[lineIndex].modulate = Color(0, 0, 0, 0)` to hide it and if it should exist, I could use very similar code to show it.

After some fiddling with the offsets for the lines, I got it working and they correctly display. I further tested this by adding skips into the spawn loop so some tiles are missing and those missing areas correctly had lines around them.

There is still an issue though which is that the tiles spawned later appear on top of the tiles spawned earlier which creates an issue where some lines are underneath other tiles. I think I should be able to fix this by setting the tiles' z position according to its spawn order but I'm not sure.

Node 2Ds don't actually have a z position since their position is a vector 2 but they do have a z index property in their canvas item parent node. I set this to the sum of their left and right grid positions and that improved the result but it still wasn't perfect. I modified the z value for the line sprites in the tile scene and made sure to leave the z as relative property enabled so now the lines will have their parent node's z index and then their own z index in addition to that. I gave each line a different index starting from the top left line at 1 and ending at the bottom right line at 4. I tested this, and now the lines all appear properly.

I tested a few more combinations of missing tiles and without any missing tiles, and it all seems to be working.

Now for setting up the currently hovered over tile display.

First I need to be able to detect which tile the mouse is hovering over. The easiest way to do this will be by using an area 2d node in the tile scene and connecting to its mouse entered signal. I made the node and a collision polygon node to define its collision shape. I set them up to overlap for now since that was the easiest way to make sure that the mouse would always be over at least one tile, so I'll see if I can something to work for this and I can change the collision shape later if needed.

I think the overlapping colliders will mean I can't just use the mouse entered signal and will also need to use the mouse exited signal. Otherwise the player could enter a new tile without exiting the first one, and then move back to the first one without re-entering it so the second tile would still be selected, which is not what I want. I might be able to setup a queue of some kind that tiles get added to when the mouse enters them and removed from when the mouse exits and then the tile at the front of the queue is always the selected tile. I'm going to try this approach first and see if it works.

GDScript apparently doesn't have a builtin queue data type like C# does but it does have push and pop methods for both the front and back on its Array class so I should be able to just use that. I setup an array for selected tiles and some methods to add and remove tiles from the array to get the behaviour I wanted. I then hooked up the mouse signals from the area 2d node to functions in the tile script and made those functions call the queue functions on the main script. I tested this with debug logs and it seemed to be working.

Sidenote: there are a few different print functions. I've been using `print_debug` and `printt`. I'm not sure about the differences and what other options exist, but these have worked so far.

I added a select and a deselect function to the tile script to show and hide the lines and called it from the main script's process function when the selected tile changes. I had to add some code to change the z index of the lines to ensure that they would always be on top of neighbouring tiles. Now it seems to be working properly.

Currently I'm just hardcoding all of the colors I'm using. I'd like to stop doing that and instead have a scriptable object for that. So I guess I now have to learn how to make and use custom resources.

I created a new script that inherits from Resource and defined some color variables. I created a new resource file using the resource class and then selected my Colors resource script from the script option in the inspector. I setup the colors as I wanted them. Then I loaded the resource in the tile script and used it to set the colors as needed. I tested it, and everything is working the same.

I cleaned up the code.

## Buildings

