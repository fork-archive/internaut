(defclass visualgram (clispgram)
((vao :initform (gl:gen-vertex-array))
  draw-mode
  (vbo :initform (first (gl:gen-buffers 1))) 
  (count :initform 0)
  (update :initform nil)
  data))

;(defclass visualgram-colours (visualgram) ())
;(defclass visualgram-particles (visualgram) ())
;(defclass visualgram-animations (visualgram) ())

;(defmethod cg-visualize ((object visualgram))
;(gl:bind-vertex-array (slot-value object 'vao)))
;(gl:draw-elements (slot-value object 'draw-mode) (slot-value object 'vao)))

(defmethod cg-init :before ((object visualgram))
(setf (slot-value object 'data) (make-array 0 :fill-pointer t :adjustable t  :element-type 'float))
 
(gl:bind-vertex-array (slot-value object 'vao))
(gl:bind-buffer :array-buffer (slot-value object 'vbo))
(gl:enable-vertex-attrib-array 0)
(gl:vertex-attrib-pointer 0 3 :float nil 0 (cffi:null-pointer))
(gl:bind-vertex-array 0)
)

(defmethod cg-clean ((object visualgram))
(gl:delete-buffers (list (slot-value object 'vbo)))
(gl:delete-vertex-arrays (list (slot-value object 'vao)))

(call-next-method))

(defmethod cg-visualize :around ((object visualgram))
(if (slot-value object 'update)
    (progn
      (gl:bind-buffer :array-buffer (slot-value object 'vbo))
      (seq-to-glbuf (slot-value object 'data) :float)
;      (print (length (slot-value object 'data)))
;      (seq-sub-glbuf (slot-value object 'data) :float)
      (gl:bind-buffer :array-buffer 0)
      (setf (slot-value object 'update) nil)))

(gl:bind-vertex-array (slot-value object 'vao))
;(gl:draw-elements :points (gl:make-null-gl-array :unsigned-short) :count (slot-value object 'count))
(call-next-method)
(gl:draw-arrays :points 0 (slot-value object 'count))
(gl:bind-vertex-array 0))

;(print "NO!"))

(defmethod vg-load-vec ((object visualgram) (vec vector))
(setf (slot-value object 'count) (/ (length vec) 3))
(setf (slot-value object 'data) (vcoerce-singlef vec))
(setf (slot-value object 'update) t))
;(print vec))