
;; this are simple formulas just for demonstration purposes, not based on any real psychological model
;; state = [M_clarity, M_reliability, M_adaptivity, M_progress, C_caution, P_persistence]
;; x = clamp(state + s.W_signal)

(= (clamp01 $value)
   (if (< $value 0.0)
       0.0
       (if (> $value 1.0) 1.0 $value))
)

(= (adjustMotive $name $delta)
   (let* (
      ($current (fetchMotiveValue $name))
      ($newValue (clamp01 (+ $current $delta)))
      ($_ (replaceMotive $name $newValue))
   )
   (motive $name $newValue))
)

(= (adjustModulator $name $delta)
   (let* (
      ($current (fetchModulatorValue $name))
      ($newValue (clamp01 (+ $current $delta)))
      ($_ (replaceModulator $name $newValue))
   )
   (modulator $name $newValue))
)

(= (applySignal $signal)
   (case $signal
      (
         (signal ambiguity $strength) (let* (
            ($_ (adjustMotive clarity (* 0.40 $strength)))
            ($_ (adjustModulator caution (* 0.15 $strength)))
            ($_ (replaceMode orient))
         )
         done)
         (signal failure $strength) (let* (
            ($_ (adjustMotive reliability (* 0.35 $strength)))
            ($_ (adjustMotive adaptivity (* 0.20 $strength)))
            ($_ (adjustModulator caution (* 0.25 $strength)))
            ($_ (replaceMode verify))
         )
         done)
         (signal repeated-failure $strength) (let* (
            ($_ (adjustMotive adaptivity (* 0.35 $strength)))
            ($_ (adjustModulator persistence (* -0.25 $strength)))
            ($_ (replaceMode recover))
         )
         done)
         (signal stalled-progress $strength) (let* (
            ($_ (adjustMotive progress (* 0.30 $strength)))
            ($_ (adjustMotive adaptivity (* 0.15 $strength)))
         )
         done)
         (signal verified-success $strength) (let* (
            ($_ (adjustMotive reliability (* -0.30 $strength)))
            ($_ (adjustMotive clarity (* -0.20 $strength)))
            ($_ (adjustModulator caution (* -0.15 $strength)))
            ($_ (replaceMode execute))
         )
         done)
         (signal progress-made $strength) (let* (
            ($_ (adjustMotive progress (* -0.25 $strength)))
            ($_ (adjustModulator persistence (* 0.10 $strength)))
         )
         done)
         (signal user-waiting $strength) (let* (
            ($_ (adjustMotive progress (* 0.10 $strength)))
         )
         done)
         ($other (empty)) ;; invalid signal
      )
   ))

(= (applySignals $signals)
   (if (== $signals ())
       ()
       (let* (
          (($head $tail) (decons-atom $signals))
          ($_ (applySignal $head))
       )
       (applySignals $tail)))
)

(= (runMotivationUpdate)
   (applySignals (getSignals))
)
