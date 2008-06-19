(in-package :liberty-shape-board)

(defclass liberty-shape-board (liberty-board shape-board)
  ((shapes-liberties
    :accessor shapes-liberties)
   (black-shape-liberties
    :initform 0
    :accessor black-shape-liberties)
   (white-shape-liberties
    :initform 0
    :accessor white-shape-liberties)))

(defmethod initialize-instance :after ((board liberty-shape-board) &key from-board)
  (if (eql from-board nil)
      (progn
       
       (setf (shapes-liberties board) (make-array 1 :fill-pointer 0 :adjustable t)))
      (progn
	(setf (shapes-liberties board) (copy-array (shapes-liberties from-board)))
	(copy-slots (white-shape-liberties black-shape-liberties) board from-board))))
    

(defmethod set-stone :after ((board liberty-shape-board) coords val)
  (if (eql (shape-id board coords) (next-shape-id board))
      ; new shape
      (vector-push-extend (liberties-of-shape board (next-shape-id board)) (shapes-liberties board))
      ;old shape
      ())
  ;adjust neighebors