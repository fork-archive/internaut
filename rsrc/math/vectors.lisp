#| (defmacro sv.-op (func a b)
`(let ((result (make-array (length ,a))))
   (loop for x in ,b
      do (cond
	   ((typep x 'vector) 
	    (loop for i from 0 below (length ,a)
	       do (setf (svref result i) (,func (svref ,a i) (svref x i)))))
	   ((typep x 'number)
	    (loop for i from 0 below (length ,a)
	       do (setf (svref result i) (,func (svref ,a i) x))))))
result))

(defun sv.- (a &rest b)
(sv-op - a b))
(defun sv.+ (a &rest b)
(sv-op + a b))
(defun sv./ (a &rest b)
(sv-op / a b))
(defun sv.* (a &rest b)
(sv-op * a b))

(defun sv-magnitude (a)
	(loop for x in a
		collect
(defun sv-project (a b)
(sv-op * a b))

#| (defun sv.= (a &rest b)
(let ((state T)
      (test (coerce (sv-op = a b) 'list)))
  (loop for x in test
     do (if (not x)
	    (setq state nil)))
  state)) |# |#