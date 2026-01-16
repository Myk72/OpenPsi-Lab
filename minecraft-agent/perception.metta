;; Minecraft Agent Perception Module

!(add-atom &demandSpace (demand hunger 0.0 1.0 0.5))
!(add-atom &demandSpace (demand safety 0.0 1.0 0.5))
!(add-atom &demandSpace (demand curiosity 0.0 1.0 0.5))
!(add-atom &demandSpace (demand energy 0.0 1.0 0.5))

(= (totalPoints) 20)

(= (removeOccurrences $space)
   (let $atoms (get-atoms $space)
        (remove-atom $space $atoms)
    )
)

(= (updatePerception $space)
   (let* (
      ($_ (collapse(removeOccurrences $space)))
      ; ($_ (println! (collapse (get-atoms $space))))
      ($obs (py-call (utils.getObservation)))
      ($_ (collapse (addIndividualObservation $obs $space)))
   )
   (perception Updated)
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


(= (getPosition $space)
   (match $space (at $x $y $z) (at $x $y $z)))
   
(= (getHealth $space)
   (match $space (health $h) $h))
   
(= (getHunger $space)
   (match $space (hunger $h) $h))
   
(= (isDaytime $space)
   (match $space (isDay $d) $d))
   
(= (getNearbyEntities $space $type)
   (collapse (match $space (nearEntity $type $dist) (nearEntity $type $dist))))
   
(= (hostileNearby $space)
   (let $hostiles (collapse (match $space (nearEntity $type $dist)
      (if (or (== $type zombie) 
              (or (== $type skeleton) 
                  (or (== $type spider) (== $type creeper))))
          True
          False)))
      (if (== $hostiles ()) 
         False 
         True  
      )
))


(= (hasItem $space $item)
   (let $found (collapse (match $space (hasItem $item $count) True))
      (if (== $found ()) False True)))

(= (getItemCount $space $item)
   (let $counts (collapse (match $space (hasItem $item $count) $count))
      (if (== $counts ()) 
         0 
         (car-atom $counts))
))


(= (hungerUrgency $space)
   (let $hunger (getHunger $space)
      (/ (- (totalPoints) $hunger) (totalPoints))))


(= (healthUrgency $space)
   (let $health (getHealth $space)
      (/ (- (totalPoints) $health) (totalPoints))))

(= (safetyLevel $space)
   (let* (
      ($isDay (isDaytime $space))
      ($hostileNear (hostileNearby $space))
      ($dayBonus (if $isDay 0.5 0.0)) ;; safer during day
      ($hostilePenalty (if $hostileNear 0.5 0.0))
   )
   (- (+ 0.5 $dayBonus) $hostilePenalty)))


(= (perceptionToDemands $perceptionSpace $demandSpace)
   (let* (
      ($hungerVal (hungerUrgency $perceptionSpace))
      ($healthUrg (healthUrgency $perceptionSpace))
      ($safetyLvl (safetyLevel $perceptionSpace))
      ; ($_ (println! ("demands: " $safetyLvl $hungerVal $healthUrg)))
      
      ($safetyVal (- 1.0 $safetyLvl))
      
      
      ((demand hunger $hMin $hMax $hOld) (getDemandByName $demandSpace hunger))
      ($__ (updateDemandValue $demandSpace hunger $hungerVal))
      
      ((demand safety $sMin $sMax $sOld) (getDemandByName $demandSpace safety))
      ($___ (updateDemandValue $demandSpace safety $safetyVal))

      ((demand energy $eMin $eMax $eOld) (getDemandByName $demandSpace energy))
      ($____ (updateDemandValue $demandSpace energy $healthUrg))
   )
   (Demands Updated)
   )
)


(= (isEdible $item)
   (case $item (
      (porkchop True)
      (cooked_porkchop True)
      (beef True)
      (cooked_beef True)
      (chicken True)
      (cooked_chicken True)
      (mutton True)
      (cooked_mutton True)
      (rabbit True)
      (cooked_rabbit True)
      (bread True)
      (apple True)
      (carrot True)
      (potato True)
      (baked_potato True)
      (golden_apple True)
      (melon_slice True)
      (sweet_berries True)
      (cookie True)
      ($_ False)
   )))


(= (hasEdibleFood $space)
   (let $foodItems (collapse 
      (match $space (hasItem $item $count)
         (if (isEdible $item) 
            ($item $count) 
            Empty)))
      (if (== $foodItems ()) 
         False 
         True)))


(= (getInventoryFood $space)
   (collapse 
      (match $space (hasItem $item $count)
         (if (isEdible $item) 
            (FoodItem $item $count) 
            Empty))))


(= (isFoodAnimal $type)
   (case $type (
      (pig True)
      (cow True)
      (sheep True)
      (chicken True)
      (rabbit True)
      ($_ False)
   )))


(= (hasFoodAnimalNearby $space)
   (let $animals (collapse 
      (match $space (nearEntity $type $dist)
         (if (isFoodAnimal $type)
            ($type $dist)
            Empty)))
      (if (== $animals ())
         False
         True)))

(= (getNearestFoodAnimal $space)
   (let $animals (collapse 
      (match $space (nearEntity $type $dist)
         (if (isFoodAnimal $type)
            ($type $dist)
            Empty)))
      (if (== $animals ())
         ()
         (car-atom $animals))))
