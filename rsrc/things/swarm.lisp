#|(defvar g 6.673e-11)
(defvar m 10)

(defclass swarm (visualgram)
((vbo :initform (first (gl:gen-buffers 1))) 
 (count :initform 0)
 (update :initform nil)
 data
 (time :initform 0)))

(defmethod sw-move ((object swarm))
(let ndata ((slot-value object 'data))
(loop for x below (length (slot-value object 'data))
(let ((force))
(loop for i below (length (slot-value object 'data))
      do (progn
	   (flet ((inner (a b) (sqr (- (aref (slot-value object 'data) a) (aref (slot-value object 'data) b)))))
		 (setq force (+ force (/ (* g (sqr m)) (sqrt (+ (inner x i) (inner (+ x 1) (+ i 1)) (inner (+ x 2) (+ i 2)))))))))
      finally (return force))
(setf (aref data 


(defmethod cg-init ((object swarm))
  (setf (slot-value object 'data) (make-array 0 :fill-pointer t :adjustable t  :element-type 'float))

;; ----------------------------
  (loop for i from 1 to 100 do
    (loop for j from 1 to 1000 do(progn 
      (vector-push-extend (/ (- j (mod j 100)) 10) (slot-value object 'data))
      (vector-push-extend i (slot-value object 'data))
      (vector-push-extend (mod j 100) (slot-value object 'data)))))
;; ----------------------------

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

(defmethod cg-evaluate ((object swarm))
(setf (slot-value object 'update) t))

(defmethod testgram-update ((object swarm)))

;; ----------------------------------
(let ((ndata  (make-array 0 :fill-pointer t :adjustable t  :element-type 'float)))
(loop for x below (length (slot-value object 'data))
     do (setf (aref (slot-value object 'data) x) (+ (sin (slot-value object 'time)) (aref (slot-value object 'data) x))))
(setf (slot-value object 'time) (+ (slot-value object 'time) (/ pi 32))))
;; ----------------------------------

(setf (slot-value object 'data) (vcoerce-singlef (slot-value object 'data)))
(gl:bind-buffer :array-buffer (slot-value object 'vbo))
(seq-sub-glbuf (slot-value object 'data) :float)
(gl:bind-buffer :array-buffer 0))

(defmethod cg-visualize ((object swarm))
(if (slot-value object 'update) (progn (testgram-update object) (setf (slot-value object 'update) nil)))
(gl:bind-vertex-array (slot-value object 'vao))
;(gl:draw-elements :points (gl:make-null-gl-array :unsigned-short) :count (slot-value object 'count))
(gl:draw-arrays :points 0 (slot-value object 'count))
(gl:bind-vertex-array 0)
(call-next-method))
|#