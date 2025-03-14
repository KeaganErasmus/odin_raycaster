package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

mapWidth :: 24
mapHeight :: 24
screenWidth :: 640
screenHeight :: 480

worldMap: [24][24]int = {
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 3, 0, 3, 0, 3, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 3, 0, 0, 0, 3, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 2, 2, 0, 2, 2, 0, 0, 0, 0, 3, 0, 3, 0, 3, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 4, 0, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 4, 0, 0, 0, 0, 5, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 4, 0, 4, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 4, 0, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
}

main :: proc() {
	using rl
	InitWindow(screenWidth, screenHeight, "Raycasting")

	pos: Vector2 = {22, 12}
	dir: Vector2 = {-1, 0}
	plane: Vector2 = {0, 0.66}
	SetTargetFPS(60)

	time: f32 = 0
	oldTime: f32 = 0
	w := screenWidth

	for !WindowShouldClose() {
		BeginDrawing()
		ClearBackground(BLACK)

		for x: i32 = 0; x < i32(w); x += 1 {
			cameraX: f32 = 2 * f32(x) / f32(w) - 1
			rayDir: Vector2 = {dir.x + plane.x * cameraX, dir.y + plane.y * cameraX}

			mapPos: Vector2 = {pos.x, pos.y}

			sideDist: Vector2

			deltaDist: Vector2 = {
				(rayDir.x == 0) ? 1e30 : math.abs(1 / rayDir.x),
				(rayDir.y == 0) ? 1e30 : math.abs(1 / rayDir.y),
			}

			perpWallDist: f32

			step: Vector2

			hit := 0
			side: int

			if rayDir.x < 0 {
				step.x = -1
				sideDist.x = (pos.x - mapPos.x) * deltaDist.x
			} else {
				step.x = 1
				sideDist.x = (mapPos.x + 1.0 - pos.x) * deltaDist.x
			}
			if rayDir.y < 0 {
				step.y = -1
				sideDist.y = (pos.y - mapPos.y) * deltaDist.y
			} else {
				step.y = 1
				sideDist.y = (mapPos.y + 1.0 - pos.y) * deltaDist.y
			}

			for hit == 0 {
				if sideDist.x < sideDist.y {
					sideDist.x += deltaDist.x
					mapPos.x += step.x
					side = 0
				} else {
					sideDist.y += deltaDist.y
					mapPos.y += step.y
					side = 1
				}

				if worldMap[i32(mapPos.x)][i32(mapPos.y)] > 0 {
					hit = 1
				}
			}

			if side == 0 {
				perpWallDist = (sideDist.x - deltaDist.x)
			} else {
				perpWallDist = (sideDist.y - deltaDist.y)
			}

			if perpWallDist <= 0 {
				perpWallDist = 1e-6
			}
			lineHeight := i32(screenHeight / perpWallDist)

			drawStart := -lineHeight / 2 + screenHeight / 2
			if drawStart < 0 {
				drawStart = 0
			}
			drawEnd := lineHeight / 2 + screenHeight / 2
			if drawEnd >= screenHeight {
				drawEnd = screenHeight - 1
			}

			color: Color
			switch worldMap[i32(mapPos.x)][i32(mapPos.y)] {
			case 1:
				color = RED
			case 2:
				color = GREEN
			case 3:
				color = BLUE
			case 4:
				color = WHITE
			case:
				color = YELLOW
			}

			if side == 1 {
				color = color / 2
			}

			DrawLine(x, drawStart, x, drawEnd, color)
		}

		oldTime = time
		frameTime := GetFrameTime()
		DrawFPS(10, 10)

		moveSpeed := frameTime * 5
		rotSpeed := frameTime * 5


		EndDrawing()
		if (IsKeyDown(.W)) {
			if (worldMap[int(pos.x + dir.x * moveSpeed)][int(pos.y)] ==
				   0) {pos.x += dir.x * moveSpeed}
			if (worldMap[int(pos.x)][int(pos.y + dir.y * moveSpeed)] ==
				   0) {pos.y += dir.y * moveSpeed}
		}

		if (IsKeyDown(.S)) {
			if (worldMap[int(pos.x + dir.x * moveSpeed)][int(pos.y)] ==
				   0) {pos.x -= dir.x * moveSpeed}
			if (worldMap[int(pos.x)][int(pos.y + dir.y * moveSpeed)] ==
				   0) {pos.y -= dir.y * moveSpeed}
		}

		//rotate to the right
		if (IsKeyDown(.RIGHT)) {
			//both camera direction and camera plane must be rotated
			oldDirX := dir.x
			dir.x = dir.x * math.cos(-rotSpeed) - dir.y * math.sin(-rotSpeed)
			dir.y = oldDirX * math.sin(-rotSpeed) + dir.y * math.cos(-rotSpeed)
			oldPlaneX := plane.x
			plane.x = plane.x * math.cos(-rotSpeed) - plane.y * math.sin(-rotSpeed)
			plane.y = oldPlaneX * math.sin(-rotSpeed) + plane.y * math.cos(-rotSpeed)
		}
		//rotate to the left
		if (IsKeyDown(.LEFT)) {
			//both camera direction and camera plane must be rotated
			oldDirX := dir.x
			dir.x = dir.x * math.cos(rotSpeed) - dir.y * math.sin(rotSpeed)
			dir.y = oldDirX * math.sin(rotSpeed) + dir.y * math.cos(rotSpeed)
			oldPlaneX := plane.x
			plane.x = plane.x * math.cos(rotSpeed) - plane.y * math.sin(rotSpeed)
			plane.y = oldPlaneX * math.sin(rotSpeed) + plane.y * math.cos(rotSpeed)
		}
	}
}
