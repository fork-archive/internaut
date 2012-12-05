(defclass listgram (visualgram)
	((seq :initarg :sequence :initform nil)))

(defmethod cg-init ((object listgram))
(vg-load-vec object (coerce (slot-value object 'seq) 'vector)))

(defmethod cg-evaluate ((object listgram)))
(defmethod cg-visualize ((object listgram))
	(call-next-method))