(gl:define-gl-array-format simple-three
    (gl:vertex :type :float :components (x y z)))

;(defmacro lname (a b)
;  `(b (slot-value a b))) 

(defun coerce-sequence (ctype seq)
  (map (class-of seq) (lambda (a) (coerce a ctype)) seq))

(defun coerce-vfloat (vec)
(map 'vector (lambda (num) (coerce num 'float)) vec))

(defun coerce-singlef (lst)
(mapcar (lambda (a) (coerce a 'single-float)) lst))

(defun vcoerce-singlef (vst)
(map 'vector (lambda (a) (coerce a 'single-float)) vst))

(defun vertex-list-to-gl-array(list)
	(let ((alpha (gl:alloc-gl-array 'simple-three (length list)))
	      (lst (coerce-singlef list)))
		(loop for i from 0 to (- (/ (length lst) 3) 1)
		     do (progn (setf (gl:glaref alpha i 'x) (nth (* i 3) lst))
			       (setf (gl:glaref alpha i 'y) (nth (+ (* i 3) 1) lst))
			       (setf (gl:glaref alpha i 'z) (nth (+ (* i 3) 2) lst))
			       )
		     finally (return alpha))))

(defun list-to-gl-array(type list)
  (let ((alpha (gl:alloc-gl-array type (length list))))
    (loop for i from 0 to (- (length list) 1)
	 do (setf (gl:glaref alpha i) (nth i list))
	 finally (return alpha))))

(defun vector-to-gl-array(type list)
  (let ((alpha (gl:alloc-gl-array type (length list))))
    (loop for i from 0 below (length list)
	 do (setf (gl:glaref alpha i) (aref list i))
	 finally (return alpha))))

(defun repl-loop ()
	(loop for done from 0 while (= done 0) do
		(print (eval (read)))))

(defun load-file (a)
  (with-open-file (stream a)
  (let ((seq (make-string (file-length stream))))
    (read-sequence seq stream)
    seq)))

(defun sqr (x) (* x x))
(defun clength (x) (- (length x) 1))
(defun setf-add (a b)
  (setf a (+ a b)))
(defun list-add (a b); Add b to a
  (if (= (length a) (length b))
       (loop for i from 0 to (clength a)
	    collect (+ (nth i a) (nth i b)))))
(defun list-subtract (a b); Subtract b from a
  (if (= (length a) (length b))
       (loop for i from 0 to (clength a)
	    collect (- (nth i a) (nth i b)))))

(defun normalize-list (vec)
  (let ((d (sqrt (+ (mapcar #'sqr vec)))))
    (mapcar #'(lambda (x) (/ x d)) vec)))
(defun cross-list (vec1 vec2)
  (let ((vec3 (list 0 0 0)))
    (setf (nth 0 vec3) (- (* (nth 1 vec1) (nth 2 vec2)) (* (nth 2 vec1) (nth 1 vec2))))
    (setf (nth 1 vec3) (- (* (nth 2 vec1) (nth 0 vec2)) (* (nth 0 vec1) (nth 2 vec2))))
    (setf (nth 2 vec3) (- (* (nth 0 vec1) (nth 1 vec2)) (* (nth 1 vec1) (nth 0 vec2))))
    vec3))

(defmacro mvec (a b &rest c)
`(make-array ,a :initial-element ,b ,@c))

(defmacro setref (a b c)
`(setf (aref ,a ,b) ,c))

#|
(defun gl-look-at (matrix eyepos center upv)
   (let ((forward side up)
	 (mat (make-array '(4 4) :element-type float :initial-element 0)))
     (setq forward (list-subtract center eyepos))
     (setq forward (normalize-vector forward))
     (setq up upv)
     (setq side (cross-vector forward up side))
     (setq side (normalize-vector side))
     (setq up (cross-vector side forward up))      
     
     ;(setf (aref '(0 0)) 1)
     ;(setf (aref '(1 1)) 1)
     ;(setf (aref '(2 2)) 1)
     (setf (aref '(3 3) mat) 1)

     (setf (aref '(0 0) mat) (nth 0 side))
     (setf (aref '(1 0) mat) (nth 1 side))
     (setf (aref '(2 0) mat) (nth 2 side))

     (setf (aref '(0 1) mat) (nth 0 up))
     (setf (aref '(1 1) mat) (nth 1 up))
     (setf (aref '(2 1) mat) (nth 2 up))

     (setf (aref '(0 2) mat) (0 - (nth 0 forward)))
     (setf (aref '(1 2) mat) (0 -(nth 1 forward)))
     (setf (aref '(2 2) mat) (0 -(nth 2 forward)))

     (setq
|#