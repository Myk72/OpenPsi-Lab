from utils import *

def main():
    status = connectToMinecraft()

    obs = getObservation()
    print("Observation 1" , obs)
    
    actionStat = executeAction("moveForward")
    print("Action Status: " , actionStat)
    
    obs2 = getObservation()
    print("Observation 2" , obs2)

    hunger = getHungerLevel()
    print("Hunger: " , hunger)
    
    isNight = isNightTime()
    print("Is Night: " , isNight)
    
    disconnectFromMinecraft()

if __name__ == "__main__":
    main()
