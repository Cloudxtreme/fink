(in-package :liberty-shape)

(defclass liberty-board (basic-board)
  ((liberty-board
    :initform nil
    :accessor liberty-board)))

(defun set-symetric-edge (board index stone max)
  (let ((coords `( (0 ,index) (,index 0) (,max ,index) (,index ,max))))
    (loop for coord in coords do (set-2d-stone  (liberty-board board) coord stone))))

(defun set-symetric-corner (board stone max)
  (let ((coords `( (0 0) (,max 0) (,max 0) (,max ,max))))
    (loop for coord in coords do (set-2d-stone  (liberty-board board) coord stone))))

     
(defmethod initialize-instance :after ((board liberty-board) &key from-board)
;  (format t "init liberty-board~%")
  (if (eql from-board nil)
      (progn
	(setf (liberty-board board) (make-2d-board (boardsize board) 4))
	; set up walled edges to have less liberty
	(loop for i from 1 to (1- (boardsize board))  do
	     (set-symetric-edge board i 3 (1- (boardsize board))))
	(set-symetric-corner board 2 (1- (boardsize board))))
      (progn
	(setf (liberty-board board) (copy-2d-board (liberty-board from-board))))))

(defmacro dec-2d-stone (board coords)
  `(set-2d-stone ,board ,coords (1- (get-2d-stone ,board ,coords))))

(defmethod set-stone :after ((board liberty-board) coords val)
  (let* ((x (first coords))
	 (y (second coords))
	 (up (1- x))
	 (down (1+ x))
	 (left (1- y))
	 (right (1+ y)))
    (if (>= up 0) (dec-2d-stone (liberty-board board) `(,up ,y)))
    (if (>= left 0) (dec-2d-stone (liberty-board board) `(,x ,left)))
    (if (< down (boardsize board)) (dec-2d-stone (liberty-board board) `(,down ,y)))
    (if (< right (boardsize board)) (dec-2d-stone (liberty-board board) `(,x ,right)))))
     
(defmethod score + ((board liberty-board) player)
  (let ((liberty 0))
    (do-over-board (coord board)
      (let ((stone (get-stone board coord)))
      (if (eql stone player)
	  (incf liberty (get-2d-stone (liberty-board board) coord))
	  (if (eql stone (invert-player player))
	      (decf liberty (get-2d-stone (liberty-board board) coord))))))
    liberty))

(defun liberty-to-analyze (board)
  (board-to-analyze (liberty-board board)))
    
