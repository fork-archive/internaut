(defvar /4b4/ (mvec '(4 4) 0))
(defmacro armi-ref4 (vec &rest index)
	`(svref ,vec (+ (nth 0 (list ,@index)) (* (nth 1 (list ,@index)) 4))))
;`(svref ,vec (array-row-major-index ,/4b4/ ,@index)))

(defun armi-vec4 (vec index)
	(let ((vec4 (mvec 4 0)))
		(setf (svref vec4 0) (armi-ref4 vec index 0))
		(setf (svref vec4 1) (armi-ref4 vec index 1))
		(setf (svref vec4 2) (armi-ref4 vec index 2))
		(setf (svref vec4 3) (armi-ref4 vec index 3))
		vec4))

(defun radians (degrees)
	(* degrees (/ pi 180)))

(defun neg (num)
	(- 0 num))

#|
(defclass glm-matrix ()
	((dims :initarg :dims :initform '(4 4))
		(data :initarg :data :initform (mvec 16 0))))
(defmethod m* ((mat1 glm-matrix)(mat2 glm-matrix))
	(cond (= (slot-value mat dims))
		|#

		(defmacro sv-op (func a b)
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

		(defun sv- (a &rest b)
			(sv-op - a b))
		(defun sv+ (a &rest b)
			(sv-op + a b))
		(defun sv/ (a &rest b)
			(sv-op / a b))
		(defun sv* (a &rest b)
			(sv-op * a b))
		(defun sv= (a &rest b)
			(let ((state T)
				(test (coerce (sv-op = a b) 'list)))
			(loop for x in test
				do (if (not x)
					(setq state nil)))
			state))

;(defun m4*4 (a &rest b)
;(let ((result (mvec 16 0)))
;  (

	(defun vec-apply (func a)
		(apply func (coerce a 'list)))

;GLM

(defun glm-normalize (vec)
	(if (not (sv= vec (vector 0 0 0)))
		(let ((d (sqrt (apply #'+ (map 'list #'sqr vec)))))
			(map 'vector #'(lambda (x) (/ x d)) vec))
		(vector 0 0 0)))

(defun glm-dot (vec1 vec2)
	(let ((A 0))
		(setf A (+ A (* (svref vec1 0) (svref vec2 0))))
		(setf A (+ A (* (svref vec1 1) (svref vec2 1))))
		(setf A (+ A (* (svref vec1 2) (svref vec2 2))))
		A))

(defun glm-cross (vec1 vec2)
	(let ((vec3 (mvec 3 0)))
		(setf (svref vec3 0) (- (* (svref vec1 1) (svref vec2 2)) (* (svref vec1 2) (svref vec2 1))))
		(setf (svref vec3 1) (- (* (svref vec1 2) (svref vec2 0)) (* (svref vec1 0) (svref vec2 2))))
		(setf (svref vec3 2) (- (* (svref vec1 0) (svref vec2 1)) (* (svref vec1 1) (svref vec2 0))))
		vec3))

(defun glm-perspective (fovy aspect znear zfar)
	(let* ((range (* (tan (radians (/ fovy 2))) zNear))
		(left (* (neg range) aspect))
		(right (* range aspect))
		(bottom (neg range))
		(top range)
		(result (mvec 16 0)))
	
	(setf (armi-ref4 result 0 0) (/ (* znear 2) (- right left)))
	(setf (armi-ref4 result 1 1) (/ (* znear 2) (- top bottom)))
	(setf (armi-ref4 result 2 2) (neg (/ (+ zFar zNear) (- zFar zNear))))
	(setf (armi-ref4 result 2 3) -1)
	(setf (armi-ref4 result 3 2) (neg (/ (* 2 zFar zNear) (- zFar zNear))))
	result))

(defun glm-ortho (left right bottom top znear zfar)
	(let ((result (mvec 16 1)))
		(setf (armi-ref4 result 0 0) (/ 2 (- right left)))
		(setf (armi-ref4 result 1 1) (/ 2 (- top bottom)))
		(setf (armi-ref4 result 2 2) (neg (/ 2 (- zFar zNear))))
		(setf (armi-ref4 result 3 0) (neg (/ (+ right left) (- right left))))
		(setf (armi-ref4 result 3 1) (neg (/ (+ top bottom) (- top bottom))))
		(setf (armi-ref4 result 3 2) (neg (/ (+ zFar zNear) (- zFar zNear))))
		result))

(defun glm-translate (m v)
;(let ((result m)
	#|
	(let ((result (mvec 16 0))
		(temp (sv+
			(sv* (armi-vec4 m 0) (svref v 0))
			(sv* (armi-vec4 m 1) (svref v 1))
			(sv* (armi-vec4 m 2) (svref v 2)) 
			(armi-vec4 m 3))))
	 ;(setf (svref result 3) (+ (* (svref m 0) (svref v 0)) (* (svref m 1) (svref v 1)) (* (svref m 2) (svref v 2)) (svref m 3)))
	 (setf (armi-ref4 result 3 0) (svref temp 0))
	 (setf (armi-ref4 result 3 1) (svref temp 1))
	 (setf (armi-ref4 result 3 2) (svref temp 2))
	 (setf (armi-ref4 result 3 3) (svref temp 3))

	 (setf (armi-ref4 result 0 0) 1)
	 (setf (armi-ref4 result 1 1) 1)
	 (setf (armi-ref4 result 2 2) 1)
	 (setf (armi-ref4 result 3 3) 1)

	 result))
|#

(let ((result (mvec 16 0)))
	(setf (armi-ref4 result 0 0) 1)
	(setf (armi-ref4 result 1 1) 1)
	(setf (armi-ref4 result 2 2) 1)
	(setf (armi-ref4 result 3 3) 1)

	(setf (armi-ref4 result 3 0) (svref v 0))
	(setf (armi-ref4 result 3 1) (svref v 1))
	(setf (armi-ref4 result 3 2) (svref v 2))
	result))

(defun glm-scale (m v)
	(let ((result (mvec 16 0)))
		(setf (svref result 0) (* (svref m 0) (svref v 0)))
		(setf (svref result 1) (* (svref m 1) (svref v 1)))
		(setf (svref result 2) (* (svref m 2) (svref v 2)))
		(setf (svref result 3) (svref m 3))
		result))

(defun glm-look-at (eye center up)
	(let* ((result (mvec 16 1))
		(f (glm-normalize (sv- center eye)))
		(s (glm-normalize (glm-cross f (glm-normalize up))))
		(u (glm-cross s f)))

	(setf (armi-ref4 result 0 0) (svref s 0))
	(setf (armi-ref4 result 1 0) (svref s 1))
	(setf (armi-ref4 result 2 0) (svref s 2))

	(setf (armi-ref4 result 0 1) (svref u 0))
	(setf (armi-ref4 result 1 1) (svref u 1))
	(setf (armi-ref4 result 2 1) (svref u 2))

	(setf (armi-ref4 result 0 2) (neg (svref f 0)))
	(setf (armi-ref4 result 1 2) (neg (svref f 1)))
	(setf (armi-ref4 result 2 2) (neg (svref f 2)))

	(setf (armi-ref4 result 3 0) (neg (glm-dot s eye)))
	(setf (armi-ref4 result 3 1) (neg (glm-dot u eye)))
  ;(setf (armi-ref4 result 3 1) (neg (vec-apply #'+ (sv* u eye))))
  (setf (armi-ref4 result 3 2) (glm-dot f eye))
  (setf (armi-ref4 result 3 3) 1)
  
  result))
