from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass
from enum import Enum
import time


# Vereya Python API for Minecraft interaction
try:
    from tagilmo.utils.vereya_wrapper import MCConnector, RobustObserver
    import tagilmo.utils.mission_builder as mb
    VEREYA_AVAILABLE = True
except ImportError:
    VEREYA_AVAILABLE = False
    print("Warning: tagilmo not installed. Run: pip install git+https://github.com/trueagi-io/minecraft-demo.git")
    print("Using mock environment for development.")


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


class MockEnvironment:
    """Mock Minecraft environment for development without Vereya."""
    
    def __init__(self):
        self.position = (0.0, 64.0, 0.0)
        self.health = 20.0
        self.hunger = 20.0
        self.time = 6000
        self.connected = False
        
    def connect(self) -> bool:
        print(f"Connecting ...")
        time.sleep(0.5)
        self.connected = True
        print("Mock Connected to mock Minecraft environment")
        return True
    
    def disconnect(self):
        self.connected = False
        print("Mock Disconnected")
    
    def getObservation(self) -> Observation:
        self.hunger = max(0, self.hunger - 0.01)
        self.time = (self.time + 10) % 24000
        
        return Observation(
            position=self.position,
            health=self.health,
            hunger=self.hunger,
            isDay= (6000 <= self.time <= 18000),
            nearbyEntities=[
                {"type": "pig", "distance": 5.0, "position": (3, 64, 2)},
            ],
            nearbyBlocks=[
                {"type": "grass", "position": (0, 63, 0)},
                {"type": "dirt", "position": (0, 62, 0)},
            ],
            inventory=[
                {"item": "wooden_sword", "count": 1},
                {"item": "apple", "count": 3},
            ],
            timeOfDay=self.time
        )
    
    def executeAction(self, action: str, *args) -> bool:
        print(f"Executing: {action} with args: {args}")
        
        if action == "moveForward":
            x, y, z = self.position
            self.position = (x + 1, y, z)
        elif action == "eat":
            if self.hunger < 20:
                self.hunger = min(20, self.hunger + 4)
                print("Ate food, hunger restored")
        elif action == "chat":
            if args:
                print(f"Chat: {args[0]}")
        
        return True


class MinecraftBridge:
    def __init__(self):
        self.env = MockEnvironment()
        self.mcConnector = None  # will set to Vereya later
        self.connected = False
        self.lastObservation: Optional[Observation] = None
    
    def connect(self) -> bool:
        try:
            self.connected = self.env.connect()
            return self.connected
        except Exception as e:
            return False
    
    def disconnect(self):
        if self.connected:
            self.env.disconnect()
            self.connected = False
    
    def getObservation(self) -> Observation:
        if not self.connected:
            raise RuntimeError("Not connected to Minecraft")
        
        self.lastObservation = self.env.getObservation()
        return self.lastObservation
    
    def executeAction(self, action: str, *args) -> bool:

        if not self.connected:
            raise RuntimeError("Not connected to Minecraft")
        
        return self.env.executeAction(action, *args)
    
    def observationToMetta(self, obs: Observation) -> str:
        atoms = []
        
        # Position
        x, y, z = obs.position
        atoms.append(f"(At {x} {y} {z})")
        
        # Vitals
        atoms.append(f"(Health {obs.health})")
        atoms.append(f"(Hunger {obs.hunger})")
        atoms.append(f"(TimeOfDay {obs.timeOfDay})")
        atoms.append(f"(IsDay {obs.isDay})")
        
        for entity in obs.nearbyEntities:
            atoms.append(f"(NearEntity {entity['type']} {entity['distance']})")
        
        for item in obs.inventory:
            atoms.append(f"(HasItem {item['item']} {item['count']})")
        
        return " ".join(atoms)



bridge: Optional[MinecraftBridge] = None
def getBridge() -> MinecraftBridge:
    global bridge
    if bridge is None:
        bridge = MinecraftBridge()
    return bridge


def connectToMinecraft() -> str:
    bridge = getBridge()
    success = bridge.connect()
    return "Connected" if success else "Connection Failed"


def disconnectFromMinecraft() -> str:
    bridge = getBridge()
    bridge.disconnect()
    return "Disconnected"


def getObservation() -> str:
    bridge = getBridge()
    try:
        obs = bridge.getObservation()
        return bridge.observationToMetta(obs)
    except Exception as e:
        return f"(Error \"{e}\")"


def executeAction(action: str, *args) -> str:
    bridge = getBridge()
    try:
        success = bridge.executeAction(action, *args)
        return "Success" if success else "Failed"
    except Exception as e:
        return f"Failed: {e}"


def getHungerLevel() -> str:
    bridge = getBridge()
    try:
        obs = bridge.getObservation()
        return str(obs.hunger)
    except Exception as e:
        return "0"


def getHealthLevel() -> str:
    bridge = getBridge()
    try:
        obs = bridge.getObservation()
        return str(obs.health)
    except Exception as e:
        return "0"


def isNightTime() -> str:
    bridge = getBridge()
    try:
        obs = bridge.getObservation()
        return "True" if not obs.isDay else "False"
    except Exception as e:
        return "False"

