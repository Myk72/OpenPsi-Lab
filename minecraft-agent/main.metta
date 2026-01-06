!(import! &self "utils.py")
!(import! &self ../demand)
!(import! &self ../thompson-sampling-experiment/logic)
!(import! &self ../thompson-sampling-experiment/ts-algorithm)
!(import! &self ../feedback-helper)
;; !(import! &self ../feedback-loop-ts)

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
      ($modulators (collapse (get-atoms &modulatorSpace)))
      ($demands (collapse (get-atoms &demandSpace)))
      ($partialKb (union-atom $rules $modulators))
      ($kbExp (union-atom $partialKb $demands))
      ($_ (collapse (let $atom (superpose $kbExp) (add-atom $kb $atom))))
   )
   ()
   )
)


(= (initModulators)
   (
      let $modulators (superpose(
         (modulator SelectionThreshold 0.5)
         (modulator ActivationLevel 0.6)
         (modulator ResolutionLevel 0.5)
         (modulator SecuringThreshold 0.4)
         (modulator GoalChangeUrgency 0.3)
      ))
      (collapse (add-atom &modulatorSpace $modulators))
   )
)

(= (modulatorUpdaterAgent $space $comp $aff $ener)
   (let* (
      ;; just temporary placeholders for modulator update logic
      ($_ (println! "Modulators Updated"))
   )
   (Modulators Updated)
   )
)

(= (thompson-sampler $a $b $n) (
    np-beta $a $b $n))

(= (planner $space $init $goalName)
    (let* (
          ($rules (collapse (match $space 
              (: Rule $id $ttv $stv $comp 
                  (IMPLICATION 
                      (AND (Context $cstv (AND ((Goal $goalName $gStv)))) $action) 
                      $consequent
                  )
              )
              $id
          )))
          ($_ (println! (Applicable Rules for goal $goalName : $rules )))
          ($result (if (== $rules ())
             ()
             (let* (
                (($chosenId $score) (sampler $rules $space))
                ($actionAtom (getAction $chosenId $space))
                ;; Extract action name from (SEQ_AND (actionName))
                ((SEQ_AND ($actName)) $actionAtom)
             )
             ($actName)
             )
          ))
    )
    $result
    )
)

(= (cognitiveStep)
   (let* (
      ($_ (updatePerception &perceptionSpace))
      ($_ (perceptionToDemands &perceptionSpace &demandSpace))
      
      ($demands (queryAll &kb demand))
      ; ($_ (println! (Demands: $demands)))
      
      ($currDemand (fetchLeastSatisfiedDemand &demandSpace))
      ($_ (println! (Selected-Demand: $currDemand)))
      
      ((demand $demandName $minVal $maxVal $demandValue) $currDemand)
      
      ($goalObj (minecraftGoalSelector $demandName))
      ((Goal $goal $goalVal1 $goalVal2) $goalObj)
      ($_ (println! (Selected-Goal: $goal)))
      
      
      ($actions (planner &ruleSpace init $goal))
      ($_ (println! (Planned Actions: $actions)))
      
      ($result (if (== $actions ())
         ()
         (let $action (car-atom $actions)
            (performAction $action))))
      ($_ (println! (Action Result: $result)))
      
      ;; To be implemented later - Update modulators based on demands and action results
      ;; ($_ (modulatorUpdaterAgent &modulatorSpace $))
   )
   (Step-Complete)
   )
)


(= (cognitiveLoop $maxSteps $currentStep)
   (if (> $currentStep $maxSteps)
      ()
      (let* (
         ($_ (println! (Step $currentStep / $maxSteps)))
         ($_ (cognitiveStep))
      )
      (cognitiveLoop $maxSteps (+ $currentStep 1))
      )
   )
)


(= (runInteractive)
   (let* (
      ($_ (println! "Minecraft OpenPsi Agent"))
      ($_ (println! "Running in interactive mode"))
   )
   (cognitiveLoop 1 1)
   )
)


(= (testPerception)
   (let* (
      ($_ (println! "Testing perception ..."))
      ($_ (updatePerception &perception-space))
      ($hunger (hungerUrgency &perceptionSpace))
      ($safety (safetyLevel &perceptionSpace))
   )
   (println! (Hunger Urgency: $hunger Safety Level: $safety))
   )
)



(= (testAction)
   (let* (
      ($_ (println! "Testing action execution..."))
      ($result (performAction wander))
   )
   (println! (Action Result: $result))
   )
)

(= (addObservation $space) (
   let $atoms (py-call (utils.getObservation))
   (addIndividualObservation $atoms $space)
))


!(py-call (utils.connectToMinecraft vereya))
!(addObservation &perceptionSpace)
; !(collapse(get-atoms &perceptionSpace))

!(initModulators)
!(collapse(addMinecraftRules &ruleSpace))
!(collapse(kbInitializer &kb))
; !(collapse(get-atoms &kb))

!(runInteractive)

; !(testPerception)
; !(testGoalSelection)
; !(testAction)


