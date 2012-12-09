(defvar *cg-box* '())
(defvar *cg-box-lock* (sb-thread:make-mutex :name "pickme"))
"This is locked by the GL loop. In order to modify the list, we must lock this mutex."

(defvar *cg-run-lock* (sb-thread:make-mutex :name "runlock"))

(defmethod add-to-cg-box ((object clispgram))
	(sb-thread:with-mutex (*cg-box-lock*)
		(cg-init object)
		(setf *cg-box* (append *cg-box* (list (list object 0))))))

(defun proc-loop ()
	(let ((ticks  0))
		(loop (progn (setq ticks (get-internal-run-time))
			(sb-thread:with-mutex (*cg-run-lock*)
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