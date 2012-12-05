(defclass player-location (clispgram)
((xrot :initform 0)
 (yrot :initform 0)
 (zrot :initform 0)
 (xvelocity :initform 0)
 (xvelocitycache :initform 0)
 (yvelocity :initform 0)
 (yvelocitycache :initform 0)
 (zvelocity :initform 0)
 (zvelocitycache :initform 0)
 (position :initarg :position :initform (list 0 0 0))
 (rotation :initarg :rotation :initform (list 0 0 0))))

(defparameter *player-location* (make-instance 'player-location))

(defvar *forward* 0)
(defvar *backward* 1)
(defvar *left* 2)
(defvar *right 3)

(defmethod cg-evaluate ((object player-location))
  (let* ((xrot (slot-value object 'xrot))
       (yrot (slot-value object 'yrot))
       ;(xvelocity (slot-value object 'xvelocity))
       (zvelocity (slot-value object 'zvelocity))
       (zvelocitycache (slot-value object 'zvelocitycache))
       (position (slot-value object 'position))
       (rotation (slot-value object 'rotation))
       (x (float (* (cos (* (/ (nth 0 rotation) 180) pi)) (cos (* (/ (nth 1 rotation) 180) pi)))))
       (y (float (sin (* (/ (nth 0 rotation) 180) pi))))
       (z (float (* (cos (* (/ (nth 0 rotation) 180) pi)) (sin (* (/ (nth 1 rotation) 180) pi))))))
  (setf (nth 0 (slot-value object 'rotation)) (+ (nth 0 (slot-value object 'rotation)) xrot))
  (setf (nth 1 (slot-value object 'rotation)) (+ (nth 1 (slot-value object 'rotation)) yrot))
  ;(setf-add (nth 1 (slot-value object 'rotation)) yrot)
  #|(print rotation)|#
  (setf (slot-value object 'position) (list-add position (mapcar (lambda (num) (* zvelocity num)) (list x y z))))

  (if (= zvelocity 0)
      (setf *modelview-matrix* (glm-look-at 
			   (vector (nth 0 position) (nth 1 position) (nth 2 position))
			   (vector (- (nth 0 position) (* zvelocitycache x)) (- (nth 1 position) (* zvelocitycache y)) (- (nth 2 position) (* zvelocitycache z)))
			   (vector 0 1 0)))
      (progn
	(setf *modelview-matrix* (glm-look-at
			    (vector (nth 0 position) (nth 1 position) (nth 2 position))
			    (vector (- (nth 0 position) (* (abs zvelocity) x)) (- (nth 1 position) (* (abs zvelocity) y)) (- (nth 2 position) (* (abs zvelocity) z)))
			    (vector 0 1 0)))
	(setf (slot-value object 'zvelocitycache) (abs zvelocity))))

  ;(setf *model-matrix* (glm-translate #|*view-matrix*|#(mvec 16 0) (vector (neg (nth 0 position)) (neg (nth 1 position)) (neg (nth 2 position)))))
  ;(setf *view-matrix* (mvec 16 1))
  ;(print *view-matrix*)
  ;(print (list (nth 0 position) (nth 1 position) (nth 2 position) (- (nth 0 position) (* zvelocitycache x)) (- (nth 1 position) (* zvelocitycache y)) (- (nth 2 position) (* zvelocitycache z)) 0 1 0))
  #|(print position)|#))

(defmethod player-start-move ((object player-location) dist direction)
(cond 
  ((= direction 0) (setf (slot-value object 'zvelocity) (- 0 dist)));Forwards
  ((= direction 1) (setf (slot-value object 'zvelocity) dist));Backwards
  ((= direction 2) (setf (slot-value object 'xvelocity) (- 0 dist)));Strafe Left
  ((= direction 3) (setf (slot-value object 'xvelocity) dist))));Strafe Right
(defmethod player-stop-move ((object player-location) direction)
(cond
  ((= direction 0) (setf (slot-value object 'zvelocity) 0))
  ((= direction 1) (setf (slot-value object 'zvelocity) 0))
  ((= direction 2) (setf (slot-value object 'xvelocity) 0))
  ((= direction 3) (setf (slot-value object 'xvelocity) 0))))
(defmethod player-start-rotate ((object player-location) dist axis)
(cond
  ((= axis 0) (setf (slot-value object 'xrot) dist));X-Axis
  ((= axis 1) (setf (slot-value object 'yrot) dist));Y-Axis
  ((= axis 2) (setf (slot-value object 'zrot) dist))));Z-Axis
(defmethod player-stop-rotate ((object player-location) axis)
(cond
  ((= axis 0) (setf (slot-value object 'xrot) 0));X-Axis
  ((= axis 1) (setf (slot-value object 'yrot) 0));Y-Axis
  ((= axis 2) (setf (slot-value object 'zrot) 0))));Z-Axis
(defmethod set-player-location ((object player-location)) ())
(defmethod get-player-location ((object player-location)) ())

#|
(defun set-location (loc-list)
(sb-thread:with-mutex (*self-lock*)
  (setf /location/ loc-list)))
(defun get-location ()
(sb-thread:with-mutex (*self-lock*)
  /location/))
|#
(defvar *key-lock* (sb-thread:make-mutex :name "key-lock"))
(defvar /key-down-map/ '())
(defvar /key-up-map/ '())

(defun set-key-press (key function)
  (if (cdr (assoc key /key-down-map/)) 
      (rplacd (assoc key /key-down-map/) (cons key function))
      (setq /key-down-map/ (acons key function /key-down-map/))))
(defun set-key-release (key function)
  (if (cdr (assoc key /key-up-map/)) 
      (rplacd (assoc key /key-up-map/) (cons key function))
      (setq /key-up-map/ (acons key function /key-up-map/))))

(defun get-key-press (key)
  (if (assoc key /key-down-map/)
      (cdr (assoc key /key-down-map/))
      ()))
(defun get-key-release (key)
  (if (assoc key /key-up-map/)
      (cdr (assoc key /key-up-map/))
      ()))

(defun do-key-press (key)
  (if (cdr (assoc key /key-down-map/))
      (funcall (cdr (assoc key /key-down-map/)))))
(defun do-key-release (key)
  (if (cdr (assoc key /key-up-map/))
      (funcall (cdr (assoc key /key-up-map/)))))
