;; Minecraft Agent Perception Module
;; Perception atoms follow these patterns:
;   (at $x $y $z)           - Agent position
;   (health $value)         - Health points (0-20)
;   (hunger $value)         - Hunger points (0-20)
;   (isDay $bool)           - Time of day
;   (nearEntity $type $dist) - Nearby entity
;   (hasItem $item $count)  - Inventory item

!(import! &self "utils.py")
!(bind! &perceptionSpace (new-space))
!(bind! totalPoints 20)

(= (removeOccurrences $space)
   (let $atoms (get-atoms $space)
        (remove-atom $space $atoms)
    )
)

(= (update-perception $space)
   (let* (
      ($_ (removeOccurrences $space (at $x $y $z)))
      ($_ (removeOccurrences $space (health $h)))
      ($_ (removeOccurrences $space (hunger $hun)))
      ($_ (removeOccurrences $space (isDay $d)))
      ($_ (removeOccurrences $space (nearEntity $t $dist)))
      ($_ (removeOccurrences $space (hasItem $i $c)))
      
      ($obs (py-call (getObservation))) ;; to be implemented later
      ($_ (add-atom $space $obs))
   )
   ()))


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
      (/ (- totalPoints $hunger) totalPoints)))


(= (healthUrgency $space)
   (let $health (getHealth $space)
      (/ (- totalPoints $health) totalPoints)))

(= (safetyLevel $space)
   (let* (
      ($isDay (isDaytime $space))
      ($hostileNear (hostileNearby $space))
      ($dayBonus (if $isDay 0.5 0.0)) ;; safer during day
      ($hostilePenalty (if $hostileNear 0.5 0.0))
   )
   (- (+ 0.5 $dayBonus) $hostilePenalty)))


(= (perceptionUpdater $perceptionSpace $demandSpace)
   (let* (
      ($hungerUrg (hungerUrgency $perceptionSpace))
      ($healthUrg (healthUrgency $perceptionSpace))
      ($safetyLvl (safetyLevel $perceptionSpace))
      
      ($hungerSatisfaction (- 1 $hungerUrg))
      ($safetySatisfaction $safetyLvl)
      
      ;; update demands
      ;; to be implement later
   )
   ()
   )
)

