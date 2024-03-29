(in-package :liberty-board)

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

(defmacro liberty (board coords)
  `(get-2d-stone (liberty-board ,board) ,coords))

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

(defgeneric inc-liberties (board coords delta))

(defmethod inc-liberties ((board liberty-board) coords delta)
  (let ((player (get-stone board coords)))
    (if (eql player #\B)
	(incf (black-liberties board) delta)
	(if (eql player #\W)
	    (incf (white-liberties board) delta)))))

(defmacro mod-liberty (board coords delta)
  `(progn
     (set-2d-stone (liberty-board ,board) ,coords (+ (get-2d-stone (liberty-board ,board) ,coords) ,delta))
    (inc-liberties ,board ,coords ,delta)))

(defmacro dec-liberty (board coords)
  `(mod-liberty ,board ,coords -1))

(defmacro inc-liberty (board coords)
  `(mod-liberty ,board ,coords 1))



(defmethod set-stone :after ((board liberty-board) coords val)
  (inc-liberties board coords (get-2d-stone (liberty-board board) coords))
  (do-over-adjacent (coords-var  board coords) 
    (dec-liberty board coords-var)))

(defmethod remove-stone :after ((board liberty-board) coords)
  (pdebug "liberty-board:remove-stone ~a~%" coords)
  (do-over-adjacent (coords-var board coords)
    (inc-liberty board coords-var)))
     
(defmethod score + ((board liberty-board) player)
  (if (eql player #\B)
      (- (black-liberties board) (white-liberties board))
      (- (white-liberties board) (black-liberties board))))
      
	   
(defun liberty-to-analyze (board)
  (concatenate 'string (board-to-analyze (liberty-board board))
	       '(#\newline)
	       "TEXT Black Liberties: " (write-to-string (black-liberties board)) " and White Liberties: " (write-to-string (white-liberties board))))
    
