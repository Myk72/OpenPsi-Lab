(= (directiveGuidance $directive)
   (case $directive
      (
         (inspect "Inspect first. Prefer reading, querying, and narrowing the problem before broader action.")
         (verify "Verify first. Check consistency and avoid making multiple changes before confidence improves.")
         (recover "Recover from failure. Diagnose the issue, avoid repeating the same pattern, and try an alternate strategy.")
         (execute "Execute normally. Advance the task directly while respecting current motivation state.")
         ($_ "Work normally while respecting current motivation state.")
      )
   )
)

(= (motivationContextBlock)
   (let* (
      ($_ (refreshSignals))
      ($_ (runMotivationUpdate))
      ($decision (selectDecision))
      ($_ (println! ("Selected Decision: " $decision)))
      ((decision $motive $mode $directive $score) $decision)
      ($_ (change-state! &last-motivation-decision $decision))
      ($_ (replaceMode $mode))
      ($signals (eval (string-safe (repr (getSignals)))))
      ($snapshot (eval (string-safe (repr (motivationSnapshot)))))
      ($decisionText (eval (string-safe (repr $decision))))
      ($guidance (directiveGuidance $directive))
      ; ($_ (println! ("Directive Guidance: " $guidance)))
   )
   (eval (py-str (" MOTIVATION_SIGNALS: " $signals
            " MOTIVATION_STATE: " $snapshot
            " MOTIVATION_DECISION: " $decisionText
            " STEP_POLICY: " $guidance)))
))

(= (getContext)
   (let* (
      ($motivationText (motivationContextBlock))
      ; ($_ (println! ("Motivation Context: " $motivationText)))
   )
   (eval (string-safe
      (eval (py-str (
               "PROMPT: " (eval (getPrompt))
               " SKILLS: " (eval (getSkills))
               " OUTPUT_FORMAT: Output a ((skillName1 args1) (skillName2 args2) (skillName3 args3) (skillName4 args4) (skillName5 args5)) S-expression of up to 5 sexpr commands, double-check the parentheses it must me (cmd1 ... cmdn)!"
               " each arg is an explicit string hence needs quotes, and variables are forbidden!"
               " LAST_SKILL_USE_RESULTS: " (eval (last_chars (get-state &lastresults) (maxFeedback)))
               " HISTORY: " (eval (getHistory))
               " TIME: " (eval (get_time_as_string))
               " MOTIVATION: " $motivationText
               ))
      )))
   )
)

(= (motivated-mettaclaw)
   (let* (
      ($_ (initMotivationState))
      ($_ (collapse (clearSignals)))
   )
   (eval (mettaclaw))))
