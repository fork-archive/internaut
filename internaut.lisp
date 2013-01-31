(ql:quickload '("cl-opengl" "bordeaux-threads" "lispbuilder-sdl" "lispbuilder-sdl-ttf" "lispbuilder-sdl-image"))

(defparameter *config-default* "rsrc/otterconf")
(defparameter *internaut-config* nil)
(defparameter *internaut-locks* nil)


(defmacro cgi (var)	"Shortening of (config-get *internaut-config* 'var)"
	`(config-get *internaut-config* ,var))
(defmacro cgs (var val)
	"Shortening of (config-set *internaut-config* 'var)"
	`(config-set *internaut-config* ,var ,val))

(defun internaut-load ()
	(labels ((recursive-load (dir) 
		(loop for i in (directory (concatenate 'string dir "/*.lisp"))
			do(load i))
		(loop for i in (directory (concatenate 'string dir "/*/"))
			do (recursive-load (namestring i)))))

	(load "rsrc/config.lisp")
	(setf *internaut-config* (make-instance 'config))
	(config-init *internaut-config* :location "rsrc/config")

	(load "rsrc/utils.lisp")
	(recursive-load "rsrc/math")

	(load "rsrc/clispgram.lisp")
	(recursive-load "rsrc/grams")

	(load "rsrc/interact.lisp")
	(load "rsrc/interface.lisp")
	(load "rsrc/proc.lisp")
	(recursive-load "rsrc/things")

	(load "rsrc/resource.lisp")

	(load "rsrc/main.lisp")))

 ;(bordeaux-threads:make-thread (lambda ()
	(internaut-load)
	(main)
	(config-save *internaut-config*);))