import time
import math
from typing import List, Dict, Any, Optional

from type import ActionType, Observation


try:
    import tagilmo.utils.mission_builder as mb
    from tagilmo.utils.vereya_wrapper import MCConnector, RobustObserver
    VEREYA_AVAILABLE = True
except ImportError:
    VEREYA_AVAILABLE = False
    
class VereyaEnvironment:
    def __init__(self):
        if not VEREYA_AVAILABLE:
            raise ImportError("Vereya modules not found")
            
        self.connected = False
        self.mc: Optional[MCConnector] = None
        self.rob: Optional[RobustObserver] = None
        
        self.obs = mb.Observations()
        self.agentHandlers = mb.AgentHandlers(observations=self.obs)
        
        self.agentSection = mb.AgentSection(name='PythonPlayer', agenthandlers=self.agentHandlers)
        self.mission = mb.MissionXML(agentSections=[self.agentSection])
        self.mission.serverSection.initial_conditions.allowedmobs = "Pig Sheep Cow Zombie Skeleton"
        
        self.mission.setWorld(mb.defaultworld(seed='12345'))

    def connect(self):
        print("Connecting to REAL Minecraft via Vereya ...")
        try:
            # clientIp should be of the host machine running Minecraft, adjust based on that
            self.mc = MCConnector(self.mission, clientIp='172.19.176.1') 
            self.rob = RobustObserver(self.mc)
            self.mc.safeStart()
            
            print("Mission accepted. Waiting for spawn...")
            time.sleep(2)
            self.connected = True
            return True
        except Exception as e:
            print(f"Failed to connect to Vereya: {e}")
            return False
            
    def disconnect(self):
        self.connected = False
        print("Vereya environment disconnected.")

    def getObservation(self) -> Observation:
        if not self.connected or not self.rob:
            return Observation((0,0,0), 0, 0, 0, 0.0, False, 0, [], [], [])
        
        self.rob.observeProcCached() 
        
        # Position
        pos = self.rob.getCachedObserve('getAgentPos') # [x, y, z, pitch, yaw]
        if pos:
            p = (pos[0], pos[1], pos[2])
            y = pos[4]
            pitch = pos[3]
        else:
             p = (0.0, 64.0, 0.0)
             y = 0.0
             pitch = 0.0

        # Vital Stats
        life = self.rob.getCachedObserve('getLife') or 20.0

        food = self.mc.getFullStat('Food')
        food = float(food) if food is not None else 20.0
        
        
        worldTime = self.mc.getFullStat('WorldTime')
        if worldTime is not None:
            worldTime = int(worldTime)
            # Day is roughly 0-12000, Night 12000-24000
            timeMod = worldTime % 24000
            is_day = timeMod < 12000
        else:
            worldTime = 6000
            is_day = True
            
        # Entities
        ents = self.rob.getCachedObserve('getNearEntities') or []
        parsedEnts = []
        for e in ents:
            ex, ey, ez = e.get('x', 0), e.get('y', 0), e.get('z', 0)
            dist = math.sqrt((ex-p[0])**2 + (ey-p[1])**2 + (ez-p[2]))
            parsedEnts.append({
                'type': e.get('name', 'unknown').lower(), 
                'distance': dist,
                'position': [ex, ey, ez]
            })

        rawInventory = self.rob.getCachedObserve('getInventory')
        inv = []
        if rawInventory:
            if isinstance(rawInventory, list):
                for item in rawInventory:
                    inv.append({
                        'item': item.get('type', 'unknown'),
                        'count': item.get('quantity', 1)
                    })
                    
        blocks = [] 
        
        return Observation(
            position=p,
            yaw=y,
            pitch=pitch,
            health=life,
            hunger=food,
            isDay=is_day,
            timeOfDay=worldTime, 
            inventory=inv,
            nearbyEntities=parsedEnts,
            nearbyBlocks=blocks
        )

    def executeAction(self, actionType: ActionType) -> str:
        if not self.connected:
            return "Not Connected"

        if actionType == ActionType.MOVE_FORWARD:
            self.rob.sendCommand('move 1')
            time.sleep(5) 
            self.rob.sendCommand('move 0')
            return "Moved Forward"
            
        elif actionType == ActionType.TURN_LEFT:
            self.rob.sendCommand('turn -0.5')
            time.sleep(0.2) 
            self.rob.sendCommand('turn 0')
            return "Turned Left"
            
        elif actionType == ActionType.TURN_RIGHT:
            self.rob.sendCommand('turn 0.5')
            time.sleep(0.2)
            self.rob.sendCommand('turn 0')
            return "Turned Right"
            
        elif actionType == ActionType.EAT:
            self.rob.sendCommand('use 1')
            time.sleep(1)
            self.rob.sendCommand('use 0')
            return "Ate"
            
        elif actionType == ActionType.ATTACK:
            self.rob.sendCommand('attack 1')
            time.sleep(0.5)
            self.rob.sendCommand('attack 0')
            return "Attacked"
            
        elif actionType == ActionType.PLACE:
            self.rob.sendCommand('use 1')
            time.sleep(0.2)
            self.rob.sendCommand('use 0')
            return "Placed"
            
        return "Action Sent"
