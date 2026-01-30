from heapq import heappop, heappush
import math
from typing import List, Tuple, Dict, Optional, Set

class Navigation:
    walkableBlocks = {
        "air", "cave_air", "void_air", "grass", "tall_grass", 
        "poppy", "dandelion", "cornflower", "torch", "wall_torch",
        "oak_sapling", "wheat", "sugar_cane", "lever", "redstone_torch",
        "redstone_wire", "tripwire", "tripwire_hook", "rail"
    }
    
    @staticmethod
    def is_passable(blockType):
        return blockType in Navigation.walkableBlocks or "flower" in blockType or "fern" in blockType

    @staticmethod
    def getNeighbors(pos, gridMap):
        x, y, z = pos
        neighbors = []
        for dx, dz in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
            nx, nz = x + dx, z + dz
            
            for dy in [0, 1, -1]:
                ny = y + dy
                target = (nx, ny, nz)
                feet_above = (nx, ny + 1, nz)
                
                if target in gridMap and feet_above in gridMap:
                    if Navigation.is_passable(gridMap[target]) and Navigation.is_passable(gridMap[feet_above]):
                        below = (nx, ny - 1, nz)
                        if below in gridMap and not Navigation.is_passable(gridMap[below]):
                            if dy == 1:
                                if (x, y + 2, z) not in gridMap or Navigation.is_passable(gridMap[(x, y + 2, z)]):
                                    neighbors.append(target)
                            else:
                                neighbors.append(target)
        return neighbors

    @staticmethod
    def aStar(start, goal, grid_map):
        if start not in grid_map or goal not in grid_map:
            return None
        
        def heuristic(a, b):
            return abs(a[0] - b[0]) + abs(a[1] - b[1]) + abs(a[2] - b[2])

        heap = []
        heappush(heap, (0, start))
        visited = {}
        g_score = {start: 0}
        f_score = {start: heuristic(start, goal)}

        uniformCost = 1
        while heap:
            _, current = heappop(heap)

            if current == goal:
                path = []
                while current in visited:
                    path.append(current)
                    current = visited[current]
                    
                return path[::-1]

            for neighbor in Navigation.getNeighbors(current, grid_map):
                current_g_score = g_score[current] + uniformCost
                if neighbor not in g_score or current_g_score < g_score[neighbor]:
                    visited[neighbor] = current
                    g_score[neighbor] = current_g_score
                    f_score[neighbor] = current_g_score + heuristic(neighbor, goal)
                    heappush(heap, (f_score[neighbor], neighbor))
        
        return None

    @staticmethod
    def parseGrid(grid_list, grid_box):
        grid_map = {}
        sz_x = grid_box[0][1] - grid_box[0][0] + 1
        sz_y = grid_box[1][1] - grid_box[1][0] + 1
        sz_z = grid_box[2][1] - grid_box[2][0] + 1
        
        min_x, min_y, min_z = grid_box[0][0], grid_box[1][0], grid_box[2][0]
        
        idx = 0
        N = len(grid_list)
        for y_off in range(sz_y):
            for z_off in range(sz_z):
                for x_off in range(sz_x):
                    if idx < N:
                        pos = (min_x + x_off, min_y + y_off, min_z + z_off)
                        grid_map[pos] = grid_list[idx].replace("minecraft:", "")
                        idx += 1
        return grid_map
