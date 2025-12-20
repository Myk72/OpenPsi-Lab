
(= (addRules $space) (
    let $atoms
        (superpose (
            (: Rule 1
                (TTV 0)
                (STV 0.5 0.002)  
                (Complexity 1)
                (IMPLICATION
                    (AND 
                        (Context (STV 1.0 1.0) (AND (
                            (LEFT_SQUARE (STV 1.0 1.0))
                            (STILL_ALIVE (STV 1.0 1.0)))))
                        (Action (SEQ_AND (MOVE_RIGHT)) ) )
                    (Goal (STV 1.0 1.0) (AND (
                            (CENTER_SQUARE (STV 1.0 1.0))
                            (STILL_ALIVE (STV 1.0 1.0)))
                )) 
            ))

            ;; Rule 2: Stay at Left Square (Bad idea usually)
            (: Rule 2
                (TTV 0)
                (STV 0.5 0.002)  
                (Complexity 1)
                (IMPLICATION
                    (AND 
                        (Context (STV 1.0 1.0) (AND (
                            (LEFT_SQUARE (STV 1.0 1.0))
                            (STILL_ALIVE (STV 1.0 1.0)))))
                        (Action (SEQ_AND (STAY)) ) )
                    (Goal (STV 1.0 1.0) (AND (
                            (LEFT_SQUARE (STV 1.0 1.0))
                            (STILL_ALIVE (STV 1.0 1.0)))
                )) 
            ))
            
            ;; Rule 3: Move Left from Center -> Left
            (: Rule 3
                (TTV 0)
                (STV 0.5 0.002)
                (Complexity 1)
                (IMPLICATION
                    (AND
                        (Context (STV 1.0 1.0) (AND (
                            (CENTER_SQUARE (STV 1.0 1.0))
                            (STILL_ALIVE (STV 1.0 1.0)))))
                        (Action (SEQ_AND (MOVE_LEFT))) )
                    (Goal (STV 1.0 1.0) (AND (
                            (LEFT_SQUARE (STV 1.0 1.0))
                            (STILL_ALIVE (STV 1.0 1.0)))
                    ))
            ))

            ;; Rule 4: Move Right from Center -> Right (Goal)
            (: Rule 4
                (TTV 0)
                (STV 0.5 0.002)
                (Complexity 1)
                (IMPLICATION
                    (AND
                        (Context (STV 1.0 1.0) (AND (
                            (CENTER_SQUARE (STV 1.0 1.0))
                            (STILL_ALIVE (STV 1.0 1.0)))))
                        (Action (SEQ_AND (MOVE_RIGHT))) )
                    (Goal (STV 1.0 1.0) (AND (
                            (RIGHT_SQUARE (STV 1.0 1.0))
                            (TRIUMPH (STV 1.0 1.0)))
                    ))
            ))
        ))
    (add-atom $space $atoms)
))