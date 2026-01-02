from utils import *

def main():
    result = connectToMinecraft()
    obs = getObservation()
    print(f"Observation: {obs}")
    
    actionStat = executeAction("moveForward")
    print(f"Action: {actionStat}")
    
    hunger = getHungerLevel()
    print(f"Hunger: {hunger}")
    
    is_night = isNightTime()
    print(f"Is Night: {is_night}")
    
    disconnectFromMinecraft()

if __name__ == "__main__":
    main()
