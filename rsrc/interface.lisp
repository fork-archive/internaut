;vg-hud

(defclass guigram (visualgram) ())
(defmethod cg-visualize :around ((object guigram))

	(call-next-method)
	(%gl:uniform-1i *gui* 0)
	(gl:depth-mask t)
	(gl:enable :depth-test))