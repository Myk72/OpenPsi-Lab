from utils import *

def main():
    status = connectToMinecraft(mode="vereya")
    print(f"Connection Status: {status}")
    
    obs = getObservation()
    print(f"Observation Data: {obs}")
    
    atoms = observationToMetta(obs)
    print(f"MeTTa Atoms: {atoms}")
    
    action1 = executeAction('moveForward')
    print(f"Action Result 1: {action1}")
    
    action2 = executeAction('turnLeft')
    print(f"Action Result 2: {action2}")
    
    print(f"Hunger Level: {getHungerLevel()}")
    print(f"Is Day?: {isDay()}")
    
    
    print(f"{disconnectFromMinecraft()}")

if __name__ == "__main__":
    main()
