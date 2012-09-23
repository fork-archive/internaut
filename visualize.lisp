(defclass visualgram (clispgram)
((vao :initform (gl:gen-vertex-array)) draw-mode))

;(defclass visualgram-colours (visualgram) ())
;(defclass visualgram-particles (visualgram) ())
;(defclass visualgram-animations (visualgram) ())

;(defmethod cg-visualize ((object visualgram))
;(gl:bind-vertex-array (slot-value object 'vao)))
;(gl:draw-elements (slot-value object 'draw-mode) (slot-value object 'vao)))

(defmethod cg-clean ((object visualgram))
(gl:delete-vertex-arrays (slot-value object 'vao))

(call-next-method))

(defclass testgram (visualgram)
((vbo :initform 0) 
 (count :initform 0)))

(defmethod cg-init ((object testgram))
(let ((vbo (slot-value object 'vbo))
      (vao (slot-value object 'vao))
      (vlist (make-array 0 :fill-pointer t :adjustable t)))
  
  (plasma-fractal 0 0 256 256 (- 10 (random 20)) (- 10 (random 20)) (- 10 (random 20)) (- 10 (random 20)) 0 15 1 vlist)
  (gl:bind-vertex-array vao)
  (setf vbo (first (gl:gen-buffers 1)))
  (gl:bind-buffer :array-buffer vbo)
  (let ((alpha (vector-to-gl-array :float (vcoerce-singlef vlist))))
    (gl:buffer-data :array-buffer :static-draw alpha)
    (gl:free-gl-array alpha))
  (gl:bind-buffer :array-buffer 0)
  
  (gl:bind-vertex-array vao)
  (gl:bind-buffer :array-buffer vbo)
  (gl:enable-vertex-attrib-array 0)
  (gl:vertex-attrib-pointer 0 3 :float nil 0 (cffi:null-pointer))
  (gl:bind-vertex-array 0)
  (setf (slot-value object 'count) (/ (length vlist) 3))))

(defmethod cg-evaluate ((object testgram)) (print 1))

(defmethod cg-visualize ((object testgram))
(gl:bind-vertex-array (slot-value object 'vao))
;(gl:draw-elements :points (gl:make-null-gl-array :unsigned-short) :count (slot-value object 'count))
(gl:draw-arrays :points 0 (slot-value object 'count))
(call-next-method))
