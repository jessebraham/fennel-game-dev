; Global constants
(global blockSize     20)
(global blockDrawSize (- blockSize 1))
(global gridXCount    10)
(global gridYCount    18)
(global pieceXCount   4)
(global pieceYCount   4)
(global timerLimit    0.5)

; Global mutable state
(var inert         nil)
(var pieceRotation nil)
(var pieceType     nil)
(var pieceX        nil)
(var pieceY        nil)
(var sequence      nil)
(var timer         nil)

; ----------------------------------------------------------------------------

(global pieceStructures [
  ;i
  [
    [
      [" " " " " " " "]
      ["i" "i" "i" "i"]
      [" " " " " " " "]
      [" " " " " " " "]
    ]
    [
      [" " "i" " " " "]
      [" " "i" " " " "]
      [" " "i" " " " "]
      [" " "i" " " " "]
    ]
  ]
  ; o
  [
    [
      [" " " " " " " "]
      [" " "o" "o" " "]
      [" " "o" "o" " "]
      [" " " " " " " "]
    ]
  ]
  ; j
  [
    [
      [" " " " " " " "]
      ["j" "j" "j" " "]
      [" " " " "j" " "]
      [" " " " " " " "]
    ]
    [
      [" " "j" " " " "]
      [" " "j" " " " "]
      ["j" "j" " " " "]
      [" " " " " " " "]
    ]
    [
      ["j" " " " " " "]
      ["j" "j" "j" " "]
      [" " " " " " " "]
      [" " " " " " " "]
    ]
    [
      [" " "j" "j" " "]
      [" " "j" " " " "]
      [" " "j" " " " "]
      [" " " " " " " "]
    ]
  ]
  ; l
  [
    [
      [" " " " " " " "]
      ["l" "l" "l" " "]
      ["l" " " " " " "]
      [" " " " " " " "]
    ]
    [
      [" " "l" " " " "]
      [" " "l" " " " "]
      [" " "l" "l" " "]
      [" " " " " " " "]
    ]
    [
      [" " " " "l" " "]
      ["l" "l" "l" " "]
      [" " " " " " " "]
      [" " " " " " " "]
    ]
    [
      ["l" "l" " " " "]
      [" " "l" " " " "]
      [" " "l" " " " "]
      [" " " " " " " "]
    ]
  ]
  ; t
  [
    [
      [" " " " " " " "]
      ["t" "t" "t" " "]
      [" " "t" " " " "]
      [" " " " " " " "]
    ]
    [
      [" " "t" " " " "]
      [" " "t" "t" " "]
      [" " "t" " " " "]
      [" " " " " " " "]
    ]
    [
      [" " "t" " " " "]
      ["t" "t" "t" " "]
      [" " " " " " " "]
      [" " " " " " " "]
    ]
    [
      [" " "t" " " " "]
      ["t" "t" " " " "]
      [" " "t" " " " "]
      [" " " " " " " "]
    ]
  ]
  ; s
  [
    [
      [" " " " " " " "]
      [" " "s" "s" " "]
      ["s" "s" " " " "]
      [" " " " " " " "]
    ]
    [
      ["s" " " " " " "]
      ["s" "s" " " " "]
      [" " "s" " " " "]
      [" " " " " " " "]
    ]
  ]
  ; z
  [
    [
      [" " " " " " " "]
      ["z" "z" " " " "]
      [" " "z" "z" " "]
      [" " " " " " " "]
    ]
    [
      [" " "z" " " " "]
      ["z" "z" " " " "]
      ["z" " " " " " "]
      [" " " " " " " "]
    ]
  ]
])

; ----------------------------------------------------------------------------

(fn new-sequence []
  (set sequence {})
  (for [pieceTypeIndex 1 (# pieceStructures)]
    (let [pos (love.math.random (+ (# sequence) 1))]
      (table.insert sequence pos pieceTypeIndex))))

(fn new-piece []
  (set pieceX        3)
  (set pieceY        0)
  (set pieceType     (table.remove sequence))
  (set pieceRotation 1)
  
  (if (= (# sequence) 0)
    (new-sequence)))

(fn reset []
  (set inert {})
  (for [y 1 gridYCount]
    (local row {})
    (for [x 1 gridXCount]
      (tset row x " "))
    (tset inert y row))

  (new-sequence)
  (new-piece)

  (set timer 0))

(fn love.load []
  (love.graphics.setBackgroundColor 255 255 255)
  (reset))

; ----------------------------------------------------------------------------

(fn can-move? [testX testY rot]
  (var canMove true)
  (for [x 1 pieceXCount]
    (for [y 1 pieceYCount]
      (local testBlockX (+ testX x))
      (local testBlockY (+ testY y))
      (if (and (~= (. (. (. (. pieceStructures pieceType) rot) y) x) " ")
               (or (< testBlockX 1)
                   (> testBlockX gridXCount)
                   (> testBlockY gridYCount)
                   (~= (. (. inert testBlockY) testBlockX) " ")))
        (set canMove false))))
  canMove)

(fn love.update [dt]
  (set timer (+ timer dt))
  (when (>= timer timerLimit)
    (set timer (- timer timerLimit))
    (local testY (+ pieceY 1))
    (if (can-move? pieceX testY pieceRotation)
      (set pieceY testY)
      (do
        (for [y 1 pieceYCount]
          (for [x 1 pieceXCount]
            (let [block (. (. (. (. pieceStructures pieceType) pieceRotation) y) x)]
              (if (~= block " ")
                (tset (. inert (+ pieceY y)) (+ pieceX x) block)))))
        (for [y 1 gridYCount]
          (var complete true)
          (for [x 1 gridXCount]
            (if (= (. (. inert y) x) " ")
              (set complete false)))

          (when complete
            (for [removeY y 2 -1]
              (for [removeX 1 gridXCount]
                (tset (. inert removeY) removeX (. (. inert (- removeY 1)) removeX))))
            (for [removeX 1 gridXCount]
              (tset (. inert 1) removeX " "))))
        (new-piece)
        (if (not (can-move? pieceX pieceY pieceRotation))
          (reset))))))

; ----------------------------------------------------------------------------

(fn draw-block [block x y]
  (local colors {" "       [.87 .87 .87]
                 "i"       [.47 .76 .94]
                 "j"       [.93 .91 .42]
                 "l"       [.49 .85 .76]
                 "o"       [.92 .69 .47]
                 "s"       [.83 .54 .93]
                 "t"       [.97 .58 .77]
                 "z"       [.66 .83 .46]
                 "preview" [.75 .75 .75]})

  (let [color (. colors block)]
    (love.graphics.setColor color))

  (love.graphics.rectangle "fill"
                           (* (- x 1) blockSize)
                           (* (- y 1) blockSize)
                           blockDrawSize
                           blockDrawSize))

(fn love.draw []
  (local offsetX 2)
  (local offsetY 5)

  (for [y 1 gridYCount]
    (for [x 1 gridXCount]
      (let [block (. (. inert y) x)]
        (draw-block block (+ x offsetX) (+ y offsetY)))))
                               
  (for [y 1 pieceYCount]
    (for [x 1 pieceXCount]
      (let [block (. (. (. (. pieceStructures pieceType) pieceRotation) y) x)]
        (if (~= block " ")
          (draw-block block (+ x pieceX offsetX) (+ y pieceY offsetY))))))
          
  (for [y 1 pieceYCount]
    (for [x 1 pieceXCount]
      (let [block (. (. (. (. pieceStructures (. sequence (# sequence))) 1) y) x)]
        (if (~= block " ")
          (draw-block "preview" (+ x 5) (+ y 1)))))))

; ----------------------------------------------------------------------------

(fn love.keypressed [key]
  (if (= key "x")
    (do
      (var testRotation (+ pieceRotation 1))
      (if (> testRotation (# (. pieceStructures pieceType)))
        (set testRotation 1))
      (if (can-move? pieceX pieceY testRotation)
        (set pieceRotation testRotation)))
    (= key "z")
    (do
      (var testRotation (- pieceRotation 1))
      (if (< testRotation 1)
        (set testRotation (# (. pieceStructures pieceType))))
      (if (can-move? pieceX pieceY testRotation)
        (set pieceRotation testRotation)))

    (= key "left")
    (do
      (local testX (- pieceX 1))
      (if (can-move? testX pieceY pieceRotation)
        (set pieceX testX)))
    (= key "right")
    (do
      (local testX (+ pieceX 1))
      (if (can-move? testX pieceY pieceRotation)
        (set pieceX testX)))
        
    (= key "c")
      (while (can-move? pieceX (+ pieceY 1) pieceRotation)
        (set pieceY (+ pieceY 1))
        (set timer timerLimit))
    (= key "s")
      (do
        (new-sequence)
        (print "Sequence:")
        (each [pieceTypeIndex pieceType (ipairs sequence)]
          (print pieceType)))))
