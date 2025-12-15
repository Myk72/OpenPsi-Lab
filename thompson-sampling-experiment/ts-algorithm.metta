
!(bind! np (py-atom numpy))

(= (n_samples) 5)
(= (a) 2.0)
(= (b) 5.0)

(: generateNumpyBetaSamples (-> Number Number Number Expression))
(= (generateNumpyBetaSamples $a $b $n)
    ((py-dot np random.beta) $a $b $n))
    
(: range (-> Number Number))
(= (range $k) 
   (if (> $k 0)
       (superpose ((range (- $k 1)) (- $k 1)))
       (empty)))


(= (arrayToMettaAtom $numpyArray)
   (let $pyList ((py-dot $numpyArray tolist))
      (let $len ((py-dot $pyList __len__))
          (collapse
              (let $i (range $len)
                   ((py-dot $pyList __getitem__) $i)
              )
          )
      )
   )
)

(= (thompson-sampler $a $b $n_samples) (
    arrayToMettaAtom (generateNumpyBetaSamples $a $b $n_samples)))


; !(let $mettaStructure (arrayToMettaAtom (generateNumpyBetaSamples (a) (b) (n_samples)))
;     $mettaStructure
;  )