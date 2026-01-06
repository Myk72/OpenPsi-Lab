import math
import time
from typing import List, Dict, Any

from type import ActionType, Observation

class MockEnvironment:
    def __init__(self):
        self.position = [10.0, 64.0, 10.0] # x, y, z
        self.yaw = 0.0
        self.pitch = 0.0
        self.health = 20.0
        self.hunger = 20.0
        self.timeOfDay = 6000
        
        self.inventory = [
            {"item": "wooden_sword", "count": 1},
            {"item": "bread", "count": 3}
        ]

        self.entities = [
            {'type': 'pig', 'distance': 5.0, 'position': [15.0, 64.0, 10.0]},
            {'type': 'zombie', 'distance': 15.0, 'position': [10.0, 64.0, -5.0]}
        ]

        self.worldGrid = {
            (0, 63, 0): "grass_block",
            (0, 63, 1): "grass_block",
            (0, 63, 2): "grass_block",
            (1, 63, 0): "stone",
            (2, 63, 0): "diamond_ore",
            (3, 64, 3): "log" 
        }
        
        self.connected = False
    def connect(self):
        print(f"Connecting ...")
        time.sleep(0.5)
        self.connected = True
        print("Connected to Mock Minecraft")
        return True
    
    def disconnect(self):
        self.connected = False
        print("Mock Disconnected")
        
    def getObservation(self) -> Observation:
        self.timeOfDay = (self.timeOfDay + 20) % 24000
        self.hunger = max(0.0, self.hunger - 0.005)
        
        return Observation(
            position=tuple(self.position),
            yaw=self.yaw,
            pitch=self.pitch,
            health=self.health,
            hunger=self.hunger,
            isDay= (0 <= self.timeOfDay < 12000),
            timeOfDay=self.timeOfDay,
            inventory=self.inventory,
            nearbyEntities=self.entities,
            nearbyBlocks=[
                {'type': self.worldGrid.get((0,63,0), "grass"), 'x': 0, 'y': 63, 'z': 0},
                {'type': self.worldGrid.get((0,63,1), "dirt"), 'x': 0, 'y': 63, 'z': 1},
            ]
        )

    def executeAction(self, actionType: ActionType) -> str:
        if not self.connected:
            return "Not Connected"
        
        if actionType == ActionType.MOVE_FORWARD:
            rad = math.radians(self.yaw)
            dx = -math.sin(rad)
            dz = math.cos(rad)
            self.position[0] += dx
            self.position[2] += dz
            return "Moved Forward"
            
        elif actionType == ActionType.TURN_LEFT:
            self.yaw -= 90
            return "Turned Left"
            
        elif actionType == ActionType.TURN_RIGHT:
            self.yaw += 90
            return "Turned Right"
            
        elif actionType == ActionType.EAT:
             self.hunger = min(20.0, self.hunger + 4)
             return "Ate Food"
             
        elif actionType == ActionType.ATTACK:
            return "Attacked"
            
        return "Action Done"
