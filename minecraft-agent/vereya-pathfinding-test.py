import time
import math
import sys
from typing import Tuple
from navigation import Navigation

try:
    import tagilmo.utils.mission_builder as mb
    from tagilmo.utils.vereya_wrapper import MCConnector, RobustObserver
except ImportError:
    print("Error: 'tagilmo' library not found.")
    sys.exit(1)

class PathfindingTester:
    def __init__(self, ip="172.19.176.1"):
        self.ip = ip
        self.mc = None
        self.rob = None
        
        print("Configuring Pathfinding Mission ...")
        obs = mb.Observations(bAll=True)
        self.gridBoundary = [[-10, 10], [-2, 4], [-10, 10]]
        obs.gridNear = self.gridBoundary
        
        agent_handlers = mb.AgentHandlers(observations=obs)
        self.mission = mb.MissionXML(agentSections=[
            mb.AgentSection(name='Pathfinder', agenthandlers=agent_handlers)
        ])
        self.mission.setWorld(mb.defaultworld(seed='12345'))

    def connect(self):
        self.mc = MCConnector(self.mission, clientIp=self.ip)
        self.rob = RobustObserver(self.mc)
        if self.mc.safeStart():
            print("Connected to Minecraft server.")
            time.sleep(2)
            return True
        return False

    def getAgentPos(self):
        return self.rob.getCachedObserve('getAgentPos')

    def move(self, target_rel, tolerance=0.4):
        print(f"Moving to absolute target: {target_rel}")
        
        last_dist = 999
        stuck_ticks = 0

        timeout_ticks = 0
        MAX_TIMEOUT = 100
        
        while True:
            self.rob.observeProcCached()
            curr = self.getAgentPos()
            if not curr: 
                break
            
            dx = target_rel[0] - curr[0]
            dy = target_rel[1] - curr[1]
            dz = target_rel[2] - curr[2]
            dist_h = math.sqrt(dx*dx + dz*dz)
            
            
            if dist_h < tolerance and abs(dy) < 1.0:
                return True
            
            # STUCK DETECTION

            if abs(dist_h - last_dist) < 0.005:
                stuck_ticks += 1
            else:
                stuck_ticks = 0
            last_dist = dist_h
            
            if stuck_ticks > 50:
                print("Stuck! Attempting to ")
                self.rob.sendCommand("jump 1")
                self.rob.sendCommand("move -1")
                time.sleep(0.2)
                self.rob.sendCommand("move 1")
                stuck_ticks = 0
            
            timeout_ticks += 1
            if timeout_ticks > MAX_TIMEOUT:
                print("Movement timed out.")
                return False

            if dy > 0.5:
                self.rob.sendCommand("jump 1")
            else:
                self.rob.sendCommand("jump 0")

            target_yaw = math.atan2(-dx, dz) * 180 / math.pi
            curr_yaw = curr[4]
            yaw_diff = (target_yaw - curr_yaw + 180) % 360 - 180
            
            turn_speed = 0
            if abs(yaw_diff) > 10:
                turn_speed = max(0.3, min(abs(yaw_diff) / 45.0, 1.0))
                if yaw_diff < 0: 
                    turn_speed *= -1
            
            self.rob.sendCommand(f"turn {turn_speed}")

            if abs(yaw_diff) > 45:
                self.rob.sendCommand("move 0.2")
            else:
                self.rob.sendCommand("move 1")
            
            time.sleep(0.05)
        return False

    def run(self):
        if not self.connect(): return
        
        self.rob.observeProcCached()
        raw_grid = self.rob.getCachedObserve('getNearGrid')
        # print("some grid", raw_grid[:100])
        currentPos = self.getAgentPos()
        print(f"Current Position: {currentPos}")
        if not raw_grid or not currentPos:
            print("Failed to get initial data.")
            return

        grid_map = Navigation.parseGrid(raw_grid, self.gridBoundary)
        print(f"Map built with {len(grid_map)} nodes.")

        start = (0, 0, 0)
        target = (3, 0, 4)

        print(f"Block at Start {start}: {grid_map.get(start, 'UNKNOWN')}")
        print(f"Block under Start: {grid_map.get((0,-1,0), 'UNKNOWN')}")
        print(f"Block at Target {target}: {grid_map.get(target, 'UNKNOWN')}")
        print(f"Block under Target: {grid_map.get((0,-1,3), 'UNKNOWN')}")
        
        path = Navigation.aStar(start, target, grid_map)
        
        if path:
            print(f"Path found: {len(path)} steps.")
            
            base_x = math.floor(currentPos[0])
            base_y = math.floor(currentPos[1])
            base_z = math.floor(currentPos[2])

            for step_rel in path:
                target_abs = (
                    base_x + step_rel[0] + 0.5,
                    base_y + step_rel[1],
                    base_z + step_rel[2] + 0.5
                )
                
                if not self.move(target_abs):
                    print("Failed to reach segment.")
                    break
            
            self.rob.sendCommand("move 0")
            self.rob.sendCommand("turn 0")
            print("Destination reached.")
        else:
            print("No path found.")

if __name__ == "__main__":
    tester = PathfindingTester()
    tester.run()