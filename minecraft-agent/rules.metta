!(bind! &ruleSpace (new-space))
!(bind! &demandspace (new-space))
!(add-atom &demandspace (demand hunger 0 10 8))
!(add-atom &demandspace (demand safety 0 10 9))
!(add-atom &demandspace (demand curiosity 0 10 3))
!(add-atom &demandspace (demand energy 0 10 10))


(= (goalSelector $x) (
  case $x (
    (hunger (Goal FindFood 1.0 0.9))
    (safety (Goal SeekShelter 1.0 0.9))
    (curiosity (Goal Explore 1.0 0.5))
  ))
)

