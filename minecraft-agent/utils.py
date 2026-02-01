import math
import re
import time
from typing import Optional

from type import ActionType, Observation
from mock_env import MockEnvironment
from vereya_env import VereyaEnvironment, VEREYA_AVAILABLE


currentEnv = None
currentMode = "mock"

def connectToMinecraft(mode="mock") -> str:
    global currentEnv
    global currentMode
    
    if VEREYA_AVAILABLE and mode == "vereya":
        try:
            env = VereyaEnvironment()
            if env.connect():
                currentEnv = env
                currentMode = "vereya"
                return "Connected to Vereya Minecraft"
        except Exception as e:
            print(f"Vereya connection failed: {e}")
    
    currentEnv = MockEnvironment()
    currentEnv.connect()
    return "Connected to Mock Environment"

def disconnectFromMinecraft() -> str:
    if currentEnv:
        currentEnv.disconnect()
    return "Disconnected"

def getObservation() -> list:
    if currentEnv:
        obs = currentEnv.getObservation()
        # return obs
        return observationToMetta(obs)
    return observationToMetta(Observation((0,0,0), 0, 0, 20.0, 20.0, True, 6000, [], [], []))

def executeAction(actionName: str, *args) -> str:
    print(f"Executing Action: {actionName} with args {args}")
    # print("is connected", not currentEnv)
    try:
        if not currentEnv:
            return "Not Connected"
        
        key = re.sub(r'(?<!^)(?=[A-Z])', '_', actionName).upper()
        actionMap = {
            "use": ActionType.USE,
            "crouch": ActionType.CROUCH,
            "drop": ActionType.DROP,
            "jump": ActionType.JUMP,
            "place": ActionType.PLACE,
            "dig": ActionType.DIG,
            "move_to": ActionType.MOVE_TO
        }
        
        # print("Mapped action key:", key)
        if actionName in actionMap and actionMap[actionName] == ActionType.MOVE_TO:
            # print("len of args:", len(args))
            if len(args) >= 3 and currentMode == "vereya" and hasattr(currentEnv, 'moveTo'):
                return currentEnv.moveTo(float(args[0]), float(args[1]), float(args[2]))
            return "MoveTo failed: insufficient args or mode"
            
        
        if hasattr(ActionType, key):
            act = getattr(ActionType, key)
            # print("Debugging line", act)
            return currentEnv.executeAction(act)
        else:
            if actionName == "chat":
                msg = args[0] if args else "Hello"
                if currentEnv and hasattr(currentEnv, 'rob') and currentEnv.rob:
                    currentEnv.rob.sendCommand(f"chat {msg}")
                    return f"Chatted: {msg}"
                return "Chat Failed: Not connected"
            
        if actionName in actionMap:
            target_action = actionMap[actionName]
            return currentEnv.executeAction(target_action)
        
        return f"Unknown Action {actionName}"


            
    except Exception as e:
        return f"Error executing {actionName}: {e}"


def observationToMetta(obs: Observation):
    atoms = []
    x, y, z = obs.position
    atoms.append(f"(at {x} {y} {z})")
    atoms.append(f"(yaw {obs.yaw})")
    atoms.append(f"(health {obs.health})")
    atoms.append(f"(hunger {obs.hunger})")
    atoms.append(f"(time {obs.timeOfDay})")
    atoms.append(f"(isDay {str(obs.isDay)})")
    
    if obs.nearbyEntities:
        for entity in obs.nearbyEntities:
            if isinstance(entity, dict):
                eType = entity.get('type', 'unknown')
                dist = entity.get('distance', 0)
                pos = entity.get('position', [0,0,0])
                atoms.append(f"(nearEntity {eType} {dist} {pos[0]} {pos[1]} {pos[2]})")


    if obs.nearbyBlocks:
         for block in obs.nearbyBlocks:
             bType = block.get('type', 'stone')
             atoms.append(f"(nearBlock {bType})")
             
    if obs.inventory:
        for item in obs.inventory:
            if isinstance(item, dict):
                iType = item.get('item', 'unknown')
                count = item.get('count', 1)
                atoms.append(f"(hasItem {iType} {count})")
                
    return atoms

def getHungerLevel() -> str:
    return str(getObservation().hunger)

def getHealth() -> str:
    return str(getObservation().health)

def isDay() -> str:
    return "True" if getObservation().isDay else "False"

def sortEntities(*args) -> list:
    if not args:
        return []
    data = list(args[0]) if len(args) == 1 and isinstance(args[0], (list, tuple)) else list(args)
    
    try:
        return sorted(data, key=lambda e: float(e[-1]) if isinstance(e, (list, tuple)) and len(e) > 0 else 0)
    except Exception as e:
        print(f"Error sorting entities in Python: {e}")
        return data


