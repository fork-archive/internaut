(defclass texturegram (vg-vertex vg-texture) ())

(defmethod cg-init ((object texturegram))
	(vg-load-vert object '#(0.0 0.0 0.0  5.0 0.0 0.0  5.0 5.0 0.0  0.0 5.0 0.0))
	(vg-load-coor object '#(0.0 0.0  1.0 0.0  1.0 1.0  0.0 1.0))	
	(vg-load-tex object "rsrc/things/texturegram/stripe.png")
	(setf (slot-value object 'draw-mode) :quads))
;    (setf (slot-value object 'count) 4))

(defmethod cg-evaluate ((object texturegram)))

(defmethod cg-visualize ((object texturegram))
	(call-next-method))