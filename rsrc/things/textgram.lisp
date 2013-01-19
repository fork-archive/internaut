(defclass textgram (vg-vertex vg-texcoord vg-texture) 
	((surface :initform (sdl:create-surface 250 100 :PIXEL-ALPHA t))
	(num :initform 0)))

(defmethod cg-init ((object textgram))
	(vg-load-data object :vert '#(0.0 0.0 0.0  0.5 0.0 0.0  0.5 0.5 0.0  0.0 0.5 0.0) :coord '#(0.0 0.9  0.9 0.9  0.9 0.0  0.0 0.0) :tex (blank-texture))
	(setf (slot-value object 'draw-mode) :quads))
;    (setf (slot-value object 'count) 4))

(defmethod cg-evaluate ((object textgram)) 
	(setf (slot-value object 'num) (1+ (slot-value object 'num))))

(defmethod cg-visualize ((object textgram))
	(sdl:fill-surface-* 0 0 0 :a 0 :surface (slot-value object 'surface))
	(sdl:blit-surface (sdl:render-string-solid (format nil "~S" (slot-value object 'num))) (slot-value object 'surface))
	(update-texture (slot-value object 'surface) (slot-value object 'texture-path))
	(call-next-method))