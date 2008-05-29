(in-package :liberty-shape)

(defclass liberty-board (basic-board)
  ((liberty-board
    :initform nil
    :accessor liberty-board)
   (black-liberties
    :initform 0
    :initarg black-liberties
    :accessor black-liberties)
   (white-liberties
    :initform 0
    :initarg white-liberties
    :accessor white-liberties)))

(defun set-symetric-edge (board index stone max)
  (let ((coords `( (0 ,index) (,index 0) (,max ,index) (,index ,max))))
    (loop for coord in coords do (set-2d-stone  (liberty-board board) coord stone))))

(defun set-symetric-corner (board stone max)
  (let ((coords `( (0 0) (,max 0) (0 ,max) (,max ,max))))
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
	(setf (liberty-board board) (copy-2d-board (liberty-board from-board)))
	(copy-slots  (black-liberties white-liberties) board from-board))))

;(defmacro dec-2d-stone (board coords)
;  `(set-2d-stone ,board ,coords (1- (get-2d-stone ,board ,coords))))

  

;(defmethod dec-liberty (board coords)
;  (dec-2d-stone (liberty-board board) coords)
;  (let ((player (get-stone board coords)))
;    (if (not (eql (get-stone board coords) nil))
;	(set-liberties (board) (1- (liberties board player) player)

;(defmethod liberties ((board liberty-board) player)
;  (if (eql player #\b)
;      'black-liberties
;      'white-liberties))
  
;(defun (setf liberties) (liberty board player)
;  (if (eql player #\b)
;      (setf (black-liberties board) liberty)
;      (setf (white-liberties board) liberty)))

;(defmethod set-liberties ((board liberty-board) liberty player)
;  (if (eql player #\b)
;      (setf (black-liberties board) liberty)
;      (setf (white-liberties board) liberty)))


(defgeneric inc-liberties (board coords delta))

(defmethod inc-liberties ((board liberty-board) coords delta)
  (let ((player (get-stone board coords)))
;    (format t "inc-liberties at ~a by ~a for ~a ~%" coords delta player)
    (if (eql player #\B)
	;(progn (format t "inc black~%")
	(incf (black-liberties board) delta)
	(if (eql player #\W)
	 ;   (progn (format t "inc white ~%")
	    (incf (white-liberties board) delta)))))

(defmacro dec-liberty (board coords)
  `(progn
     (set-2d-stone (liberty-board ,board) ,coords (1- (get-2d-stone (liberty-board ,board) ,coords)))
    (inc-liberties ,board ,coords -1)))

  
(defmethod set-stone :after ((board liberty-board) coords val)
  (inc-liberties board coords (get-2d-stone (liberty-board board) coords))
  (let* ((x (first coords))
	 (y (second coords))
	 (up (1- x))
	 (down (1+ x))
	 (left (1- y))
	 (right (1+ y)))
    (if (>= up 0) (dec-liberty board `(,up ,y)))
    (if (>= left 0) (dec-liberty board `(,x ,left)))
    (if (< down (boardsize board)) (dec-liberty board `(,down ,y)))
    (if (< right (boardsize board)) (dec-liberty board `(,x ,right)))))
     
(defmethod score + ((board liberty-board) player)
;	   (format t "player ~a~%" player)
  (if (eql player #\B)
      (- (black-liberties board) (white-liberties board))
      (- (white-liberties board) (black-liberties board))))
      
	   
;  (let ((liberty 0))
;    (do-over-board (coord board)
;      (let ((stone (get-stone board coord)))
;      (if (eql stone player)
;	  (incf liberty (get-2d-stone (liberty-board board) coord))
;	  (if (eql stone (invert-player player))
;	      (decf liberty (get-2d-stone (liberty-board board) coord))))))
;    liberty))

(defun liberty-to-analyze (board)
  (concatenate 'string (board-to-analyze (liberty-board board))
	       '(#\newline)
	       "TEXT Black Liberties: " (write-to-string (black-liberties board)) " and White Liberties: " (write-to-string (white-liberties board))))
    
