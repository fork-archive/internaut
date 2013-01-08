(defclass visualgram (clispgram)
  (vao
    (draw-mode :initform :points)
    (count :initform 0)))

(defmacro vg-component (name gl-index gl-count)
  (let ((class (intern (concatenate 'string "VG-" name)))
    (data (intern (concatenate 'string "DATA-" name)))
    (buffer (intern (concatenate 'string "BUFFER-" name))) 
    (update (intern (concatenate 'string "UPDATE-" name))))

  `(progn   

    (defclass ,class (visualgram)
      (,data 
       ,buffer
       (,update :initform nil)))

    (defmethod cg-init :before ((object ,class))
      (setf (slot-value object ',buffer) (car (gl:gen-buffers 1)))
      (gl:bind-vertex-array (slot-value object 'vao))
      (gl:bind-buffer :array-buffer (slot-value object ',buffer))
      (gl:enable-vertex-attrib-array ,gl-index)
      (gl:vertex-attrib-pointer ,gl-index ,gl-count :float nil 0 (cffi:null-pointer))
      (gl:bind-vertex-array 0))

    (defmethod cg-visualize :around ((object ,class))
      (if (slot-value object ',update)
        (progn
          (gl:bind-buffer :array-buffer (slot-value object ',buffer))
          (seq-to-glbuf (coerce-sequence 'single-float (slot-value object ',data)) :float)
          (gl:bind-buffer :array-buffer 0)
          (setf (slot-value object 'count) (length (slot-value object ',data)))
          (setf (slot-value object ',update) nil)))
      ,(if (string= name "COLOR")
        '(%gl:uniform-1i *color* 1)
        '(%gl:uniform-1i *color* 0))
      (call-next-method))

    (defmethod cg-clean ((object ,class))
      (gl:delete-buffers (list (slot-value object ',buffer)))
      (call-next-method)))))

(vg-component "VERTEX" 0 3)
(vg-component "TEXCOORD" 1 2)
(vg-component "INDEX" 2 1)
(vg-component "NORMAL" 3 3)
(vg-component "COLOR" 4 3)

(defclass vg-texture (visualgram)
  (texture-path
    texture-id
   (texture-type :initform :texture-2d)
   (texture-update :initform nil)))

;;cg-init
(defmethod cg-init :around ((object visualgram))
  (setf (slot-value object 'vao) (gl:gen-vertex-array))
  (call-next-method))

;;cg-clean
(defmethod cg-clean ((object visualgram))
  (gl:delete-vertex-arrays (list (slot-value object 'vao)))
  (call-next-method))

(defmethod cg-clean ((object vg-texture))
  (unclaim-texture (slot-value object 'texture-path))
  (call-next-method))

;;cg-visualize
(defmethod cg-visualize :around ((object visualgram))
  (gl:bind-vertex-array (slot-value object 'vao))
  (call-next-method)
  (gl:draw-arrays (slot-value object 'draw-mode) 0 (slot-value object 'count))
  (gl:bind-vertex-array 0)
  (call-next-method))

(defmethod cg-visualize :around ((object vg-texture))
 (if (slot-value object 'texture-update)
   (progn
    (setf (slot-value object 'texture-id) (claim-texture (slot-value object 'texture-path)))
    (setf (slot-value object 'texture-update) nil)))
 (gl:bind-texture (slot-value object 'texture-type) (slot-value object 'texture-id))
 (call-next-method))


(defmethod vg-load-data ((object visualgram) &key (vert nil) (ind nil) (norm nil) (coord nil) (tex nil) (color nil))
  (if vert
    (progn
      (setf (slot-value object 'data-vertex) (make-array (length vert) :element-type 'single-float :initial-contents (coerce-sequence 'single-float vert)))
      (setf (slot-value object 'update-vertex) t)))
  (if ind
    (progn
      (setf (slot-value object 'data-index) (make-array (length ind) :element-type 'single-float :initial-contents (coerce-sequence 'single-float ind)))
      (setf (slot-value object 'update-index) t)))
  (if norm
    (progn
      (setf (slot-value object 'data-normal) (make-array (length norm) :element-type 'single-float :initial-contents (coerce-sequence 'single-float norm)))
      (setf (slot-value object 'update-normal) t)))
  (if coord
    (progn
      (setf (slot-value object 'data-texcoord) (make-array (length coord) :element-type 'single-float :initial-contents (coerce-sequence 'single-float coord)))
      (setf (slot-value object 'update-texcoord) t)))
  (if tex
    (progn
      (setf (slot-value object 'texture-path) tex)
      (setf (slot-value object 'texture-update) t)))
  (if color
    (progn
      (setf (slot-value object 'data-color) (make-array (length color) :element-type 'single-float :initial-contents (coerce-sequence 'single-float color)))
      (setf (slot-value object 'update-color) t))))

(defun seq-sub-glbuf(vec type &key (offset 0) (size (length vec)))
  (gl:with-mapped-buffer (p :array-buffer :write-only)
   (loop for i from offset below size
     do (setf (cffi:mem-aref p type i) (aref vec i)))))

(defun seq-to-glbuf(vec type &key (draw :dynamic-draw))
  (%gl:buffer-data :array-buffer (* (length vec) (cffi:foreign-type-size type)) (cffi:null-pointer) draw)
  (seq-sub-glbuf vec type))