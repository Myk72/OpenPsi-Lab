import time
import math
import sys
from typing import Tuple

try:
    import tagilmo.utils.mission_builder as mb
    from tagilmo.utils.vereya_wrapper import MCConnector, RobustObserver
    from navigation import Navigation
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
        self.gridBoundary = [[-10, 10], [-2, 3], [-10, 10]]
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
            time.sleep(5)
            return True
        return False

    def move(self, target_rel):
        currentPos = self.rob.getCachedObserve('getAgentPos')

        if not currentPos: 
            return False
        print("current position", currentPos)
        
        target_abs = (
            math.floor(currentPos[0]) + target_rel[0] + 0.5,
            math.floor(currentPos[1]) + target_rel[1],
            math.floor(currentPos[2]) + target_rel[2] + 0.5
        )
        
        print("Moving to target:", target_abs)
        
        last_dist = 999
        stuck_ticks = 0
        
        while True:
            self.rob.observeProcCached()
            curr = self.rob.getCachedObserve('getAgentPos')
            if not curr: 
                break
            
            dx = target_abs[0] - curr[0]
            dy = target_abs[1] - curr[1]
            dz = target_abs[2] - curr[2]
            dist_h = math.sqrt(dx*dx + dz*dz)
            
            
            if dist_h < 0.35 and abs(dy) < 1.0:
                self.rob.sendCommand("move 0")
                self.rob.sendCommand("turn 0")
                self.rob.sendCommand("jump 0")
                return True
            
            if abs(dist_h - last_dist) < 0.01:
                stuck_ticks += 1
            else:
                stuck_ticks = 0

            last_dist = dist_h
            
            if stuck_ticks > 100:
                print("Agent seems stuck, trying to jump...")
                self.rob.sendCommand("jump 1")
                time.sleep(0.2)
                self.rob.sendCommand("jump 0")
                stuck_ticks = 0

            if dy > 0.5:
                self.rob.sendCommand("jump 1")
            else:
                self.rob.sendCommand("jump 0")

            target_yaw = math.atan2(-dx, dz) * 180 / math.pi
            curr_yaw = curr[4]
            yaw_diff = (target_yaw - curr_yaw + 180) % 360 - 180
            
            if abs(yaw_diff) > 30:
                self.rob.sendCommand(f"turn {0.6 if yaw_diff > 0 else -0.6}")
                self.rob.sendCommand("move 0")
            else:
                self.rob.sendCommand("turn 0")
                self.rob.sendCommand("move 0.7")
            
            time.sleep(0.05)

    def run(self):
        if not self.connect(): 
            return
        
        self.rob.observeProcCached()
        raw_grid = self.rob.getCachedObserve('getNearGrid')

        if not raw_grid:
            print("Failed to get grid data.")
            return

        print("five sample example", raw_grid[:5])


        grid_map = Navigation.parseGrid(raw_grid, self.gridBoundary)
        print(f"Grid mapped. {len(grid_map)} blocks loaded.")
        print("Grid map sample:", list(grid_map.items())[:5])

        start = (0, 0, 0)
        target = (0, 1, 0)
        
        path = Navigation.aStar(start, target, grid_map)
        
        if path:
            print(f"Path found! Length: {len(path)} steps.")
            print(f"Steps: {path}")
            
            for step in path:
                print(f"Next step: {step}")
                if not self.move(step):
                    print("Navigation failed.")
                    break
        else:
            print("No path found to goal.")

if __name__ == "__main__":
    tester = PathfindingTester()
    tester.run()
