(= (dominantMotive)
   (let* (
      ($clarity (fetchMotive clarity))
      ($progress (fetchMotive progress))
      ($reliability (fetchMotive reliability))
      ($adaptivity (fetchMotive adaptivity))
      ($candidates ($clarity $progress $reliability $adaptivity))
   )
   (bestMotive (cdr-atom $candidates) (car-atom $candidates)))
)

(= (bestMotive $rest $best)
   (if (== $rest ())
       $best
       (let* (
          (($head $tail) (decons-atom $rest))
          ((motive $headName $headVal) $head)
          ((motive $bestName $bestVal) $best)
       )
       (if (> $headVal $bestVal)
           (bestMotive $tail $head)
           (bestMotive $tail $best))))
)

(= (selectDirective)
   (let* (
      ((motive $name $value) (dominantMotive))
      ($mode (fetchMode))
      ($caution (fetchModulatorValue caution))
      ($persistence (fetchModulatorValue persistence))
   )
   (case $name
      (
         (clarity (directive inspect gather-context (+ $value $caution)))
         (progress (directive execute next-task-step (+ $value $persistence)))
         (reliability (directive verify check-output (+ $value $caution)))
         (adaptivity (directive recover change-strategy (+ $value (- 1 $persistence))))
         ($_ (directive orient review-state 0.5))
      )
   )
))
