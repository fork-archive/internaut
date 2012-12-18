(defparameter *proc-jump* 0.01)
(defparameter *frame-rate* 160)
(defparameter *itups* internal-time-units-per-second)

(defparameter *insert-box* '())
(defparameter *insert-box-lock* (bordeaux-threads:make-lock))
;(:documentation "This is locked by the GL loop. In order to modify the list, we must lock this mutex."))

(defvar *modelview-matrix*)
(defvar *projection-matrix*)
(defvar *texture-matrix*)
(defvar *colour-matrix*)

(defvar *modelviewm*)
(defvar *projectm*)
(defvar *texturem*)
(defvar *colourm*)

(defun insert-clispgram (object)
  (bordeaux-threads:with-lock-held (*insert-box-lock*)
    (setf *insert-box* (append *insert-box* (list object)))))

(defun draw ()
  (gl:uniform-matrix *projectm* 4 (vector *projection-matrix*))
  (gl:uniform-matrix *modelviewm* 4 (vector *modelview-matrix*))

  (gl:clear-color .15 .15 .15 1.0)
  (gl:clear :color-buffer-bit :depth-buffer-bit)

  (cg-evaluate *player-location*)

  (bordeaux-threads:with-lock-held (*cg-box-lock*)
    (loop for obj in *cg-box*
     do (progn
       (cg-lock (nth 0 obj))
       (cg-visualize (nth 0 obj))
       (cg-unlock (nth 0 obj)))))

  (gl:flush))

(defun init-window (fullscreen width height)
  "Create an SDL OpenGL surface."
  (SDL:WINDOW width height :FULLSCREEN nil :TITLE-CAPTION "BOX" :ICON-CAPTION "BOX" :DOUBLE-BUFFER T :POSITION T :OPENGL T)
  (reshape-window width height)
  )

(defun reshape-window (width height)
  (gl:viewport 0 0 width height)
  ;(glu:perspective 50 (/ width height) 0.5 2000)
  ;(setf *projection-matrix* (gl:get-float :projection-matrix))
  ;(setf *modelview-matrix* (gl:get-float :modelview-matrix))  
  ;(gl:matrix-mode :projection)
  ;(gl:load-identity)
  (setf *modelview-matrix* (mvec 16 1))
  (setf *projection-matrix* (glm-perspective 45 (/ width height) 1e-10 10))
  )

(defun toggle-fullscreen ()
  (if (cgi 'fullscreen)
    (progn (cgs 'fullscreen nil)
      (sdl:resize-window (cgi 'window-width) (cgi 'window-height) :fullscreen nil :TITLE-CAPTION "BOX" :ICON-CAPTION "BOX" :DOUBLE-BUFFER T :OPENGL T)
      (reshape-window (cgi 'window-width) (cgi 'window-height)))
    (progn (cgs 'fullscreen T)
      (sdl:resize-window (cgi 'fullscreen-width) (cgi 'fullscreen-height) :fullscreen T :TITLE-CAPTION "BOX" :ICON-CAPTION "BOX" :DOUBLE-BUFFER T :OPENGL T)
      (reshape-window (cgi 'fullscreen-width) (cgi 'fullscreen-height)))))

(defun init-shaders ()
  (let ((frags (load-file "rsrc/shaders/points.fs"))
    (verts (load-file "rsrc/shaders/points.vs"))
      ;(geos (load-file "rsrc/shaders/points.gs"))
      (fs (gl:create-shader :fragment-shader))
      (vs (gl:create-shader :vertex-shader))
      ;(gs (gl:create-shader :geometry-shader))
      (shaderprogram (gl:create-program)))

  (gl:shader-source fs frags)
  (gl:shader-source vs verts)
  ;(gl:shader-source gs geos)

  (gl:compile-shader fs)
  (gl:compile-shader vs)
  ;(gl:compile-shader gs)

  (format t (gl:get-shader-info-log fs))
  (format t (gl:get-shader-info-log vs))
 ;(format t (gl:get-shader-info-log gs))

 (gl:attach-shader shaderprogram fs)
 (gl:attach-shader shaderprogram vs)
  ;(gl:attach-shader shaderprogram gs)
  
  (gl:bind-attrib-location shaderprogram 0 "in_position")
  (gl:bind-attrib-location shaderprogram 1 "in_color")

  (gl:link-program shaderprogram)
  (gl:use-program shaderprogram)

  (setf *modelviewm* (gl:get-uniform-location shaderprogram "modelviewmatrix"))
  (setf *projectm* (gl:get-uniform-location shaderprogram "projectionmatrix"))))

(defun init-gl ()
 (gl:depth-func :lequal)
 (gl:enable :depth-test)
 (gl:clear-depth 1)

 (gl:enable :lighting)
 (gl:light-model :light-model-ambient '(0.75 0.75 0.75 1))

 (gl:fog :fog-color '(.5 .5 .5 .5))
 (gl:fog :fog-mode :linear)
 (gl:fog :fog-density 1)
 (gl:fog :fog-start 10.0)
 (gl:fog :fog-end 5)
 (gl:enable :fog)
 )

(defun clean-all ()
  (bordeaux-threads:release-lock *insert-box-lock*)
  (bordeaux-threads:release-lock *cg-box-lock*)
  (bordeaux-threads:release-lock *cg-run-lock*)
  (loop for obj in *cg-box* do (cg-clean (nth 0 obj)))
  (sdl:quit-sdl)

  (setf *cg-box* nil)
  (setf /key-down-map/ nil)
  (setf /key-up-map/ nil))

(defun main ()
  (format t "starting the reactor~%")
  (SDL:INIT-SDL :VIDEO T :AUDIO T)
  (if (cgi 'fullscreen)
    (init-window t (cgi 'fullscreen-width) (cgi 'fullscreen-height))
    (init-window nil (cgi 'window-width) (cgi 'window-height)))
  (init-gl)
  (init-shaders)

  (add-to-cg-box (make-instance 'testgram))
  ;(add-to-cg-box (make-instance 'ROCHEGRAM))

  (set-key-press :sdl-key-w (lambda () (player-start-move *player-location* 2 0)))
  (set-key-press :sdl-key-s (lambda () (player-start-move *player-location* 2 1)))
  (set-key-press :sdl-key-a (lambda () (player-start-move *player-location* 2 2)))
  (set-key-press :sdl-key-d (lambda () (player-start-move *player-location* 2 3)))
  (set-key-release :sdl-key-w (lambda () (player-stop-move *player-location* 0)))
  (set-key-release :sdl-key-s (lambda () (player-stop-move *player-location* 1)))
  (set-key-release :sdl-key-a (lambda () (player-stop-move *player-location* 2)))
  (set-key-release :sdl-key-d (lambda () (player-stop-move *player-location* 3)))

  (set-key-press :sdl-key-left (lambda () (player-start-rotate *player-location* -1 1)))
  (set-key-press :sdl-key-right (lambda () (player-start-rotate *player-location* 1 1)))
  (set-key-press :sdl-key-up (lambda () (player-start-rotate *player-location* -0.5 0)))
  (set-key-press :sdl-key-down (lambda () (player-start-rotate *player-location* 0.5 0)))
  (set-key-release :sdl-key-left (lambda () (player-stop-rotate *player-location* 1)))
  (set-key-release :sdl-key-right (lambda () (player-stop-rotate *player-location* 1)))
  (set-key-release :sdl-key-up (lambda () (player-stop-rotate *player-location* 0)))
  (set-key-release :sdl-key-down (lambda () (player-stop-rotate *player-location* 0)))

  (set-key-press :sdl-key-f11 (lambda () (toggle-fullscreen)))
  (set-key-press :sdl-key-escape (lambda () (sdl:push-quit-event)))

  (let ((thread (bordeaux-threads:make-thread 'proc-loop)))

    (SETF (SDL:FRAME-RATE) *frame-rate*)
    (SDL:WITH-EVENTS (:POLL)  
      (:QUIT-EVENT () T)  
      (:KEY-DOWN-EVENT (:KEY KEY)  
        (do-key-press key))
      (:KEY-UP-EVENT (:KEY KEY)  
        (do-key-release key))
      (:idle ()

        ; FIX ME LATER -- DOES NOT TIME OUT!
        (if *insert-box*
          (bordeaux-threads:with-lock-held (*insert-box-lock*)
            (progn
              (loop for item in *insert-box*
                do(progn
                  (cg-lock item)
                  (add-to-cg-box item)
                  (cg-unlock item))
                (setf *insert-box* nil)))))

        (draw)
        (SDL:UPDATE-DISPLAY)))
    ;(with-lock-held (*cg-run-lock*) (bordeaux-threads:interrupt-thread thread (lambda () (proc-quit))))

    (format t "waiting for lock ... ")
    (bordeaux-threads:with-lock-held (*cg-run-lock*) (bordeaux-threads:destroy-thread thread))
    (format t "done~%")
    (clean-all)))