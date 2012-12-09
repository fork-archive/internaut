(defclass clispgram (STANDARD-OBJECT)
	((interval :initarg :interval :initform 1)
		(objlock :initform (sb-thread:make-mutex :name "objlock"))
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
	(sb-thread:release-mutex (slot-value object 'objlock)))

(defmethod cg-lock ((object clispgram))
	(sb-thread:grab-mutex (slot-value object 'objlock)))
(defmethod cg-unlock ((object clispgram))
	(sb-thread:release-mutex (slot-value object 'objlock)))
(defmethod cg-scoped-lock ((object clispgram) function)
	(sb-thread:with-mutex ((slot-value object 'objlock)) function))

(defmethod cg-visualize ((object clispgram))())