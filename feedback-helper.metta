
(= (goalSelector $demandName)
   (case $demandName (
      (affiliation (Goal mission_complete))
      (competence (Goal mission_complete))
      (energy (Goal mission_complete))
      (curiosity (Goal explore_unknown))
   ))
)

(= (update-atom $space $oatom $natom) (let $_ (remove-atom $space $oatom) (add-atom $space $natom)))

(= (sigmoid $x)
   (/ 1.0 (+ 1.0 (pow-math (eulerNumber) (* -1.0 $x))))
)


(= (normalizeWithSpecificRange $x $a $b)
   (if (and (>= $x $a) (<= $x $b)) $x (+ $a (* (- $b $a) (sigmoid $x))))
)

(= (fuzzy_equal $x $t $a)
   ( / 1 (+ 1 (* $a (* (- $x $t) (- $x $t)))))
)
(= (alpha) 150)

;; temporary function to check if action result matches goal
;; this is hardcoded for testing


(= (result-check (SEQ_AND ($action)) (Goal $gName))
    (if (== $gName explore_unknown) 1
    (if (or 
            (and (== $action found_target) (== $gName found_target))
            (or 
                (and (== $action approach) (== $gName near_target))
                (or 
                    (and (== $action interact) (== $gName task_done))
                    (or 
                        (or (and (== $action report) (== $gName mission_complete))
                            (and (== $action email) (== $gName mission_complete))
                        )
                        (or 
                            (and (== $action analyze) (== $gName analyze_data))
                            (or 
                                (and (== $action upload) (== $gName upload_results))
                                (and (== $action reboot) (== $gName reset_system))
                            )
                        )
                    )
                )
            )
        )
        1
        0
    ))
)

