(defclass visualgram (clispgram)
  (vao
    (draw-mode :initform :points)
    (count :initform 0)))

(defclass vg-vertex (visualgram)
  (vertex-data 
   vertex-buffer
   (vertex-update :initform nil)))

(defclass vg-texture (visualgram)
  (texcoord-data
   texcoord-buffer
   (texcoord-update :initform nil)

   texture-path
   (texture-type :initform :texture-2d)
   (texture-update :initform nil)))

(defclass vg-normal (visualgram)
  (index-data
   index-buffer
   normal-data
   normal-buffer
   (normal-update :initform nil)))

(defclass vg-color (visualgram)
  (color-data
   color-buffer
   (color-update :initform nil)))

;;cg-init
(defmethod cg-init :around ((object visualgram))
  (setf (slot-value object 'vao) (gl:gen-vertex-array))
  (call-next-method))

(defmethod cg-init :before ((object vg-vertex))
  (setf (slot-value object 'vertex-buffer) (car (gl:gen-buffers 1)))
  (gl:bind-vertex-array (slot-value object 'vao))
  (gl:bind-buffer :array-buffer (slot-value object 'vertex-buffer))
  (gl:enable-vertex-attrib-array 0)
  (gl:vertex-attrib-pointer 0 3 :float nil 0 (cffi:null-pointer))
  (gl:bind-vertex-array 0))

(defmethod cg-init :before ((object vg-texture))
  (setf (slot-value object 'texcoord-buffer) (car (gl:gen-buffers 1)))
  (gl:bind-vertex-array (slot-value object 'vao))
  (gl:bind-buffer :array-buffer (slot-value object 'texcoord-buffer))
  (gl:enable-vertex-attrib-array 1)
  (gl:vertex-attrib-pointer 1 2 :float nil 0 (cffi:null-pointer))
  (gl:bind-vertex-array 0))

(defmethod cg-init :before ((object vg-normal))
  (setf (slot-value object 'index-buffer) (car (gl:gen-buffers 1)))
  (setf (slot-value object 'normal-buffer) (car (gl:gen-buffers 1))))

;;cg-clean
(defmethod cg-clean ((object visualgram))
  (gl:delete-vertex-arrays (list (slot-value object 'vao)))
  (call-next-method))
(defmethod cg-clean ((object vg-vertex))
  (gl:delete-buffers (list (slot-value object 'vertex-buffer)))
  (call-next-method))
(defmethod cg-clean ((object vg-normal))
  (gl:delete-buffers (list (slot-value object 'index-buffer) (slot-value object 'normal-buffer)))
  (call-next-method))
(defmethod cg-clean ((object vg-texture))
  (unclaim-texture (slot-value object 'texture-path))
  (call-next-method))

;;cg-visualize
(defmethod cg-visualize :around ((object vg-vertex))
  (if (slot-value object 'vertex-update)
    (progn
      (gl:bind-buffer :array-buffer (slot-value object 'vertex-buffer))
      (seq-to-glbuf (coerce-sequence 'single-float (slot-value object 'vertex-data)) :float)
      (gl:bind-buffer :array-buffer 0)
      (setf (slot-value object 'count) (length (slot-value object 'vertex-data)))
      (setf (slot-value object 'vertex-update) nil)))
  (call-next-method))

(defmethod cg-visualize :around ((object vg-normal))
  (if (slot-value object 'normal-update)
    (progn
      (gl:bind-buffer :array-buffer (slot-value object 'normal-buffer))
      (seq-to-glbuf (coerce-sequence 'single-float (slot-value object 'normal-data)) :float)
      (gl:bind-buffer :array-buffer 0)
      ;(setf (slot-value object 'count) (length (slot-value object 'normal-data)))
      ;setf (slot-value object 'normal-update) nil))
    ))
(call-next-method))

(defmethod cg-visualize :around ((object vg-texture))
 (if (slot-value object 'texture-update)
   (progn
    (gl:bind-vertex-array (slot-value object 'vao))
    (print (claim-texture (slot-value object 'texture-path)))
    (gl:bind-texture (slot-value object 'texture-type) (claim-texture (slot-value object 'texture-path)))
    (gl:bind-vertex-array 0)
    (setf (slot-value object 'texture-update) nil)))
 (if (slot-value object 'texcoord-update)
  (progn
    (gl:bind-buffer :array-buffer (slot-value object 'texcoord-buffer))
    (seq-to-glbuf (coerce-sequence 'single-float (slot-value object 'texcoord-data)) :float)
    (gl:bind-buffer :array-buffer 0)
    (setf (slot-value object 'texcoord-update) nil)))
 (call-next-method))

(defmethod cg-visualize :around ((object visualgram))
  (gl:bind-vertex-array (slot-value object 'vao))
  (call-next-method)
  (gl:draw-arrays (slot-value object 'draw-mode) 0 (slot-value object 'count))
  (gl:bind-vertex-array 0)
  (call-next-method))

(defmethod vg-load-vert ((object vg-vertex) (vec vector))
  (setf (slot-value object 'vertex-data) (make-array (length vec) :element-type 'single-float :initial-contents (coerce-sequence 'single-float vec)))
  (setf (slot-value object 'vertex-update) t))

(defmethod vg-load-ind ((object vg-texture) (vec vector))
  (setf (slot-value object 'index-data) (make-array (length vec) :element-type 'single-float :initial-contents vec))
  (setf (slot-value object 'index-update) t))

(defmethod vg-load-norm ((object vg-normal) (vec vector))
  (setf (slot-value object 'normal-data) (make-array (length vec) :element-type 'single-float :initial-contents vec))
  (setf (slot-value object 'normal-update) t))

(defmethod vg-load-coor ((object visualgram) (vec vector))
  (setf (slot-value object 'texcoord-data) (make-array (length vec) :element-type 'single-float :initial-contents vec))
  (setf (slot-value object 'texcoord-update) t))

(defmethod vg-load-tex ((object visualgram) path)
  (setf (slot-value object 'texture-path) path)
  (setf (slot-value object 'texture-update) t))

(defmethod vg-load-data ((object visualgram) (vert vector) &key ind norm tex)
  (vg-load-vert object vert)
  (if ind
    (vg-load-ind object ind))
  (if norm
    (vg-load-norm object ind))
  (if tex
    (vg-load-tex object ind)))

(defun seq-sub-glbuf(vec type &key (offset 0) (size (length vec)))
  (gl:with-mapped-buffer (p :array-buffer :write-only)
   (loop for i from offset below size
     do (setf (cffi:mem-aref p type i) (aref vec i)))))

(defun seq-to-glbuf(vec type &key (draw :dynamic-draw))
  (%gl:buffer-data :array-buffer (* (length vec) (cffi:foreign-type-size type)) (cffi:null-pointer) draw)
  (seq-sub-glbuf vec type))