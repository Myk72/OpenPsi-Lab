!(import! &self thompson-sampling-experiment/ts-algorithm)
!(import! &self thompson-sampling-experiment/logic)
!(import! &self feedback-helper)
!(import! &self demand)
!(import! &self rule)

!(bind! &kb (new-space))
!(bind! &demandSpace (new-space))
!(bind! &modulatorSpace (new-space))
!(bind! &ruleSpace (new-space))


; !(get-atoms &modulatorSpace)

(= (get-random $x $y)
    (np-randint $x $y))

;; Add Demands
!(addDemand &demandSpace affiliation -10 10 5)
!(addDemand &demandSpace competence -10 10 0)
!(addDemand &demandSpace energy -10 10 -9)
!(addDemand &demandSpace curiosity -10 10 0)

; !(get-atoms &demandSpace)

!(addRules &ruleSpace)

(= (kbInit) (
    let $demands (get-atoms &demandSpace)
    (add-atom &kb $demands)
))



;; Main loop with Thompson Sampling


(= (psi-agent-loop-ts $state $kb $ruleSpace $demandSpace $modulatorSpace)
    (let* (
        
        ($currDemand (fetchLeastSatisfiedDemand $kb))
        ($_ (println! (Current Demand: $currDemand)))
        ((demand $demandName $minVal $maxVal $demandValue) $currDemand)
        
        ($goalObj (goalSelector $demandName))
        ((Goal $goalName) $goalObj)
        ($_ (println! (Selected Goal: $goalName --> goalObj $goalObj)))

        ($applicableRules 
            (if (== $demandName curiosity)
                (matchRules $state $ruleSpace)
                (let* (
                    ($applicableGoalRules (matchGoal $goalName $ruleSpace))
                    ($_ (println! (Rules matching goal: $applicableGoalRules)))
                    ($res (matchContexts $applicableGoalRules $state $ruleSpace))
                ) $res)
        ))
        
        ($_ (println! (Rules matching context $state : $applicableRules)))
        
        ; ;; Sample a rule
        (($chosenRuleId $score) (if (== $demandName curiosity)
             (explorationSample $applicableRules $ruleSpace)
             (sampler $applicableRules $ruleSpace)
        ))
        ($_ (println! (Chosen Rule ID: $chosenRuleId Score: $score)))

    )
        (if (== $chosenRuleId -1)
            (println! (No rule selected))
            (let* (
                ($action (getAction $chosenRuleId $ruleSpace))
                ($_ (println! (Executing Action: $action)))
                
                ($isSuccess (result-check $action $goalObj)) 
                ($_ (println! (Action Success: $isSuccess)))
                
                
                ($__ (updateRule $chosenRuleId $isSuccess $ruleSpace))
                
                ;; Update Demand if success
                ($__ (if (== $isSuccess 1)
                        (let* (
                            ($newDemValue (+ $demandValue (* (- 1 $demandValue) 0.5)))
                            ($__ (updateDemandValue $demandSpace $demandName $newDemValue))
                            ) 
                            ()
                        )
                        (if (== $demandName curiosity)
                            (let* (
                                ($learningBonus (* $score 2.0))
                                ($newDemValue (+ $demandValue (* (- 1 $demandValue) $learningBonus)))
                                ($newDemValue (min $newDemValue 1.0))
                                ($__ (updateDemandValue $demandSpace $demandName $newDemValue))
                            ) ())
                            ()
                        )
                ))
                
            
                ($curiosityDemand (getDemandByName $demandSpace curiosity))
                ((demand curiosity $cMin $cMax $cVal) $curiosityDemand)
                ($boredomDecay 0.05)
                ($newCVal (max $cMin (- $cVal $boredomDecay)))
                ($__ (updateDemandValue $demandSpace curiosity $newCVal))
            ) 
            (Done)
            )
        )
    )
)


; !(get-atoms &demandSpace)
!(kbInit)
; !(get-atoms &kb)
!(psi-agent-loop-ts (init (STV 0.9 0.6)) &kb &ruleSpace &demandSpace &modulatorSpace)