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
    match $space (: Rule $ruleId $ttv (STV $s $c) $comp $impl) ($s $c)
))


(= (getAction $ruleId $space) (
    match $space (: Rule $ruleId $ttv $stv $comp (IMPLICATION (AND $context (Action $action)) $goal)) $action
))

(= (getContext $ruleId $space) (
    match $space (: Rule $ruleId $ttv $stv $comp (IMPLICATION (AND $context $action) $goal)) $context
))

(= (getContextAtoms $ruleId $space) (
    match $space (: Rule $ruleId $ttv $stv $comp (IMPLICATION (AND (Context $cstv (AND ($atoms))) $action) $goal)) $atoms
))

(= (matchContext $ruleId $context $space) (
    let* (
        ; ($_ (println! ("Matching Rule ID: " $ruleId " with Context: " $context)))
        ($ruleContext (getContextAtoms $ruleId $space))
        ; ($_ (println! ("Rule Context: " $ruleContext)))
        ($contextCount (size-atom ($context)))
        ($intersection (intersection-atom ($ruleContext) ($context)))
        ($matchCount (size-atom $intersection))
    ) (if (== $contextCount $matchCount)
        $ruleId
        Empty
    )
))

(= (isContextApplicable $ruleContextAtoms $currentContext) (
    let* (
        ; ($_ (println! ("Rule Context Atoms: " $ruleContextAtoms)))
        ; ($_ (println! ("Current Context: " $currentContext)))
        ($common (intersection-atom $ruleContextAtoms $currentContext))
        ) (== (size-atom $common) (size-atom $ruleContextAtoms))
))

(= (matchGoal $goalName $space) (
    collapse (match $space (: Rule $id $ttv $stv $comp (IMPLICATION $ant (Goal $gstv (AND (($goalName $gstv)))))) $id)
))


(= (matchContexts $ruleIds $context $space) (
    collapse (let $ruleId (superpose $ruleIds) (matchContext $ruleId $context $space))
))

(= (matchRules $currentContext $space) (
    collapse (
        let* (
            ($ruleAtom (match $space (: Rule $id $ttv $stv $comp (IMPLICATION (AND (Context $cstv (AND $ctxAtoms)) $action) $goal)) (: $id $ttv $stv $comp (IMPLICATION (AND (Context $cstv (AND $ctxAtoms)) $action) $goal))))
            ((: $id $ttv $stv $comp (IMPLICATION (AND (Context $cstv (AND $ctxAtoms)) $action) $goal)) $ruleAtom)
            ($isMatch (isContextApplicable $ctxAtoms $currentContext))
            ($_ (println! ("Rule ID:" $id " Match:" $isMatch)))
        ) (if $isMatch $id (empty))
    )
))

(= (updateAtom $space $old $new) (
        let $_ (remove-atom $space $old) 
            (add-atom $space $new)))

(= (round $x $d) 
   (py-call ("round" $x $d)))

(= (updateRule $ruleId $result $space) (
    let* (
        ($rule (match $space (: Rule $ruleId $ttv (STV $s $c) $comp $impl) (: Rule $ruleId $ttv (STV $s $c) $comp $impl)))
        ((: Rule $id $ttv (STV $s $c) $comp $impl) $rule)
        (($alpha $beta) (stvToBeta ($s $c)))
        ($newAlpha (if (== $result 1) (+ $alpha 1) $alpha))
        ($newBeta (if (== $result 1) $beta (+ $beta 1)))
        (($ns $nc) (betaToSTV ($newAlpha $newBeta)))
        ($_ (println! ("New STV Params: (" $ns ", " $nc ")")))

        
        ($newRule (: Rule $id $ttv (STV $ns $nc) $comp $impl))
        ($_ (println! ("Updating Rule ID: " $id " | Old STV: (" $s ", " $c ") | New STV: (" $ns ", " $nc ")")))
        ($_ (remove-atom $space $rule))
        ($_ (add-atom $space $newRule))
    ) ()
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



;; variance of Beta distribution
(= (getBetaVariance $alpha $beta) (
    let* (
        ($sum (+ $alpha $beta))
        ($numerator (* $alpha $beta))
        ($denominator (* (* $sum $sum) (+ $sum 1)))
    ) (/ $numerator $denominator)
))

;; Exploration Sampling: Select rule with highest variance (uncertainty)
(= (explorationSample $ruleIds $space) (
    if (== $ruleIds ())
        (-1 0)
    (let* (
        (($ruleId $rest) (decons-atom $ruleIds))
        ($_ (println! ("Exploration considering rule: " $ruleId)))
        (($strength $confidence) (getSTV $ruleId $space))
        (($alpha $beta) (stvToBeta ($strength $confidence)))
        ($variance (getBetaVariance $alpha $beta))
        ($_ (println! ("Rule " $ruleId " variance: " $variance)))
        (($chosenId $chosenVariance) (explorationSample $rest $space))
    ) (if (>= $variance $chosenVariance) 
        ($ruleId $variance) 
        ($chosenId $chosenVariance)
    ))
))

