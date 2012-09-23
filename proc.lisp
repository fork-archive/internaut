(defclass clispgram (STANDARD-OBJECT)
((interval :initarg :interval :initform 1)
 (objlock :initform (make-mutex :name "objlock"))
 (name :initarg :name :initform "clispgram")))

(defgeneric cg-init (object)
(:documentation "REQUIRED - Called after the object is initalized, to setup everything that wasn't already."))
(defgeneric cg-evaluate (object)
(:documentation "REQUIRED - Evaluate a clispgram, updating its internal structure. This is called as often as the clispgram specifies in 'interval."))
(defgeneric cg-interval (object)
(:documentation "REQUIRED - Indicate how often the clispgram should be updated in evaluations. A value of one, for example, would indicate that it should be updated every loop-through."))
(defgeneric cg-clean (object)
(:documentation "REQUIRED - Called when closing a clispgram."))

(defgeneric cg-lock (object)
(:documentation "Locks the object for the calling thread. Must be used before modifying any object."))
(defgeneric cg-unlock (object)
(:documentation "Unlocks an object from the calling thread. Must be used in conjunction with 'CG-LOCK"))
(defgeneric cg-scoped-lock (object function)
(:documentation "Scope locks a call for an object. The function must be a predefined 'LAMBDA."))

(defgeneric cg-visualize (object)
(:documentation "Called by the OpenGL loop, this function directly utilizes the GL to display data"))

(defmethod cg-init ((object clispgram))())
(defmethod cg-evaluate ((object clispgram)) ())

(defmethod cg-interval ((object clispgram))
(slot-value object 'interval))
(defmethod cg-clean ((object clispgram))
(release-mutex (slot-value object 'objlock)))

(defmethod cg-lock ((object clispgram))
(get-mutex (slot-value object 'objlock)))
(defmethod cg-unlock ((object clispgram))
(release-mutex (slot-value object 'objlock)))
(defmethod cg-scoped-lock ((object clispgram) function)
(with-mutex ((slot-value object 'objlock)) function))

(defmethod cg-visualize ((object clispgram))())

(defvar *cg-box* '())
(defvar *cg-box-lock* (make-mutex :name "pickme"))
"This is locked by the GL loop. In order to modify the list, we must lock this mutex."

(defvar *cg-run-lock* (make-mutex :name "runlock"))

(defmethod add-to-cg-box ((object clispgram))
(with-mutex (*cg-box-lock*)
  (cg-init object)
  (setf *cg-box* (append *cg-box* (list (list object 0))))))

(defun proc-loop ()
(let ((ticks  0))
  (loop (progn (setq ticks (get-internal-run-time))
	       (with-mutex (*cg-run-lock*)
          (loop for obj in *cg-box*
	     do (let ((fi (nth 0 obj))
		      (la (nth 1 obj)))
		(if (= 0 la)
		    (progn
		      (cg-lock fi)
		      (cg-evaluate fi)
		      (setf la (cg-interval fi))
		      (cg-unlock fi))
		    (setf la (- la 1)))
		)))

	        (let ((time (- (get-internal-run-time) ticks)))
		    (if (< time (* *proc-jump* *itups*))
			(sleep (- *proc-jump* (/ time *itups*)))
			()
))))))
(defun proc-quit () ())
