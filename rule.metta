(= (addRules $ruleSpace) (
    let $rules ( superpose (
        ;; Rule 1: init + report → mission_complete
        (: Rule 1
            (TTV 0)
            (STV 0.75 0.35)
            (Complexity 2)
            (IMPLICATION
                (AND
                    (Context
                        (STV 0.9 0.6)
                        (AND
                            ((init (STV 0.9 0.6)))
                        )
                    )
                    (Action
                        (SEQ_AND
                        (report)
                        )
                    )
                )
                (Goal
                    (STV 0.8 0.4)
                    (AND
                        (
                            (mission_complete (STV 0.8 0.4))
                        )
                    )
                )
            )
        )

        ;; Rule 2: init + email → mission_complete
        (: Rule 2
            (TTV 0)
            (STV 0.55 0.25)
            (Complexity 2)
            (IMPLICATION
                (AND
                    (Context
                        (STV 0.9 0.6)
                        (AND
                            ((init (STV 0.9 0.6)))
                        )
                    )
                    (Action
                        (SEQ_AND
                        (email)
                        )
                    )
                )
                (Goal
                    (STV 0.6 0.3)
                    (AND
                        (
                            (mission_complete (STV 0.6 0.3))
                        )
                    )
                )
            )
        )

        ;; Rule 3: init + idle → low_energy
        (: Rule 3
            (TTV 0)
            (STV 0.85 0.45)
            (Complexity 1)
            (IMPLICATION
                (AND
                    (Context
                        (STV 0.9 0.6)
                        (AND
                            ((init (STV 0.9 0.6)))
                        )
                    )
                    (Action
                        (SEQ_AND
                        (idle)
                        )
                    )
                )
                (Goal
                    (STV 0.9 0.5)
                    (AND
                        (
                            (low_energy (STV 0.9 0.5))
                        )
                    )
                )
            )
        ))
    )
    (add-atom $ruleSpace $rules)
))
