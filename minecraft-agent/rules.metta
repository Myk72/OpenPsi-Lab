
; !(bind! &ruleSpace (new-space))
; !(bind! &demandspace (new-space))

!(add-atom &demandspace (demand hunger 0 10 8))
!(add-atom &demandspace (demand safety 0 10 9))
!(add-atom &demandspace (demand curiosity 0 10 3))
!(add-atom &demandspace (demand energy 0 10 10))


(= (goalSelector $x) (
  case $x (
    (hunger (Goal FindFood 1.0 0.9))
    (safety (Goal SeekShelter 1.0 0.9))
    (curiosity (Goal Explore 1.0 0.5))
  ))
)

(= (addRules $space) (
  let $atoms (superpose(
    
    ;; Rule 1: Search Food
    (: r1
        (TTV 0)
        (STV 0.9 0.8)
        (Complexity 5)
        (IMPLICATION
            (AND
                (Context (STV 1.0 1.0) (AND (
                    (Goal FindFood (STV 1.0 0.9))
                )))
                (Action (SEQ_AND (searchForFood)))
            )
            (Goal (STV 1.0 0.8) (AND (
                (FoodLocated (STV 1.0 1.0))
            )))
        )
    )

    ;; Rule 2: Approach Food
    (: r2
        (TTV 0)
        (STV 0.85 0.8)
        (Complexity 4)
        (IMPLICATION
            (AND
                (Context (STV 1.0 1.0) (AND (
                    (Goal FoodLocated (STV 1.0 0.8))
                )))
                (Action (SEQ_AND (moveToFood)))
            )
            (Goal (STV 1.0 0.8) (AND (
                (FoodReached (STV 1.0 1.0))
            )))
        )
    )

    ;; Rule 3: Eat Food
    (: r3
        (TTV 0)
        (STV 0.95 0.9)
        (Complexity 6)
        (IMPLICATION
            (AND
                (Context (STV 1.0 1.0) (AND (
                    (Goal FoodReached (STV 1.0 0.8))
                )))
                (Action (SEQ_AND (eat)))
            )
            (Goal (STV 1.0 1.0) (AND (
                (SatisfyHunger (STV 1.0 1.0))
            )))
        )
    )

    ;; Rule 4: Heal By Eating
    (: r4
        (TTV 0)
        (STV 0.8 0.7)
        (Complexity 5)
        (IMPLICATION
            (AND
                (Context (STV 1.0 1.0) (AND (
                    (Goal RestoreHealth (STV 1.0 0.9))
                )))
                (Action (SEQ_AND (eat)))
            )
            (Goal (STV 1.0 0.9) (AND (
                (HealthRestored (STV 1.0 1.0))
            )))
        )
    )

    ;; Rule 5: Seek Shelter Night
    (: r5
        (TTV 0)
        (STV 0.9 0.85)
        (Complexity 6)
        (IMPLICATION
            (AND
                (Context (STV 1.0 1.0) (AND (
                    (Goal SeekShelter (STV 1.0 0.9))
                )))
                (Action (SEQ_AND (findShelter)))
            )
            (Goal (STV 1.0 0.8) (AND (
                (ShelterLocated (STV 1.0 1.0))
            )))
        )
    )

    ;; Rule 6: Enter Shelter
    (: r6
        (TTV 0)
        (STV 0.85 0.8)
        (Complexity 5)
        (IMPLICATION
            (AND
                (Context (STV 1.0 1.0) (AND (
                    (Goal ShelterLocated (STV 1.0 0.8))
                )))
                (Action (SEQ_AND (enterShelter)))
            )
            (Goal (STV 1.0 1.0) (AND (
                (InShelter (STV 1.0 1.0))
            )))
        )
    )

    ;; Rule 7: Flee Hostile
    (: r7
        (TTV 0)
        (STV 0.95 0.9)
        (Complexity 7)
        (IMPLICATION
            (AND
                (Context (STV 1.0 1.0) (AND (
                    (Goal SeekShelter (STV 1.0 0.9))
                )))
                (Action (SEQ_AND (flee)))
            )
            (Goal (STV 1.0 0.9) (AND (
                (SafeDistance (STV 1.0 1.0))
            )))
        )
    )

    ;; Rule 8: Build Barrier
    (: r8
        (TTV 0)
        (STV 0.7 0.6)
        (Complexity 4)
        (IMPLICATION
            (AND
                (Context (STV 1.0 1.0) (AND (
                    (Goal SeekShelter (STV 1.0 0.9))
                )))
                (Action (SEQ_AND (placeBlocks)))
            )
            (Goal (STV 1.0 0.7) (AND (
                (BarrierBuilt (STV 1.0 1.0))
            )))
        )
    )

    ;; Rule 9: Wander
    (: r9
        (TTV 0)
        (STV 0.6 0.5)
        (Complexity 3)
        (IMPLICATION
            (AND
                (Context (STV 1.0 1.0) (AND (
                    (Goal Explore (STV 1.0 0.5))
                )))
                (Action (SEQ_AND (wander)))
            )
            (Goal (STV 1.0 0.6) (AND (
                (NewAreaReached (STV 1.0 1.0))
            )))
        )
    )

    ;; Rule 10: Look Around
    (: r10
        (TTV 0)
        (STV 0.5 0.5)
        (Complexity 2)
        (IMPLICATION
            (AND
                (Context (STV 1.0 1.0) (AND (
                    (Goal Explore (STV 1.0 0.5))
                )))
                (Action (SEQ_AND (lookAround)))
            )
            (Goal (STV 1.0 0.5) (AND (
                (AreaSurveyed (STV 1.0 1.0))
            )))
        )
    )

    ;; Rule 11: Investigate
    (: r11
        (TTV 0)
        (STV 0.7 0.6)
        (Complexity 3)
        (IMPLICATION
            (AND
                (Context (STV 1.0 1.0) (AND (
                    (Goal Explore (STV 1.0 0.5))
                )))
                (Action (SEQ_AND (approachTarget)))
            )
            (Goal (STV 1.0 0.7) (AND (
                (TargetInvestigated (STV 1.0 1.0))
            )))
        )
    )

    ;; Rule 12: Gather Resources
    (: r12
        (TTV 0)
        (STV 0.8 0.7)
        (Complexity 4)
        (IMPLICATION
            (AND
                (Context (STV 1.0 1.0) (AND (
                    (Goal GatherResources (STV 1.0 0.7))
                )))
                (Action (SEQ_AND (dig)))
            )
            (Goal (STV 1.0 0.8) (AND (
                (ResourcesGathered (STV 1.0 1.0))
            )))
        )
    )

    ;; Rule 13: Collect Drops
    (: r13
        (TTV 0)
        (STV 0.85 0.75)
        (Complexity 4)
        (IMPLICATION
            (AND
                (Context (STV 1.0 1.0) (AND (
                    (Goal GatherResources (STV 1.0 0.7))
                )))
                (Action (SEQ_AND (collectItem)))
            )
            (Goal (STV 1.0 0.8) (AND (
                (ItemCollected (STV 1.0 1.0))
            )))
        )
    )

  ))
  (add-atom $space $atoms)
))


(= (performAction searchForFood)
   (py-call (utils.executeAction moveForward)))

(= (performAction $result) (
  case $result (
    ;; hardcoded actions for testing
    (searchForFood (py-call (utils.executeAction moveForward)))
    (moveToFood (py-call (utils.executeAction moveForward)))
    (eat (py-call (utils.executeAction eat)))
    (findShelter (py-call (utils.executeAction moveForward)))
    (enterShelter (py-call (utils.executeAction moveForward)))
    (placeBlocks (py-call (utils.executeAction place)))
    (lookAround (py-call (utils.executeAction turnLeft)))
    (approachTarget (py-call (utils.executeAction moveForward)))
    (dig (py-call (utils.executeAction dig)))
    (collectItem (py-call (utils.executeAction moveForward)))
  ))
)


(= (performAction wander)
   (let* (
      ($x (py-call (utils.executeAction turnLeft)))
      ; ($__ (println! $x))
      ($_ (py-call (utils.executeAction moveForward)))
   )
   (Wandered)))

(= (performAction flee)
   (let $result (py-call (utils.executeAction turnLeft))
      (py-call (utils.executeAction moveForward))))


(= (getRules) (collapse (get-atoms &ruleSpace)))
