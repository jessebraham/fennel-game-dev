; Global constants
(global gridXCount  20)
(global gridYCount  15)

; Global mutable state
(var directionQueue nil)
(var foodPosition   nil)
(var snakeAlive     nil)
(var snakeSegments  nil)
(var timer          nil)

; ----------------------------------------------------------------------------

(fn move-food []
  ; Construct a sequential table of positions which are *not* occupied by a
  ; snake segment.
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
  ; location to it.
  (set foodPosition
       (. possiblePositions (love.math.random (# possiblePositions)))))

(fn love.load []
  (set directionQueue ["right"])
  (set snakeAlive     true)
  (set snakeSegments [{:x 3 :y 1}
                      {:x 2 :y 1}
                      {:x 1 :y 1}])
  (set timer          0)
  (move-food))

; ----------------------------------------------------------------------------

(fn next-position []
  ; The next position is determined by the head of the snake.
  (var nextXPosition (. (. snakeSegments 1) :x))
  (var nextYPosition (. (. snakeSegments 1) :y))

  ; Apply the appropriate transformation to the position, wrapping around if
  ; the bounds of the board have been crossed.
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

  ; Return the next position as a table.
  {:x nextXPosition :y nextYPosition})

(fn can-move? [pos]
  (var canMove true)
  (each [segmentIndex segment (ipairs snakeSegments)]
    (if (and (~= segment (# snakeSegments))
             (= (. pos :x) (. segment :x))
             (= (. pos :y) (. segment :y)))
      (set canMove false)))
  canMove)

(fn love.update [dt]
  ; Increment the timer on each update.
  (set timer (+ timer dt))

  (local timerLimit 0.15)
  (if snakeAlive
    ; If the snake is alive, handle any input received.
    (when (>= timer timerLimit)
      (set timer (- timer timerLimit))
      (if (> (# directionQueue) 1)
        (table.remove directionQueue 1))

      (local pos (next-position))
      (if (can-move? pos)
        ; If the snake can move, update its position. If the head of the snake
        ; overlaps any food, consume it.
        (do
          (table.insert snakeSegments 1 pos)
          (if (and (= (. (. snakeSegments 1) :x) (. foodPosition :x))
                   (= (. (. snakeSegments 1) :y) (. foodPosition :y)))
            (move-food)
            (table.remove snakeSegments)))
        ; If the snake cannot move, flag it as dead.
        (set snakeAlive false)))

    ; If the snake is dead, wait 2 seconds before restarting the game.
    (>= timer 2)
      (love.load)))

; ----------------------------------------------------------------------------

(fn draw-cell [x y]
  (local cellSize 15)
  (love.graphics.rectangle "fill"
                           (* (- x 1) cellSize)
                           (* (- y 1) cellSize)
                           (- cellSize 1)
                           (- cellSize 1)))

(fn love.draw []
  ; Set the background color.
  (love.graphics.setBackgroundColor 0.28 0.28 0.28)

  ; Set the snake color based on whether or not it is alive, then draw each
  ; snake segment.
  (if snakeAlive
    (love.graphics.setColor 0.6 1.0 0.32)
    (love.graphics.setColor 0.5 0.5 0.5))

  (each [segmentIndex segment (ipairs snakeSegments)]
    (draw-cell (. segment :x) (. segment :y)))

  ; Draw the food.
  (love.graphics.setColor 1.0 0.3 0.3)
  (draw-cell (. foodPosition :x) (. foodPosition :y)))

; ----------------------------------------------------------------------------

(fn valid-direction? [dir]
  (let [opposites {"right" "left"
                   "left"  "right"
                   "down"  "up"
                   "up"    "down"}
        previous (. directionQueue (# directionQueue))]
    (and (~= previous dir) (~= previous (. opposites dir)))))

(fn love.keypressed [key]
  ; Only the arrow keys are valid input, so we ignore everything else. The
  ; direction additionally must not be the same or the opposite of the
  ; previous direction in order to be considered valid.
  (if (and (or (= key "right") (= key "left") (= key "down") (= key "up"))
           (valid-direction? key))
    (table.insert directionQueue key)))
