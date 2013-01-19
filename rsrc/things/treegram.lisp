(defclass treegram (vg-vertex vg-color)
	((location :initarg :location :initform '(0.0 0.0 0.0))
	(count :initarg :count :initform 3)
	(length :initarg :length :initform 3)))

(defmethod cg-init ((object treegram))
	(setf (slot-value object 'draw-mode) :lines)
	(let ((alpha (coerce (tree-recursion (slot-value object 'location) (slot-value object 'count) (slot-value object 'length)) 'vector)))
		(vg-load-data object :vert alpha :color (coerce (loop for i below (length alpha) collect (random 1.0)) 'vector))))

(defun tree-recursion (start count length)
	(let ((point (list (- .50 (random 1.0)) (random 1.0) (- .5 (random 1.0)))))
		(setf point (map 'list #'+ start (map 'list #'* (list length length length) point)))
		(if (> count 0)
			(apply #'append (loop repeat (+ 2 (random 3)) collect(append start point (tree-recursion point (1- count) (/ length 1.35)))))
			(append start point))))

(defmethod cg-evaluate ((object treegram)))

(defmethod cg-visualize ((object treegram))
	(call-next-method))