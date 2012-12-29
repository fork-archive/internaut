#| (defclass textgram (visualgram)
	((seq :initarg :sequence :initform nil)))

(defmethod cg-init ((object textgram))
(vg-load-vec object (coerce (slot-value object 'seq) 'vector)))

(defmethod cg-evaluate ((object textgram)))
(defmethod cg-visualize ((object textgram))
	(call-next-method))
|#