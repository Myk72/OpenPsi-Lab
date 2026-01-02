from utils import MockEnvironment

def main():
    env = MockEnvironment()
    env.connect()
    
    obs = env.getObservation()
    print(f"Observation: {obs}")

    print("Executing action: moveForward")
    env.executeAction("moveForward")
    print(f"New position: {env._position}")

    print("Executing action: eat")
    env.executeAction("eat")
    
    env.disconnect()

if __name__ == "__main__":
    main()
