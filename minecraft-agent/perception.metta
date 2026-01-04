;; Minecraft Agent Perception Module
;; Perception atoms follow these patterns:
;   (at $x $y $z)           - Agent position
;   (health $value)         - Health points (0-20)
;   (hunger $value)         - Hunger points (0-20)
;   (isDay $bool)           - Time of day
;   (nearEntity $type $dist) - Nearby entity
;   (hasItem $item $count)  - Inventory item
;   etc.


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

