#| (defclass textgram (visualgram)
	((seq :initarg :sequence :initform nil)))

(defmethod cg-init ((object textgram))
(vg-load-vec object (coerce (slot-value object 'seq) 'vector)))

(defmethod cg-evaluate ((object textgram)))
(defmethod cg-visualize ((object textgram))
	(call-next-method))

(defun init-ttf ()  
   (if (is-init)  
     t  
     (sdl-ttf-cffi::ttf-init)))  
(pushnew 'init-ttf sdl:*external-init-on-startup*) 

(defun quit-ttf ()  
   (if (is-init)  
     (sdl-ttf-cffi::ttf-quit)))  
(pushnew 'quit-ttf sdl:*external-quit-on-exit*) |#