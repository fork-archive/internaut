(defclass config (STANDARD-OBJECT)
	((options :initform (make-hash-table))
		(file :initform *config-default*)))

(defgeneric config-init (object &key location)
	(:documentation "Parses a configuration file. If none is specificed, defaults *CONFIG-DEFAULT*. If the specified file is blank, or does not exist, it will be created."))
(defgeneric config-reload (object)
	(:documentation "Reloads the configuration file."))
(defgeneric config-save (object)
	(:documentation "Saves the configuration file."))
(defgeneric config-get (object str)
	(:documentation "Searches for the value assoc. with the given string. If no value is found, returns 'DNE'"))
(defgeneric config-set (object str val)
	(:documentation "Sets the given value for the given string"))

(defmethod config-init ((object config) &key (location file))
	(let ((inf (open location)))
		(if inf
			(loop for i in (read inf)
				do (progn
						(print (car i)) 
						(setf (gethash (car i) (slot-value object 'options)) (cdr i)))))
		(close inf))
	(setf (slot-value object 'file) location))

(defmethod config-reload ((object config)))

(defmethod config-save ((object config))
	(let ((inf (open (slot-value object 'file) :direction :output :if-exists :overwrite)))
		(format inf "(~%")
		(flet ((key-save (key value)
				(format inf "(~S . ~S)~%" key value)))
			(maphash #'key-save (slot-value object 'options)))
		(format inf ")~%")
		(close inf)))

(defmethod config-get ((object config) str)
	(gethash str (slot-value object 'options)))

(defmethod config-set ((object config) str val)
	(setf (gethash str (slot-value object 'options)) val))