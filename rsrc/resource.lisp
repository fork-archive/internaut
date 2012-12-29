(defparameter *texture-hash* (make-hash-table))

;Knowledge courtesy of "http://3bb.cc/tutorials/cl-opengl/textures-part-2.html"
(defun load-texture (path)
	"Documentation for load-texture."
	(let ((texture (car (gl:gen-textures 1)))
		(image (sdl:load-image path)))
	(gl:bind-texture :texture-2d texture)
    (gl:tex-parameter :texture-2d :texture-min-filter :linear)
	(sdl:with-pixel (pix (sdl:fp image))
		(gl:tex-image-2d :texture-2d 0 :rgb
			(sdl:width image) (sdl:height image)
			0
			:rgb
			:unsigned-byte (sdl-base::pixel-data pix)))
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
		(load-texture path)))
(defun unclaim-texture (path)
	"Documentation for unclaim-texture."
	(if (gethash path *texture-hash*)
		(let ((tex (gethash path *texture-hash*)))
			(if (<= (cdr tex) 1)
				(progn
					(unload-texture path)
					(setf tex nil))
				(setf tex (cons (car tex) (1- (cdr tex))))))))