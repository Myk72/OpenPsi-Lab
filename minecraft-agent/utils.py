from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass
from enum import Enum
import time
import math


## TEMPORARILY using MockEnvironment
## For real setup, we need to use Vereya API or Malmo Project
## To-do -> integrate with real Minecraft environment later

## ISSUES I FACED:
## Difficulties with their complexity and out-dated dependencies
## WSL host connection issues


class ActionType(Enum):
    """Symbolic actions the agent can perform."""
    MOVE_FORWARD = "moveForward"
    MOVE_BACKWARD = "moveBackward"
    TURN_LEFT = "turnLeft"
    TURN_RIGHT = "turnRight"
    JUMP = "jump"
    ATTACK = "attack"
    USE = "use"  # right-click action
    CRAFT = "craft"
    DIG = "dig"
    PLACE = "place"
    EAT = "eat"
    CHAT = "chat"


@dataclass
class Observation:
    """World state observation from Minecraft."""
    position: Tuple[float, float, float]  # x, y, z
    health: float
    hunger: float
    isDay: bool
    nearbyEntities: List[Dict[str, Any]]
    nearbyBlocks: List[Dict[str, Any]]
    inventory: List[Dict[str, Any]]
    timeOfDay: int
    yaw: float = 0.0
    pitch: float = 0.0


class MockEnvironment:
    """Mock Minecraft environment for development without Vereya."""
    
    def __init__(self):
        self.position = [0.0, 64.0, 0.0]
        self.health = 20.0
        self.hunger = 20.0
        self.timeOfDay = 6000
        self.connected = False
        self.yaw = 0.0
        self.pitch = 0.0

        self.inventory = [
            {"item": "wooden_sword", "count": 1},
            {"item": "bread", "count": 3}
        ]

        self.worldGrid = {
            (0, 63, 0): "grass_block",
            (0, 63, 1): "grass_block",
            (0, 63, 2): "grass_block",
            (1, 63, 0): "stone",
            (2, 63, 0): "diamond_ore",
            (3, 64, 3): "log" 
        }

        self.entities = [
            {"name": "pig", "x": 3.0, "y": 64.0, "z": 2.0, "health": 10.0},
            {"name": "cow", "x": -2.0, "y": 64.0, "z": -2.0, "health": 10.0}
        ]
        
    def connect(self) -> bool:
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
        agentX, agentY, agentZ = int(self.position[0]), int(self.position[1]) , int(self.position[2])
        nearbyBlocks = []

        # Scan a small area around the agent
        # for dx in range():
        #    for dy in range():
        #        for dz in range():

        # to implement later

        visibleEntities = []
        # Find nearby entities with min distance
        for entity in self.entities:
            dist = math.sqrt(
                (entity["x"] - self.position[0]) ** 2 +
                (entity["y"] - self.position[1]) ** 2 +
                (entity["z"] - self.position[2]) ** 2
            )
            if dist <= 10.0:
                visibleEntities.append({
                    "type": entity['name'],
                    "distance": round(dist, 2),
                    "position": [entity['x'], entity['y'], entity['z']]
                })
        
        return Observation(
            position=tuple(self.position),
            health=self.health,
            hunger=self.hunger,
            isDay= (0 <= self.timeOfDay < 12000),
            nearbyEntities=visibleEntities,
            nearbyBlocks=nearbyBlocks,
            inventory=self.inventory,
            timeOfDay=self.timeOfDay,
            yaw=self.yaw,
            pitch=self.pitch
        )
    
    def executeAction(self, action: str, *args) -> bool:
        print(f"Mock Action: {action} {args}")
        
        if action == "moveForward":
            # 0=South(+Z), 90=West(-X), 180=North(-Z), 270=East(+X)
            rad = math.radians(self.yaw)
            speed = 1.0 # blocks per action
            
            # dx = -sin(yaw)  (because 90 is -X)
            # dz = cos(yaw)   (because 0 is +Z)
            dx = -math.sin(rad) * speed
            dz = math.cos(rad) * speed
            
            self.position[0] += dx
            self.position[2] += dz
            
        elif action == "moveBackward":
            rad = math.radians(self.yaw)
            speed = 1.0
            dx = -math.sin(rad) * speed
            dz = math.cos(rad) * speed
            
            self.position[0] -= dx
            self.position[2] -= dz

        elif action == "turnLeft":
            self.yaw = (self.yaw - 45.0) % 360.0
            
        elif action == "turnRight":
            self.yaw = (self.yaw + 45.0) % 360.0

        elif action == "eat":
            for i, slot in enumerate(self.inventory):
                if slot['item'] in ["bread", "apple", "steak"]:
                    self.hunger = min(20.0, self.hunger + 4.0)
                    slot['count'] -= 1
                    if slot['count'] <= 0:
                        self.inventory.pop(i)
                    print("Ate food, hunger restored.")
                    break
                    
        elif action == "attack":
             closest = None
             minDist = 3.0
             for i, ent in enumerate(self.entities):
                 dist = math.sqrt((ent['x'] - self.position[0])**2 + (ent['y'] - self.position[1])**2 + (ent['z'] - self.position[2])**2)
                 if dist < minDist:
                     minDist = dist
                     closest = i
             
             if closest is not None:
                 ent = self.entities[closest]
                 ent['health'] -= 5.0
                 print(f"Attacked {ent['name']}!")
                 if ent['health'] <= 0:
                     print(f"{ent['name']} died!")
                     self.entities.pop(closest)

        elif action == "chat":
            if args:
                print(f"Agent says: {args[0]}")

        return True



mockEnv = MockEnvironment()

def getBridge() -> MockEnvironment:
    return mockEnv

def connectToMinecraft() -> str:
    success = mockEnv.connect()
    return "Connected" if success else "Failed"

def disconnectFromMinecraft() -> str:
    mockEnv.disconnect()
    return "Disconnected"

def getObservation() -> str:
    try:
        obs = mockEnv.getObservation()
        return observationToMetta(obs)
    except Exception as e:
        return f"(Error \"{e}\")"

def executeAction(action: str, *args) -> str:
    try:
        success = mockEnv.executeAction(action, *args)
        return "Success" if success else "Failed"
    except Exception as e:
        return f"Failed: {e}"

def getHungerLevel() -> str:
    try:
        return str(mockEnv.getObservation().hunger)
    except:
        return "0"

def getHealthLevel() -> str:
    try:
        return str(mockEnv.getObservation().health)
    except:
        return "0"

def isNightTime() -> str:
    try:
        return "True" if not mockEnv.getObservation().isDay else "False"
    except:
        return "False"

def observationToMetta(obs: Observation) -> str:
    x, y, z = obs.position
    atoms = []
    atoms.append(f"(at {x} {y} {z})")
    atoms.append(f"(yaw {obs.yaw:.1f})")
    atoms.append(f"(health {obs.health:.1f})")
    atoms.append(f"(hunger {obs.hunger:.1f})")
    atoms.append(f"(time {obs.timeOfDay})")
    atoms.append(f"(isDay {str(obs.isDay)})")
    
    for entity in obs.nearbyEntities:
        eType = entity['type']
        atoms.append(f"(nearEntity {eType})")
    
    for block in obs.nearbyBlocks:
         bType = block['type']
         atoms.append(f"(nearBlock {bType})")

    for item in obs.inventory:
        iType = item['item']
        count = item['count']
        atoms.append(f"(hasItem {iType} {count})")

    return atoms
    # return " ".join(atoms)

