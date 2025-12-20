;; PeTTa code

(= (import $name) (py-call (importlib.import_module $name)))
(= (get-attribute $obj $name) (py-call (getattr $obj $name)))

(= (eulerNumber) (get-attribute (import math) e))

; (= (round $x $d) 
;    (py-call ("round" $x $d)))

(= (np) (import numpy))
(= (np.random) (get-attribute (np) random))

(= (np-rand) 
   (py-call (".rand" (np.random))))

(= (np-randint $min $max) 
   (py-call (".randint" (np.random) $min $max)))

(= (np-beta $a $b $n)
    (py-call (".beta" (np.random) $a $b $n)))
   

