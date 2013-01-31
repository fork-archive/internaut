(defvar *cg-box* '())
(defvar *cg-box-2d* '())
(defvar *cg-box-lock* (bordeaux-threads:make-lock))
"This is locked by the GL loop. In order to modify the list, we must lock this mutex."

(defvar *cg-run-lock* (bordeaux-threads:make-lock))

(defmethod add-to-cg-box ((object clispgram) &key (2d nil))
	(bordeaux-threads:with-lock-held (*cg-box-lock*)
		(cg-init object)
		(if 2d
			(setf *cg-box-2d* (append *cg-box-2d* (list (list object 0))))
			(setf *cg-box* (append *cg-box* (list (list object 0)))))))

(defun proc-loop ()
	(let ((ticks  0))
		(loop (progn (setq ticks (get-internal-run-time))
			(bordeaux-threads:with-lock-held (*cg-run-lock*)
				(mapcar (lambda (a)
					(loop for obj in a
						do (if (= 0 (cadr obj))
							(progn
								(cg-lock (car obj))
								(cg-evaluate (car obj))
								(setf (cadr obj) (cg-interval (car obj)))
								(cg-unlock (car obj)))
							(setf (cadr obj) (1- (cadr obj)))))) (list *cg-box* *cg-box-2d*)))
			(let ((time (- (get-internal-run-time) ticks)))
				(if (< time (* *proc-jump* *itups*))
					(sleep (- *proc-jump* (/ time *itups*)))
					()
					))))))
(defun proc-quit () ())
