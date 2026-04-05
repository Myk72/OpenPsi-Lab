
(= (clearSignals)
   (let* (
      ($signal (match &signal-space (signal $kind $strength) (signal $kind $strength)))
      ($_ (remove-atom &signal-space $signal))
   )
   ())
)

(= (addSignal $kind $strength)
   (add-atom &signal-space (signal $kind $strength))
)

(= (getSignals)
   (collapse (match &signal-space (signal $kind $strength) (signal $kind $strength)))
)
