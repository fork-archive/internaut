#| (defun generate-triangles (seq)
	(loop for i below (/ (length seq) 3)
		collect (loop for j below (/ (length seq) 3)
			with min = (if (< i (/ (length seq)))
				(1+ i)
				(1- i))
			do((print j))))) |#