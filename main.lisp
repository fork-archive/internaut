(require :asdf)
(asdf:load-system :cl-opengl)
(asdf:load-system :cl-glut)
;(asdf:load-system :cl-glu)
(asdf:load-system :lispbuilder-sdl)
(use-package :sb-thread)

(defparameter *proc-jump* 0.01)
(defparameter *frame-rate* 160)
(defparameter *itups* internal-time-units-per-second)

(defun reload()
(load "fractals.lisp")
(load "utils.lisp")
(load "glm.lisp")
(load "proc.lisp")
(load "visualize.lisp")
(load "physics.lisp")
(load "listen.lisp")
(load "interact.lisp")
(load "interface.lisp"))

(reload)

(defvar *modelview-matrix*)
(defvar *projection-matrix*)
(defvar *texture-matrix*)
(defvar *colour-matrix*)

(defvar *modelviewm*)
(defvar *projectm*)
(defvar *texturem*)
(defvar *colourm*)

(defparameter *fullscreen* nil)

(defun draw ()

(gl:uniform-matrix *projectm* 4 (vector *projection-matrix*))
(gl:uniform-matrix *modelviewm* 4 (vector *modelview-matrix*))
;(gl:uniform-matrix *modelviewm* 4 (vector (glm-look-at (vector 0.0 0.0 10.0) (vector 0.0 0.0 0.0) (vector 0.0 1.0 0.0))))

(gl:clear-color .25 .5 .75 1.0)
(gl:clear :color-buffer-bit :depth-buffer-bit)

(cg-evaluate *player-location*)

;(print (vector *projection-matrix*))
;(print (vector *model-matrix*))
;(print (vector *view-matrix*))

;(print (sv* *projection-matrix* *model-matrix* *view-matrix*))

(with-mutex (*cg-box-lock*)
(loop for obj in *cg-box*
     do (progn
	  (cg-lock (nth 0 obj))
	  (cg-visualize (nth 0 obj))
	  (cg-unlock (nth 0 obj)))))

(glut:solid-teapot 1)

(gl:flush))

(defun init-window (fullscreen width height)
"Create an SDL OpenGL surface."
(print fullscreen)
(SDL:WINDOW width height :TITLE-CAPTION "BOX" :ICON-CAPTION "BOX" :DOUBLE-BUFFER T :POSITION T :OPENGL T :RESIZABLE T :FULLSCREEN fullscreen)
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
  (setf *projection-matrix* (glm-perspective 45 (/ width height) 0.1 250))
)

(defun toggle-fullscreen ()
  (if *fullscreen*
      (progn (setf *fullscreen* nil)
	     (sdl:resize-window 1024 768 :fullscreen nil :TITLE-CAPTION "BOX" :ICON-CAPTION "BOX" :DOUBLE-BUFFER T :OPENGL T :RESIZABLE T)
	     (reshape-window 1024 768))
      (progn (setf *fullscreen* T)
	     (sdl:resize-window 1920 1080 :fullscreen T :TITLE-CAPTION "BOX" :ICON-CAPTION "BOX" :DOUBLE-BUFFER T :OPENGL T :RESIZABLE T)
	     (reshape-window 1920 1080))))

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
;  (gl:attach-shader shaderprogram gs)
  
  (gl:bind-attrib-location shaderprogram 0 "in_position")
  (gl:bind-attrib-location shaderprogram 1 "in_color")

  (gl:link-program shaderprogram)
  (gl:use-program shaderprogram)

  (setf *modelviewm* (gl:get-uniform-location shaderprogram "modelviewmatrix"))
  (setf *projectm* (gl:get-uniform-location shaderprogram "projectionmatrix"))))

(defun init-gl ()
(gl:enable :depth-test)
(gl:depth-func :lequal)
(gl:clear-depth 1))

(defun clean-all ()
(release-mutex *cg-box-lock*)
(release-mutex *cg-run-lock*)
(loop for obj in *cg-box* do (cg-clean (nth 0 obj)))
(sdl:quit-sdl)

(setf *cg-box* nil)
(setf /key-down-map/ nil)
(setf /key-up-map/ nil))

(defun main ()
(print "STARTING THE REACTOR")
(SDL:INIT-SDL :VIDEO T :AUDIO T)
(glut:init)
(init-window nil 1024 768)
(init-gl)
(init-shaders)

(add-to-cg-box (make-instance 'testgram))

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

(let ((thread (sb-thread:make-thread 'proc-loop)))

(SETF (SDL:FRAME-RATE) *frame-rate*)
(SDL:WITH-EVENTS (:POLL)  
  (:QUIT-EVENT () T)  
  (:KEY-DOWN-EVENT (:KEY KEY)  
      (do-key-press key))
  (:KEY-UP-EVENT (:KEY KEY)  
      (do-key-release key))
  (:idle ()
      (draw)
      (SDL:UPDATE-DISPLAY)))
;(with-mutex (*cg-run-lock*) (sb-thread:interrupt-thread thread (lambda () (proc-quit))))
(format t "~%Waiting for lock...~%")
(with-mutex (*cg-run-lock*) (sb-thread:terminate-thread thread))
(format t "Done.~%")
(clean-all)))
