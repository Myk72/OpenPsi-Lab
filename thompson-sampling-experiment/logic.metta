!(import! &self ts-algorithm)

; c -> n
(= (confidenceToCount $confidence) (
    / (* $confidence 800) (- 1 $confidence)
))

; n -> c
(= (countToConfindence $count) (
    / $count (+ 800 $count)
))

; stv -> beta
(= (stvToBeta ($strength $confidence)) (
    let* (
        ($count (confidenceToCount $confidence))
        ($alpha (* $strength $count))
        ($beta (- $count $alpha))
    ) ($alpha $beta)
))

; beta -> stv
(= (betaToSTV ($alpha $beta)) (
    let* (
        ($count (+ $alpha $beta))
        ($strength (round (/ $alpha $count) 3))
        ($confidence (+ 0.001 (round (countToConfindence $count) 3)))
    ) ($strength $confidence)
))



(= (getSTV $ruleId $space) (
    match $space (: rule $ruleId $ttv (STV $s $c) $comp $impl) ($s $c)
))


(= (getAction $ruleId $space) (
    match $space (: rule $ruleId $ttv $stv $comp (IMPLICATION (AND $context (Action $action)) $goal)) $action
))



(= (getContextAtoms $ruleId $space) (
    match $space (: rule $ruleId $ttv $stv $comp (IMPLICATION (AND (Context $cstv (AND $atoms)) $action) $goal)) $atoms
))



(= (isContextApplicable $ruleContextAtoms $currentContext) (
    let* (
        ; ($_ (println! ("Rule Context Atoms: " $ruleContextAtoms)))
        ; ($_ (println! ("Current Context: " $currentContext)))
        ($common (intersection-atom $ruleContextAtoms $currentContext))
        ) (== (size-atom $common) (size-atom $ruleContextAtoms))
))


(= (matchRules $currentContext $space) (
    collapse (
        let* (
            ($ruleAtom (match $space (: rule $id $ttv $stv $comp (IMPLICATION (AND (Context $cstv (AND $ctxAtoms)) $action) $goal)) (: $id $ttv $stv $comp (IMPLICATION (AND (Context $cstv (AND $ctxAtoms)) $action) $goal))))
            ; ($_ (println! ("rules" $ruleAtom)))
            ((: $id $ttv $stv $comp (IMPLICATION (AND (Context $cstv (AND $ctxAtoms)) $action) $goal)) $ruleAtom)
            ; ($_ (println! ("Checking Rule ID:" $id " Context Atoms:" $ctxAtoms)))
            ($isMatch (isContextApplicable $ctxAtoms $currentContext))
            ; ($_ (println! ("Rule ID:" $id " Match:" $isMatch)))
        ) (if $isMatch $id (empty))
    )
))

(= (updateAtom $space $old $new) (
        let $_ (remove-atom $space $old) 
            (add-atom $space $new)))

(= (updateRule $ruleId $result $space) (
    let* (
        ($rule (match $space (: rule $ruleId $ttv (STV $s $c) $comp $impl) (: rule $ruleId $ttv (STV $s $c) $comp $impl)))
        ((: rule $id $ttv (STV $s $c) $comp $impl) $rule)

        (($alpha $beta) (stvToBeta ($s $c)))
        ($newAlpha (if (== $result 1) (+ $alpha 1) $alpha))
        ($newBeta (if (== $result 1) $beta (+ $beta 1)))
        (($ns $nc) (betaToSTV ($newAlpha $newBeta)))
        ($_ (println! ("New STV Params: (" $ns ", " $nc ")")))

        
        ($newRule (: rule $id $ttv (STV $ns $nc) $comp $impl))
        ($_ (println! ("Updating Rule ID: " $id " | Old STV: (" $s ", " $c ") | New STV: (" $ns ", " $nc ")")))
        ($_ (remove-atom $space $rule))
        ($_ (add-atom $space $newRule))
    ) (Empty)
))

; Thompson Sampling
(= (sampler $ids $space) (
    if (== () $ids)
        (-1 0)
        (let* (
            (($head $tail) (decons-atom $ids))
            (($s $c) (getSTV $head $space))
            (($alpha $beta) (stvToBeta ($s $c)))
            ; ($_ (println! ("Rule ID:" $head  " STV: (" $s ", " $c ") Beta Params: (" $alpha ", " $beta ")")))
            (($sample) (thompson-sampler $alpha $beta 1))
            ($_ (println! ("Rule id:" $head  "Sample:" $sample)))
            (($chosenId $chosenSample) (sampler $tail $space))
        ) (
            if (> $sample $chosenSample)
                ($head $sample)
                ($chosenId $chosenSample)
        ))
))

