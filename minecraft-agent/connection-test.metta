!(import! &self "utils.py")


!(py-call (utils.connectToMinecraft))

(= (getObservation)
   (py-call (utils.getObservation))
)

!(collapse(getObservation))

(= (executeAction $action)
   (py-call (utils.executeAction $action))
)

!(executeAction moveForward)

(= (getHungerLevel)
   (py-call (utils.getHungerLevel))
)

!(getHungerLevel)

(= (isNightTime)
   (py-call (utils.isNightTime))
)
!(isNightTime)

!(py-call (utils.disconnectFromMinecraft))
