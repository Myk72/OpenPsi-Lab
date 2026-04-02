!(import! &self "../python/bridge/utils.py")
!(import! &self ../../demand)
!(import! &self ../../feedback-helper)
!(import! &self utils)
!(import! &self ts-algorithm)

!(bind! &kb (new-space))
!(bind! &perceptionSpace (new-space))
!(bind! &modulatorSpace (new-space))
!(bind! &ruleSpace (new-space))
!(bind! &demandSpace (new-space))

!(import! &self perception)
!(import! &self rules)

(= (kbInitializer $kb)
   (let* (
      ($rules (collapse (get-atoms &ruleSpace)))
      ($demands (collapse (get-atoms &demandSpace)))
      ($kbExp (union-atom $rules $demands))
      ($_ (collapse (let $atom (superpose $kbExp) (add-atom $kb $atom))))
   )
   ()
   )
)

(= (cognitiveStep)
   (let* (
      ($_ (updatePerception &perceptionSpace))
      ($_ (perceptionToDemands &perceptionSpace &demandSpace))
      
      ($demands (queryAll &demandSpace demand))
      ($currDemand (getLeastSatisfiedDemandEpsilonGreedy &demandSpace 0.1))
      ((demand $demandName $minVal $maxVal $demandValue) $currDemand)
      ($goalObj (minecraftGoalSelector $demandName))
      ((Goal $goal $goalVal1 $goalVal2) $goalObj)
      ($_ (println! (Selected-Goal: $goal)))
      
      (($actions $id) (actionPlanner &ruleSpace $goal))
      ($_ (println! (Planned Actions: $actions)))

      ($result (
         if (== $actions ())
            ()
            (performAction $actions)
      ))
      ($_ (
         if (== $result ())
            ()
            (updateRule $id $result &ruleSpace)
         )
      )
   )
   (Step Completed)
   )
)


(= (cognitiveLoop $maxSteps $currentStep)
   (if (> $currentStep $maxSteps)
      ()
      (let* (
         ($_ (println! (Step $currentStep / $maxSteps)))
         ($_ (applyIterationEnvironment $currentStep))
         ($_ (cognitiveStep))
         ($_ (py-call (utils.sleepSeconds 0.35)))
      )
      (cognitiveLoop $maxSteps (+ $currentStep 1))
      )
   )
)


(= (runInteractive)
   (let $_ (println! (Minecraft OpenPsi Agent Starting ...))
   (cognitiveLoop 30 1))
)




(= (addObservation $space) (
   let $atoms (py-call (utils.getObservation))
   (addIndividualObservation $atoms $space)
))


!(py-call (utils.connectToMinecraft))
!(addObservation &perceptionSpace)

!(collapse(kbInitializer &kb))

!(runInteractive)
