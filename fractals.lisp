(defun plasma-fractal (x y width height Alpha Beta Gamma Delta central randomF gridspacing vertex)
  (if (or (> width gridspacing) (> height gridspacing ))
      (let
	  ((center (floor (+ (/ (+ Alpha Beta Gamma Delta) 4) (* 0.5 (- randomF (* 2 (random randomF)))))))
	   (A (* 0.5 (+ Alpha Beta)))
	   (B (* 0.5 (+ Beta Gamma)))
	   (C (* 0.5 (+ Gamma Delta)))
	   (D (* 0.5 (+ Delta Alpha))))
             
;	(if (= central 1)
;	    (if (<= center 0)
;	     (setq center (+ central (random randomF)))
;	    (setq center 11))
;	(if (> center 50)
;	    (setq center 50))
	(plasma-fractal x y (* .5 width) (* .5 height) Alpha A center D central randomF gridspacing vertex)
	(plasma-fractal x (+ y (* .5 height)) (* .5 width) (* .5 height) D center C Delta central randomF gridspacing vertex)
	(plasma-fractal (+ x (* .5 width)) (+ y (* .5 height)) (* .5 width) (* .5 height) center B Gamma C central randomF gridspacing vertex) 	
	(plasma-fractal (+ x (* .5 width)) y (* .5 width) (* .5 height) A Beta B center central randomF gridspacing vertex))
      
      (let 
	  ((z (floor (/ (+ Alpha Beta Gamma Delta) 4)))
	   (u))
  
	(if (< Alpha Beta)
	    (setq u Alpha)
	    (setq u Beta))

	(if (< Gamma u)
	    (setq u  Gamma))
	(if (< Delta u)
	    (setq u Delta))

	(loop for i from (floor u) below z
	   do (vector-push-extend x vertex)
	      (vector-push-extend z vertex)
	      (vector-push-extend y vertex)))))
