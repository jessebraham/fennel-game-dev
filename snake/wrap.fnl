; Global constants
(global cellSize   15)
(global gridXCount 20)
(global gridYCount 15)

; Global mutable state!? :o
(var directionQueue nil)
(var foodPosition   nil)
(var snakeAlive     nil)
(var snakeSegments  nil)
(var timer          nil)

; ----------------------------------------------------------------------------

(fn move-food []
  ; Construct a sequential table of positions which are *not* occupied by a
  ; snake segment
  (local possiblePositions [])
  (for [foodX 1 gridXCount]
    (for [foodY 1 gridYCount]
      (var possible true)
      (each [segmentIndex segment (ipairs snakeSegments)]
        (if (and (= foodX (. segment :x)) (= foodY (. segment :y)))
          (set possible false)))
      (if possible
        (table.insert possiblePositions {:x foodX :y foodY}))))

  ; Randomly select one of the possible positions and set the food's
  ; location to it
  (set foodPosition (. possiblePositions (love.math.random (# possiblePositions)))))

(fn reset []
  (set snakeSegments [{:x 3 :y 1}
                      {:x 2 :y 1}
                      {:x 1 :y 1}])
  (set directionQueue ["right"])
  (set snakeAlive     true)
  (set timer          0)
  (move-food))

(fn love.load []
  (reset))

; ----------------------------------------------------------------------------

(fn next-position []
  (var nextXPosition (. (. snakeSegments 1) :x))
  (var nextYPosition (. (. snakeSegments 1) :y))

  (match (. directionQueue 1)
    "right" (do
              (set nextXPosition (+ nextXPosition 1))
              (if (> nextXPosition gridXCount)
                (set nextXPosition 1)))
    "left"  (do
              (set nextXPosition (- nextXPosition 1))
              (if (< nextXPosition 1)
                (set nextXPosition gridXCount)))
    "down"  (do
              (set nextYPosition (+ nextYPosition 1))
              (if (> nextYPosition gridYCount)
                (set nextYPosition 1)))
    "up"    (do
              (set nextYPosition (- nextYPosition 1))
              (if (< nextYPosition 1)
                (set nextYPosition gridYCount))))

  {:x nextXPosition :y nextYPosition})

(fn can-move [pos]
  (var canMove true)
  (each [segmentIndex segment (ipairs snakeSegments)]
    (if (and (~= segment (# snakeSegments))
             (= (. pos :x) (. segment :x))
             (= (. pos :y) (. segment :y)))
      (set canMove false)))
  canMove)

(fn love.update [dt]
  (local timerLimit 0.15)
  (set timer (+ timer dt))

  (if snakeAlive
    (when (>= timer timerLimit)
      (set timer (- timer timerLimit))
      (if (> (# directionQueue) 1)
        (table.remove directionQueue 1))

      (local pos (next-position))
      (if (can-move pos)
        (do
          (table.insert snakeSegments 1 pos)
          (if (and (= (. (. snakeSegments 1) :x) (. foodPosition :x))
                   (= (. (. snakeSegments 1) :y) (. foodPosition :y)))
            (move-food)
            (table.remove snakeSegments)))
        (set snakeAlive false)))
    (>= timer 2)
      (reset)))

; ----------------------------------------------------------------------------

(fn draw-cell [x y]
  (love.graphics.rectangle "fill"
                           (* (- x 1) cellSize)
                           (* (- y 1) cellSize)
                           (- cellSize 1)
                           (- cellSize 1)))

(fn love.draw []
  ; Draw the background
  (love.graphics.setColor 0.28 0.28 0.28)
  (love.graphics.rectangle "fill"
                           0
                           0
                           (* gridXCount cellSize)
                           (* gridYCount cellSize))

  ; Set the snake color based on whether or not it is alive
  (if snakeAlive
    (love.graphics.setColor 0.6 1.0 0.32)
    (love.graphics.setColor 0.5 0.5 0.5))

  ; Draw each snake segment
  (each [segmentIndex segment (ipairs snakeSegments)]
    (draw-cell (. segment :x) (. segment :y)))

  ; Draw the food
  (love.graphics.setColor 1.0 0.3 0.3)
  (draw-cell (. foodPosition :x) (. foodPosition :y)))

; ----------------------------------------------------------------------------

(fn valid-direction [key]
  (let [opposites {"right" "left"
                   "left"  "right"
                   "down"  "up"
                   "up"    "down"}
        previous (. directionQueue (# directionQueue))]
    (and (~= previous key) (~= previous (. opposites key)))))

(fn love.keypressed [key]
  (if (and (or (= key "right") (= key "left") (= key "down") (= key "up"))
           (valid-direction key))
    (table.insert directionQueue key)))
