(ns lsystem.core
  (:gen-class))

(defn interpret-step
  "interpret a single command of a lindenmayer system"
  [ command ]
  (println command)
)

(defn process-step
  "processes a single step of a lindenmayer system"
  [ [sym & remainder] rules order ]

  (when sym
    (if (< order 1)
      (interpret-step sym)
      (let [ expansion (get rules sym) ]
        (if expansion
          (process-step expansion rules (dec order))
          (interpret-step sym))))
    (process-step remainder rules order)))

(defn -main
  "Lindenmayer systems!"
  [& args]
  (let [ start (seq (char-array "FX"))
         rules { \X (seq (char-array "X+YF+"))
                 \Y (seq (char-array "-FX-Y")) }
         order 5 ]
    (process-step start rules order)))
