(defclass visualgram (clispgram)
  (vao

    (vertex-data :initform nil)
    (vertex-update :initform nil)
    vertex-buffer

    (index-data :initform nil)
    (index-update :initform nil)
    index-buffer

    (normal-data :initform nil)
    (normal-update :initform nil)
    normal-buffer

    (texture-data :initform nil)
    (texture-update :initform nil)
    texture-buffer

    (draw-mode :initform :points)

    (count :initform 0)))

(defmethod cg-init :before ((object visualgram))
  (setf (slot-value object 'vao) (gl:gen-vertex-array))

  (setf (slot-value object 'vertex-buffer) (first (gl:gen-buffers 1)))
  (setf (slot-value object 'index-buffer) (first (gl:gen-buffers 1)))
  (setf (slot-value object 'normal-buffer) (first (gl:gen-buffers 1)))
  (setf (slot-value object 'texture-buffer) (first (gl:gen-buffers 1)))

  (gl:bind-vertex-array (slot-value object 'vao))
  (gl:bind-buffer :array-buffer (slot-value object 'vertex-buffer))
  (gl:enable-vertex-attrib-array 0)
  (gl:vertex-attrib-pointer 0 3 :float nil 0 (cffi:null-pointer))
  (gl:bind-vertex-array 0))

(defmethod cg-clean ((object visualgram))
  (gl:delete-buffers (list (slot-value object 'vertex-buffer)))
  (gl:delete-vertex-arrays (list (slot-value object 'vao)))
  (call-next-method))

(defmethod cg-visualize :around ((object visualgram))
  (if (slot-value object 'vertex-update)
    (progn
      (gl:bind-buffer :array-buffer (slot-value object 'vertex-buffer))
      (seq-to-glbuf (coerce-sequence 'single-float (slot-value object 'vertex-data)) :float)
      (gl:bind-buffer :array-buffer 0)

      (setf (slot-value object 'count) (length (slot-value object 'vertex-data)))

      (setf (slot-value object 'vertex-update) nil)))
  (if (slot-value object 'index-update) 1)
  (if (slot-value object 'normal-update) 1)
  (if (slot-value object 'texture-update) 1)
  (gl:bind-vertex-array (slot-value object 'vao))
  (call-next-method)
  (gl:draw-arrays (slot-value object 'draw-mode) 0 (slot-value object 'count))
  (gl:bind-vertex-array 0))

(defmethod vg-load-vert ((object visualgram) (vec vector))
  (setf (slot-value object 'vertex-data) (make-array (length vec) :element-type 'single-float :initial-contents (coerce-sequence 'single-float vec)))
  (setf (slot-value object 'vertex-update) t))

(defmethod vg-load-ind ((object visualgram) (vec vector))
  (setf (slot-value object 'index-data) (make-array (length vec) :element-type 'single-float :initial-contents vec))
  (setf (slot-value object 'index-update) t))

(defmethod vg-load-norm ((object visualgram) (vec vector))
  (setf (slot-value object 'normal-data) (make-array (length vec) :element-type 'single-float :initial-contents vec))
  (setf (slot-value object 'normal-update) t))

(defmethod vg-load-tex ((object visualgram) (vec vector))
  (setf (slot-value object 'texture-data) (make-array (length vec) :element-type 'single-float :initial-contents vec))
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