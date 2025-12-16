;; PeTTa code

(= (import $name) (py-call (importlib.import_module $name)))
(= (get-attribute $obj $name) (py-call (getattr $obj $name)))


(= (round $x $d) 
   (py-call ("round" $x $d)))

(= (np) (import numpy))
(= (np.random) (get-attribute (np) random))

(= (np-rand) 
   (py-call (".rand" (np.random))))

(= (np-randint $min $max) 
   (py-call (".randint" (np.random) $min $max)))

(= (np-beta $a $b $n)
    (py-call (".beta" (np.random) $a $b $n)))
   

(= (thompson-sampler $a $b $n) (
    np-beta $a $b $n))







;; Optional code without PeTTa dependencies

; !(bind! np (py-atom numpy))

; (: generateNumpyBetaSamples (-> Number Number Number Expression))
; (= (generateNumpyBetaSamples $a $b $n)
;     ((py-dot np random.beta) $a $b $n))
    
; (: range (-> Number Number))
; (= (range $k) 
;    (if (> $k 0)
;        (superpose ((range (- $k 1)) (- $k 1)))
;        (empty)))


; (= (arrayToMettaAtom $numpyArray)
;    (let $pyList ((py-dot $numpyArray tolist))
;       (let $len ((py-dot $pyList __len__))
;           (collapse
;               (let $i (range $len)
;                    ((py-dot $pyList __getitem__) $i)
;               )
;           )
;       )
;    )
; )

; (= (thompson-sampler $a $b $n) (
;     arrayToMettaAtom (generateNumpyBetaSamples $a $b $n)))


; ; !(let $x (arrayToMettaAtom (generateNumpyBetaSamples 2 5 5))
; ;     $x
; ;  )