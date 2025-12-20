!(import! &self logic)
!(import! &self rules)
!(import! &self ts-algorithm)
!(bind! &rule-space (new-space))

!(addRules &rule-space)
(= (thompson-sampler $a $b $n) (
    np-beta $a $b $n))
    
; !(get-atoms &rule-space)

; this is sample testing only
(= (executeAction $action $space) (
    let $rand (random-float &rng 0 1)
    (if (== $action (SEQ_AND (MOVE_RIGHT)))
        ;; Moving Right is generally good, but sometimes dangerous
        (if (> $rand 0.3) 1 0)
        (if (== $action (SEQ_AND (STAY)))
            (if (> $rand 0.9) 1 0)
            0.5
        )
    )
))

; !(executeAction (SEQ_AND (MOVE_RIGHT)) &rule-space)


(= (run-agent-loop $iter $context) (
    if (== $iter 0)
        (Done)
        (let* (
            ($candidates (matchRules $context &rule-space))
            ($_ (println! ("candidates: " $candidates)))

            ;; Thompson Sampling
            (($bestRule $score) (sampler $candidates &rule-space))
            ($_ (println! ("Selected Rule: " $bestRule " Score: " $score)))
            
            
            ($action (getAction $bestRule &rule-space))
            ($_ (println! ("Action: " $action)))
            ($result (executeAction $action &rule-space))
            ($_ (println! ("Result: " $result)))
            
            ($__ (updateRule $bestRule $result &rule-space))
            
            ; Simplified state transition for demo
            ($nextContext (
                if (== $action (SEQ_AND (MOVE_RIGHT))) 
                ((CENTER_SQUARE (STV 1.0 1.0)) (STILL_ALIVE (STV 1.0 1.0))) 
                $context))

            ($_ (println! ("Next Context: " $nextContext)))
        ) (run-agent-loop (- $iter 1) $nextContext))
))

!(run-agent-loop 2 ((LEFT_SQUARE (STV 1.0 1.0)) (STILL_ALIVE (STV 1.0 1.0))))