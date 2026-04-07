(= (stateLength $value)
   (eval (string_length (eval (string-safe (repr $value)))))
)

(= (syncSignalsFromMettaclawState)
   (let* (
      ($_ (collapse (clearSignals)))
      ($msgLen (stateLength (get-state &prevmsg)))
      ($_ (println! ("Motivation Signal Update: msgLen=" $msgLen)))
      ($resultLen (stateLength (get-state &lastresults)))
      ($_ (println! ("Motivation Signal Update: resultLen=" $resultLen)))
      ($errorLen (stateLength (get-state &error)))
      ($_ (println! ("Motivation Signal Update: errorLen=" $errorLen)))
      ($_ (if (> $errorLen 2)
              (progn
                 (addSignal failure 0.85)
                 (addSignal repeated-failure 0.55))
              _))
      ($_ (if (and (> $msgLen 2) (<= $resultLen 2))
              (addSignal ambiguity 0.55)
              _))
      ($_ (if (and (> $resultLen 2) (<= $errorLen 2))
              (progn
                 (addSignal progress-made 0.45)
                 (addSignal verified-success 0.25))
              _))
   )
   (getSignals))
)

(= (motivationPromptBlock)
   (let* (
      ($_ (syncSignalsFromMettaclawState))
      ($_ (runMotivationUpdate))
      ($signals (string-safe (repr (getSignals))))
      ($snapshot (string-safe (repr (motivationSnapshot))))
      ($directive (string-safe (repr (selectDirective))))
   )
   (py-str (" MOTIVATION_SIGNALS: " $signals
            " MOTIVATION_STATE: " $snapshot
            " RECOMMENDED_DIRECTIVE: " $directive
            " MOTIVATION_POLICY: Follow the recommended directive as a bias for tool use and reasoning, while still obeying the latest user request and using existing MeTTaClaw skills.")))
)

(= (baseMeTTaClawContext)
   (string-safe
      (py-str ("PROMPT: " (eval (getPrompt))
               " SKILLS: " (eval (getSkills))
               " OUTPUT_FORMAT: Output a ((skillName1 args1) (skillName2 args2) (skillName3 args3)) S-expression of up to 3 sexpr commands, double-check the parentheses it must me (cmd1 ... cmdn)!"
               " each arg is an explicit string hence needs quotes, and variables are forbidden!"
               " LAST_SKILL_USE_RESULTS: " (eval (last_chars (get-state &lastresults) (maxFeedback)))
               " HISTORY: " (eval (getHistory))
               " TIME: " (eval (get_time_as_string)))))
)

; Override MeTTaClaw context generation from the use-case layer so motivation
(= (getContext)
   (eval (string-safe (py-str ((baseMeTTaClawContext) (motivationPromptBlock)))))
)

(= (motivated-mettaclaw)
   (let* (
      ($_ (initMotivationState))
      ($_ (collapse (clearSignals)))
   )
   (eval (mettaclaw))))
