(= (decisionScore $name $value)
   (case $name
      (
         (clarity (+ $value (+ (fetchModulatorValue context_depth) (fetchModulatorValue caution))))
         (progress (+ $value (+ (fetchModulatorValue urgency) (fetchModulatorValue persistence))))
         (reliability (+ $value (+ (fetchModulatorValue caution) (fetchModulatorValue human_deference))))
         (adaptivity (+ $value (+ (fetchModulatorValue exploration_bias) (- 1 (fetchModulatorValue persistence)))))
         (coherence (+ $value (+ (fetchModulatorValue context_depth) (fetchModulatorValue human_deference))))
         (responsiveness (+ $value (+ (fetchModulatorValue urgency) (fetchModulatorValue human_deference))))
         ($_ $value)
      )
   )
)

(= (dominantMotive)
   (let* (
      ($clarity (fetchMotive clarity))
      ($progress (fetchMotive progress))
      ($reliability (fetchMotive reliability))
      ($adaptivity (fetchMotive adaptivity))
      ($coherence (fetchMotive coherence))
      ($responsiveness (fetchMotive responsiveness))
      ($candidates ($clarity $progress $reliability $adaptivity $coherence $responsiveness))
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
          ($headScore (decisionScore $headName $headVal))
          ($bestScore (decisionScore $bestName $bestVal))
       )
       (if (> $headScore $bestScore)
           (bestMotive $tail $head)
           (bestMotive $tail $best))))
)

(= (selectDecision)
   (let* (
      ((motive $name $value) (dominantMotive))
      ($score (decisionScore $name $value))
      ($decision
         (case $name
            (
               (clarity (decision clarity orient inspect $score))
               (progress (decision progress execute execute $score))
               (reliability (decision reliability verify verify $score))
               (adaptivity (decision adaptivity recover recover $score))
               (coherence (decision coherence orient inspect $score))
               (responsiveness (decision responsiveness execute execute $score))
               ($_ (decision clarity orient inspect 0.5))
            )
         ))
   )
   $decision)
)

(= (selectDirective)
   (let* (
      ((decision $motive $mode $directive $score) (selectDecision))
   )
   (directive $directive $mode $score))
)
