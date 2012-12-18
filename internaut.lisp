(ql:quickload "cl-opengl")
(ql:quickload "lispbuilder-sdl")
(ql:quickload "bordeaux-threads")

(defparameter *config-default* "rsrc/otterconf")
(defparameter *internaut-config* nil)
(defparameter *internaut-locks* nil)

(defun internaut-load ()
	(flet ((recursive-load (dir) 
		(loop for i in (directory (concatenate 'string dir "/*.lisp"))
			do(load i))
		(loop for i in (directory (concatenate 'string dir "/*/"))
			do (recursive-load (native-namestring i)))))

	(load "rsrc/config.lisp")
	(setf *internaut-config* (make-instance 'config))
	(config-init *internaut-config* :location "rsrc/config")

	(defmacro cgi (var)	"Shortening of (config-get *internaut-config* 'var)"
		`(config-get *internaut-config* ,var))
	(defmacro cgs (var val)
		"Shortening of (config-set *internaut-config* 'var)"
		`(config-set *internaut-config* ,var ,val))

	(load "rsrc/utils.lisp")
	(recursive-load "rsrc/math")

	(load "rsrc/clispgram.lisp")
	(recursive-load "rsrc/grams")

	(load "rsrc/interact.lisp")
	(load "rsrc/interface.lisp")
	(load "rsrc/proc.lisp")
	(recursive-load "rsrc/things")

	(load "rsrc/main.lisp")))

;(bordeaux-threads:make-thread (lambda ()
	(internaut-load)
	(main)
	(config-save *internaut-config*);))