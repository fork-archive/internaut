(defparameter *texture-hash* (make-hash-table))
;Knowledge courtesy of "http://3bb.cc/tutorials/cl-opengl/textures-part-2.html"
(defun load-texture (path)
	"Documentation for load-texture."
	(let ((texture (car (gl:gen-textures 1)))
		(image (sdl:load-image path)))
	(gl:bind-texture :texture-2d texture)
	(gl:tex-parameter :texture-2d :texture-min-filter :linear)
	(gl:tex-parameter :texture-2d :texture-wrap-s :repeat);
	(gl:tex-parameter :texture-2d :texture-wrap-t :repeat);
	(surface-to-texture image)
	(setf (gethash path *texture-hash*) (cons texture 1))
	texture))
(defun unload-texture (path)
	"Documentation for unload-texture."
	(gl:delete-textures (list (car (gethash path *texture-hash*)))))
(defun claim-texture (path)
	"Documentation for claim-texture."
	(if (gethash path *texture-hash*)
		(let ((tex (gethash path *texture-hash*)))
			(setf tex (cons (car tex) (1+ (cdr tex))))
			(car tex))
		(progn
			(format t "loading ~S~%" path)
			(load-texture path))))
(defun unclaim-texture (path)
	"Documentation for unclaim-texture."
	(if (gethash path *texture-hash*)
		(let ((tex (gethash path *texture-hash*)))
			(if (<= (cdr tex) 1)
				(progn
					(unload-texture path)
					(setf tex nil))
				(setf tex (cons (car tex) (1- (cdr tex))))))))
(defun texture-id (path)
	"Documentation for texture-id."
	(gethash path *texture-hash*))

(defun surface-to-texture (surf)
	"Documentation for surface-to-texture."
	(sdl:with-pixel (pix (sdl:fp surf))
		(gl:tex-image-2d :texture-2d 0 :rgba
			(sdl:width surf) (sdl:height surf)
			0
			(ecase (sdl-base::pixel-bpp pix)
				(3 :rgb)
				(4 :rgba))
			:unsigned-byte (sdl-base::pixel-data pix))))
(defun update-texture (surf path)
	"Documentation for update-texture."
	(gl:bind-texture :texture-2d (car (gethash path *texture-hash*)))
	(gl:tex-parameter :texture-2d :texture-min-filter :linear)
	(gl:tex-parameter :texture-2d :texture-wrap-s :repeat)
	(gl:tex-parameter :texture-2d :texture-wrap-t :repeat)
	(surface-to-texture surf))
(defun blank-texture ()
	"Documentation for blank-texture."
	(let ((id (car (gl:gen-textures 1)))
		(path (gensym)))
	(setf (gethash path *texture-hash*) (cons id 0))
	path))