(defclass visualgram (clispgram)
((vao :initform (gl:gen-vertex-array)) draw-mode))

;(defclass visualgram-colours (visualgram) ())
;(defclass visualgram-particles (visualgram) ())
;(defclass visualgram-animations (visualgram) ())

;(defmethod cg-visualize ((object visualgram))
;(gl:bind-vertex-array (slot-value object 'vao)))
;(gl:draw-elements (slot-value object 'draw-mode) (slot-value object 'vao)))

(defmethod cg-clean ((object visualgram))
(gl:delete-buffers (list (slot-value object 'vbo)))
(gl:delete-vertex-arrays (list (slot-value object 'vao)))
(call-next-method))

(defclass testgram (visualgram)
((vbo :initform (first (gl:gen-buffers 1))) 
 (count :initform 0)
 (update :initform nil)
 data
 (time :initform 0)))

(defmethod cg-init ((object testgram))
  (setf (slot-value object 'data) (make-array 0 :fill-pointer t :adjustable t  :element-type 'float))
  (plasma-fractal 0 0 32 32 (- 10 (random 20)) (- 10 (random 20)) (- 10 (random 20)) (- 10 (random 20)) 0 15 1 (slot-value object 'data))
  (setf (slot-value object 'data) (vcoerce-singlef (slot-value object 'data)))

  (gl:bind-buffer :array-buffer (slot-value object 'vbo))
 
  (seq-to-glbuf (slot-value object 'data) :float)

  (gl:bind-buffer :array-buffer 0)
 
  (gl:bind-vertex-array (slot-value object 'vao))
  (gl:bind-buffer :array-buffer (slot-value object 'vbo))
  (gl:enable-vertex-attrib-array 0)
  (gl:vertex-attrib-pointer 0 3 :float nil 0 (cffi:null-pointer))
  (gl:bind-vertex-array 0)
  (setf (slot-value object 'count) (/ (length (slot-value object 'data)) 3)))

(defmethod cg-evaluate ((object testgram))
(setf (slot-value object 'update) t))

(defmethod testgram-update ((object testgram)))
#|
(loop for x below (length (slot-value object 'data))
     do (setf (aref (slot-value object 'data) x) (+ (sin (slot-value object 'time)) (aref (slot-value object 'data) x))))
(setf (slot-value object 'time) (+ (slot-value object 'time) (/ pi 32)))

(setf (slot-value object 'data) (vcoerce-singlef (slot-value object 'data)))
(gl:bind-buffer :array-buffer (slot-value object 'vbo))
(seq-sub-glbuf (slot-value object 'data) :float)
(gl:bind-buffer :array-buffer 0))
|#
(defmethod cg-visualize ((object testgram))
(if (slot-value object 'update) (progn (testgram-update object) (setf (slot-value object 'update) nil)))
(gl:bind-vertex-array (slot-value object 'vao))
;(gl:draw-elements :points (gl:make-null-gl-array :unsigned-short) :count (slot-value object 'count))
(gl:draw-arrays :points 0 (slot-value object 'count))
(gl:bind-vertex-array 0)
(call-next-method))
