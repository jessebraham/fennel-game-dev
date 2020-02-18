; Global constants
(global birdWidth         30)
(global birdHeight        25)
(global pipeSpaceYMin     54)
(global pipeWidth         54)
(global playingAreaWidth  300)
(global playingAreaHeight 388)

; Global mutable state
(var birdX           nil)
(var birdY           nil)
(var birdYSpeed      nil)
(var pipeSpaceHeight nil)
(var pipe1X          nil)
(var pipe1SpaceY     nil)
(var pipe2X          nil)
(var pipe2SpaceY     nil)
(var score           nil)
(var upcomingPipe    nil)

; ----------------------------------------------------------------------------

(fn new-pipe-space-y []
  (let [pipeSpaceYMin 54]
    (love.math.random pipeSpaceYMin
                      (- playingAreaHeight pipeSpaceHeight pipeSpaceYMin))))

(fn reset []
  (set birdX      62)
  (set birdY      200)
  (set birdYSpeed 0)

  (set pipeSpaceHeight 100)
  (set pipe1X          playingAreaWidth)
  (set pipe1SpaceY     (new-pipe-space-y))
  (set pipe2X          (+ playingAreaWidth (/ (+ playingAreaWidth pipeWidth) 2)))
  (set pipe2SpaceY     (new-pipe-space-y))
  
  (set score        0)
  (set upcomingPipe 1))

(fn love.load []
  (reset))

; ----------------------------------------------------------------------------

(fn move-pipe [dt x y]
  (var pipeX      (- x (* 60 dt)))
  (var pipeSpaceY y)

  ; When the pipe is no longer within the bounds of the screen, create a new
  ; one.
  (when (< (+ pipeX pipeWidth) 0)
    (set pipeX      playingAreaWidth)
    (set pipeSpaceY (new-pipe-space-y)))

  (values pipeX pipeSpaceY))

(fn colliding? [x y]
  (and (< birdX (+ x pipeWidth))
       (> (+ birdX birdWidth) x)
       (or (< birdY y)
           (> (+ birdY birdHeight) (+ y pipeSpaceHeight)))))

(fn update-score-and-closest-pipe [pipe x other]
  (when (and (= upcomingPipe pipe)
             (> birdX (+ x pipeWidth)))
    (set score        (+ score 1))
    (set upcomingPipe other)))

(fn love.update [dt]
  (set birdYSpeed (+ birdYSpeed (* 516 dt)))
  (set birdY      (+ birdY (* birdYSpeed dt)))
  
  (let [(x1 y1) (move-pipe dt pipe1X pipe1SpaceY)
        (x2 y2) (move-pipe dt pipe2X pipe2SpaceY)]
    (set pipe1X      x1)
    (set pipe2X      x2)
    (set pipe1SpaceY y1)
    (set pipe2SpaceY y2))

  (if (or (colliding? pipe1X pipe1SpaceY)
          (colliding? pipe2X pipe2SpaceY)
          (> birdY playingAreaHeight))
    (reset))

  (update-score-and-closest-pipe 1 pipe1X 2)
  (update-score-and-closest-pipe 2 pipe2X 1))

; ----------------------------------------------------------------------------

(fn draw-pipe [x y]
  (love.graphics.setColor 0.37 0.82 0.28)
  (love.graphics.rectangle "fill" x 0 pipeWidth y)
  (love.graphics.rectangle "fill"
                           x
                           (+ y pipeSpaceHeight)
                           pipeWidth
                           (- playingAreaHeight y pipeSpaceHeight)))

(fn love.draw []
  ; Draw the background of the playing area.
  (love.graphics.setBackgroundColor 0.14 0.36 0.46)
  
  ; Draw the bird.
  (love.graphics.setColor 0.87 0.84 0.27)
  (love.graphics.rectangle "fill" birdX birdY birdWidth birdHeight)

  ; Draw the two sets of pipes.  
  (draw-pipe pipe1X pipe1SpaceY)
  (draw-pipe pipe2X pipe2SpaceY)
  
  ; Draw the score.
  (love.graphics.setColor 1.0 1.0 1.0)
  (love.graphics.print score 15 15))

; ----------------------------------------------------------------------------

(fn love.keypressed [key]
  ; Any key will cause the bird to flap its wings when pressed.
  (if (> birdY 0)
    (set birdYSpeed -165)))
