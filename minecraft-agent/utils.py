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
    try:
        if not currentEnv:
            return "Not Connected"
        
        key = re.sub(r'(?<!^)(?=[A-Z])', '_', actionName).upper()
        
        if hasattr(ActionType, key):
            act = getattr(ActionType, key)
            return currentEnv.executeAction(act)
        else:
            if actionName == "chat":
                msg = args[0] if args else "Hello"
                if currentEnv and hasattr(currentEnv, 'rob') and currentEnv.rob:
                    currentEnv.rob.sendCommand(f"chat {msg}")
                    return f"Chatted: {msg}"
                return "Chat Failed: Not connected"
            
            actionMap = {
                "use": ActionType.USE,
                "crouch": ActionType.CROUCH,
                "drop": ActionType.DROP,
                "jump": ActionType.JUMP,
                "place": ActionType.PLACE,
                "dig": ActionType.DIG
            }
            
            if actionName in actionMap:
                 return currentEnv.executeAction(actionMap[actionName])
            
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
                atoms.append(f"(nearEntity {eType} {dist})")

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
