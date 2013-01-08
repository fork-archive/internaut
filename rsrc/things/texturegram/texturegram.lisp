(defclass texturegram (vg-vertex vg-texcoord vg-texture) ())

(defmethod cg-init ((object texturegram))
	(vg-load-data object :vert '#(0.0 0.0 0.0  5.0 0.0 0.0  5.0 5.0 0.0  0.0 5.0 0.0) :coord '#(0.0 0.0  10.0 0.0  10.0 10.0  0.0 10.0) :tex "rsrc/things/texturegram/stripe.png")
	(setf (slot-value object 'draw-mode) :quads))
;    (setf (slot-value object 'count) 4))

(defmethod cg-evaluate ((object texturegram)))

(defmethod cg-visualize ((object texturegram))
	(call-next-method))