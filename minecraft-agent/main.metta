!(import! &self "utils.py")

; !(import! &self ../demand)
; !(import! &self ../feedback-loop-ts)

!(import! &self perception)
!(import! &self rules)

!(bind! &kb (new-space))
!(bind! &perceptionSpace (new-space))
!(bind! &modulatorSpace (new-space))

!(bind! &ruleSpace (new-space))
!(bind! &demandspace (new-space))

(= (kbInitializer $kb)
   (let* (
      ($rules (collapse (get-atoms &ruleSpace)))
    ;   ($_ (println! (Rules: $rules)))
      ($modulators (collapse (get-atoms &modulatorSpace)))
    ;   ($_ (println! (Modulators: $modulators)))
      ($demands (collapse (get-atoms &demandspace)))
    ;   ($_ (println! (Demands: $demands)))
      ($partialKb (union-atom $rules $modulators))
      ($kbExp (union-atom $partialKb $demands))
      ($_ (collapse (add-atom $kb $kbExp)))
   )
   ()
   )
)


(= (initModulators)
   (let* (
      ($_ (add-atom &modulatorSpace (modulator SelectionThreshold 0.5)))
      ($_ (add-atom &modulatorSpace (modulator ActivationLevel 0.6)))
      ($_ (add-atom &modulatorSpace (modulator ResolutionLevel 0.5)))
      ($_ (add-atom &modulatorSpace (modulator SecuringThreshold 0.4)))
      ($_ (add-atom &modulatorSpace (modulator GoalChangeUrgency 0.3)))
   )
   ()
   )
)


(= (testPerception)
   (let* (
      ($_ (println! "Testing perception ..."))
      ; ($_ (update-perception &perception-space))
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

(= (addIndividualObservation $atoms $space)
   (if (== $atoms ())
      (empty)
      (let* (
         (($head $tail) (decons $atoms))
         ($expr (sread $head))
         ($_ (collapse (add-atom $space $expr)))
         ($_ (collapse (addIndividualObservation $tail $space)))
      )
      ()
      )
))

!(py-call (utils.connectToMinecraft))
!(addObservation &perceptionSpace)
; !(get-atoms &perceptionSpace)

!(initModulators)
!(collapse(addRules &ruleSpace))
!(kbInitializer &kb)
; !(get-atoms &kb)

; !(testPerception)
; !(testGoalSelection)
; !(testAction)


