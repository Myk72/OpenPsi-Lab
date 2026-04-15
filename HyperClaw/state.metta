!(bind! &motivation-space (new-space))
!(bind! &signal-space (new-space))

(= (baselineMotive $name)
   (case $name
      (
         (clarity 0.45)
         (progress 0.55)
         (reliability 0.50)
         (adaptivity 0.40)
         (coherence 0.45)
         (responsiveness 0.45)
         ($_ 0.50)
      )
   )
)

(= (baselineModulator $name)
   (case $name
      (
         (urgency 0.50)
         (caution 0.50)
         (persistence 0.55)
         (exploration_bias 0.40)
         (context_depth 0.50)
         (human_deference 0.40)
         ($_ 0.50)
      )
   )
)

(= (clearMotivationState)
   (let* (
      ($atoms (get-atoms &motivation-space))
      ($_ (remove-atom &motivation-space $atoms))
   )
   ())
)

(= (initMotivationState)
   (let* (
      ($_ (collapse (clearMotivationState)))
      ($_ (println! "Initializing Motivation State with default motives and modulators..."))
      ($clarityBaseline (baselineMotive clarity))
      ($progressBaseline (baselineMotive progress))
      ($reliabilityBaseline (baselineMotive reliability))
      ($adaptivityBaseline (baselineMotive adaptivity))
      ($coherenceBaseline (baselineMotive coherence))
      ($responsivenessBaseline (baselineMotive responsiveness))
      ($urgencyBaseline (baselineModulator urgency))
      ($cautionBaseline (baselineModulator caution))
      ($persistenceBaseline (baselineModulator persistence))
      ($explorationBiasBaseline (baselineModulator exploration_bias))
      ($contextDepthBaseline (baselineModulator context_depth))
      ($humanDeferenceBaseline (baselineModulator human_deference))

      ($_ (add-atom &motivation-space (motive clarity $clarityBaseline)))
      ($_ (add-atom &motivation-space (motive progress $progressBaseline)))
      ($_ (add-atom &motivation-space (motive reliability $reliabilityBaseline)))
      ($_ (add-atom &motivation-space (motive adaptivity $adaptivityBaseline)))
      ($_ (add-atom &motivation-space (motive coherence $coherenceBaseline)))
      ($_ (add-atom &motivation-space (motive responsiveness $responsivenessBaseline)))
      ($_ (add-atom &motivation-space (modulator urgency $urgencyBaseline)))
      ($_ (add-atom &motivation-space (modulator caution $cautionBaseline)))
      ($_ (add-atom &motivation-space (modulator persistence $persistenceBaseline)))
      ($_ (add-atom &motivation-space (modulator exploration_bias $explorationBiasBaseline)))
      ($_ (add-atom &motivation-space (modulator context_depth $contextDepthBaseline)))
      ($_ (add-atom &motivation-space (modulator human_deference $humanDeferenceBaseline)))
      ($_ (add-atom &motivation-space (mode orient)))

      ($_ (change-state! &failure-streak 0))
      ($_ (change-state! &active-task ""))
      ($_ (change-state! &last-motivation-decision (decision clarity orient inspect 0.0)))

      ($_ (println! (collapse(get-atoms &motivation-space))))
   )
   ())
)

(= (fetchMotive $name)
   (match &motivation-space (motive $name $value) (motive $name $value))
)

(= (fetchMotiveValue $name)
   (let (motive $n $value) (fetchMotive $name) $value)
)

(= (fetchModulator $name)
   (match &motivation-space (modulator $name $value) (modulator $name $value))
)

(= (fetchModulatorValue $name)
   (let (modulator $n $value) (fetchModulator $name) $value)
)

(= (fetchMode)
   (match &motivation-space (mode $name) (mode $name))
)

(= (replaceMotive $name $newValue)
   (let* (
      ((motive $name $oldValue) (fetchMotive $name))
      ($_ (remove-atom &motivation-space (motive $name $oldValue)))
      ($_ (add-atom &motivation-space (motive $name $newValue)))
   )
   ())
)

(= (replaceModulator $name $newValue)
   (let* (
      ((modulator $name $oldValue) (fetchModulator $name))
      ($_ (remove-atom &motivation-space (modulator $name $oldValue)))
      ($_ (add-atom &motivation-space (modulator $name $newValue)))
   )
   ())
)

(= (replaceMode $newMode)
   (let* (
      ((mode $oldMode) (fetchMode))
      ($_ (remove-atom &motivation-space (mode $oldMode)))
      ($_ (add-atom &motivation-space (mode $newMode)))
   )
   ())
)

(= (getMotives)
   (collapse (match &motivation-space (motive $name $value) (motive $name $value)))
)

(= (getModulators)
   (collapse (match &motivation-space (modulator $name $value) (modulator $name $value)))
)

(= (motivationSnapshot)
   (state
      (getMotives)
      (getModulators)
      (fetchMode))
)
