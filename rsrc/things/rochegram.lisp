(ql:quickload "femlisp")
(ql:quickload "femlisp-matlisp")

(defstruct monad location mass velocity)

(defclass rochegram (visualgram)
	((num :initarg :monad-count :initform 2)
		monads))

(defparameter *gk* (coerce (* 6.67300 (expt 10 -11)) 'double-float))
(defparameter *radius* 1.0d0)
(defparameter *time-step* 10d0)

(defmacro m-project (A B)
	`(fl.matlisp:scal (coerce (/ (fl.matlisp:dot ,A ,B) (sqr (fl.matlisp:norm ,B))) 'double-float) ,B))
(defmacro m-unit (A)
	`(fl.matlisp:scal (coerce (/ 1 (fl.matlisp:norm ,A)) 'double-float) ,A))

(defmethod cg-init ((object rochegram))
	(setf (slot-value object 'monads)
		(loop for i below 20
			collect(make-monad :location (fl.matlisp:make-real-vector 3 (sin i)) :mass 100000 :velocity (fl.matlisp:make-real-vector 3 0))))

	(vg-load-vec object (coerce (loop for mon in (slot-value object 'monads)
		append(loop for i below 3 collect (fl.matlisp:mref (monad-location mon) i 0))) 'vector)))

; (slot-value object 'seq) 

(defmethod cg-evaluate ((object rochegram))
	(loop for mon in (slot-value object 'monads)
		do(let* ((force  
			(loop for mon2 in (slot-value object 'monads)
				with fpart = (fl.matlisp:make-real-vector 3 0)
				do(if (not (fl.matlisp:mequalp (monad-location mon) (monad-location mon2)))
					(setf fpart 
						(fl.matlisp:m+ fpart 
							(fl.matlisp:scal (coerce (/ (* *gk* (monad-mass mon) (monad-mass mon2)) (sqr (fl.matlisp:norm (fl.matlisp:m- (monad-location mon2) (monad-location mon))))) 'double-float)
								(m-unit (fl.matlisp:m- (monad-location mon2) (monad-location mon)))))))
				finally(return fpart)))
			;Calculate change in velocity
			(vdelta (fl.matlisp:scal *time-step* (fl.matlisp:scal (coerce (/ 1 (monad-mass mon)) 'double-float) force))))
		(setf (monad-velocity mon) (fl.matlisp:m+ (monad-velocity mon) vdelta))))
	(loop for mon in (slot-value object 'monads)
		do(let ((new-location (fl.matlisp:m+ (fl.matlisp:scal *time-step* (monad-velocity mon)) (monad-location mon))))
		 (if (loop for mon2 in (slot-value object 'monads)
				;Could cause problems...
				with noc = t
				do(if (and (<= (abs (fl.matlisp:norm (fl.matlisp:m- new-location (monad-location mon2)))) *radius*) (not (fl.matlisp:mequalp (monad-location mon) (monad-location mon2))))
					(let* ((center-line (fl.matlisp:m- new-location (monad-location mon2)))
						(proj-vel-1 (m-project (monad-velocity mon) center-line))
						(proj-vel-2 (m-project (monad-velocity mon2) center-line))
						(tang-vel-1 (fl.matlisp:m- (monad-velocity mon) proj-vel-1))
						(tang-vel-2 (fl.matlisp:m- (monad-velocity mon2) proj-vel-2))
						(collision-point (fl.matlisp:m+ (monad-location mon) (fl.matlisp:scal *radius* (m-unit center-line))))
						(time-rem (abs (/ (fl.matlisp:norm (fl.matlisp:m- collision-point (monad-location mon))) (fl.matlisp:norm (monad-velocity mon))))))
					(setf noc nil)
					(setf (monad-velocity mon) (fl.matlisp:m+ tang-vel-1 proj-vel-2))
					(setf (monad-velocity mon2) (fl.matlisp:m+ tang-vel-2 proj-vel-1))
					(setf (monad-location mon) (fl.matlisp:m+ (fl.matlisp:scal (- *time-step* time-rem) (monad-velocity mon)) collision-point))))
finally(return noc))
(setf (monad-location mon) (fl.matlisp:m+ (fl.matlisp:scal *time-step* (monad-velocity mon)) (monad-location mon)))))))

(defmethod cg-visualize ((object rochegram))
	(vg-load-vec object (coerce (loop for mon in (slot-value object 'monads)
		append(loop for i below 3 collect (fl.matlisp:mref (monad-location mon) i 0))) 'vector))
	(call-next-method))