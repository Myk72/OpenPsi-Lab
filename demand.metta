
(= (addDemand $space $name $minVal $maxVal $currentValue) (
    let* (
            ($demand (demand $name $minVal $maxVal $currentValue))
            ($_ (add-atom $space $demand))
        )
    ()
))


(= (fetchDemand $space $name) (
    match $space (demand $name $min $max $val) (demand $name $min $max $val)
))

(= (getDemandByName $space $name) (match $space (demand $name $min $max $val) (demand $name $min $max $val)))


(= (getAllDemands $space) (
    collapse (match $space (demand $name $min $max $val) (demand $name $min $max $val))
))




(= (getEnabledDemands $space) (
    let* (
    ;    ($skippedDemands (collapse (match $space (, (demand $x $min $max $v) (skip $x)) (demand $x $min $max $v)) ))
       ($allDemands (getAllDemands $space))
    ;    ($enabledDemands (collapse (subtraction  (superpose $allDemands)  (superpose $skippedDemands))))
    ) 
    $allDemands
))



(= (calculateDemandSatisfaction $space $demandName) (
    let* (
        ((demand $demandName $minVal $maxVal $currentValue) (fetchDemand $space $demandName))
        ($alpha (alpha))
    ) (if (and (>= $currentValue $minVal) (<= $currentValue $maxVal))
        (+ 0.8 (* 0.2 (random-float &rng 0 1)))
        (if (< $currentValue $minVal)
            (fuzzy_equal $currentValue $minVal $alpha)
            (+ 0.9 (* 0.1 (random-float &rng 0 1)))
        )
    )
))


(= (fetchLeastSatisfiedDemand' $space $demands $leastSatisfiedDemand)
    (if (== $demands ())
        $leastSatisfiedDemand
        (let* (
            (($currentDemand $restDemands) (decons-atom $demands))
            ((demand $currentName $currentMin $currentMax $currentValue) $currentDemand)
            ((demand $leastName $leastMin $leastMax $leastValue) $leastSatisfiedDemand)
            ($currentSatisfaction (calculateDemandSatisfaction $space $currentName))
            ($leastSatisfaction (calculateDemandSatisfaction $space $leastName))
        )
        (if (< $currentSatisfaction $leastSatisfaction)
            (fetchLeastSatisfiedDemand' $space $restDemands $currentDemand)
            (fetchLeastSatisfiedDemand' $space $restDemands $leastSatisfiedDemand)
        )
    )
))


(= (fetchLeastSatisfiedDemand $space) (
    let* (
        ($activeDemands (getEnabledDemands $space))
    ) (if (== $activeDemands ())
        ("No active demands found")
        (fetchLeastSatisfiedDemand' $space $activeDemands (car-atom $activeDemands))
    )
))

(= (updateDemandValue $space $demandName $newValue) (
    let* (
        ; ($_ (println! ("Updating Demand:" $demandName " to New Value:" $newValue)))
        ((demand $demandName $min $max $oldValue) (match $space (demand $demandName $min $max $oldValue) (demand $demandName $min $max $oldValue)))
        ($_ (remove-atom $space (demand $demandName $min $max $oldValue)))
        ($_ (add-atom $space (demand $demandName $min $max $newValue)))
    )
    ()
))



