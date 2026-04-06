
!(bind! &motivation-space (new-space))
!(bind! &signal-space (new-space))

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
      ;; motives play the role of demand 
      ($_ (add-atom &motivation-space (motive clarity 0.40)))
      ($_ (add-atom &motivation-space (motive progress 0.55)))
      ($_ (add-atom &motivation-space (motive reliability 0.45)))
      ($_ (add-atom &motivation-space (motive adaptivity 0.35)))

      ($_ (add-atom &motivation-space (modulator caution 0.50)))
      ($_ (add-atom &motivation-space (modulator persistence 0.50)))

      ($_ (add-atom &motivation-space (mode orient)))
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
