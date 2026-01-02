from typing import Dict, List, Any, Optional, Tuple
from dataclasses import dataclass
from enum import Enum
import time

from hyperon import MeTTa, Atom, ExpressionAtom, OperationAtom, ValueAtom
from hyperon.ext import register_atoms

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
        self._position = (0.0, 64.0, 0.0)
        self._health = 20.0
        self._hunger = 20.0
        self._time = 6000
        self._connected = False
        
    def connect(self) -> bool:
        print(f"Connecting ...")
        time.sleep(0.5)
        self._connected = True
        print("Mock Connected to mock Minecraft environment")
        return True
    
    def disconnect(self):
        self._connected = False
        print("Mock Disconnected")
    
    def getObservation(self) -> Observation:
        self._hunger = max(0, self._hunger - 0.01)
        self._time = (self._time + 10) % 24000
        
        return Observation(
            position=self._position,
            health=self._health,
            hunger=self._hunger,
            isDay= (6000 <= self._time <= 18000),
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
            timeOfDay=self._time
        )
    
    def executeAction(self, action: str, *args) -> bool:
        print(f"Executing: {action} with args: {args}")
        
        if action == "moveForward":
            x, y, z = self._position
            self._position = (x + 1, y, z)
        elif action == "eat":
            if self._hunger < 20:
                self._hunger = min(20, self._hunger + 4)
                print("Ate food, hunger restored")
        elif action == "chat":
            if args:
                print(f"Chat: {args[0]}")
        
        return True

