(in-package :board)




(defun make-2d-board (size &optional (initial nil))
  (let ((array (make-array size)))
    (dotimes (i size)
      (setf (aref array i) (make-array size :initial-element initial)))
    array))

(defun copy-2d-board (board)
  (let ((copy (make-array (length board))))
    (dotimes (i (length board))
      (setf (aref copy i) (copy-seq (aref board i))))
    copy))


	      

(defun filter-i-number (number)
  (if (> number 8) 
      (1- number)
      number))

(defun str-to-coord (str)
  `( ,(filter-i-number (- (char-code (char (string-upcase str) 0)) 65)) ,(- (parse-integer (subseq str 1)) 1)))

(defun filter-i-char (number)
  (if (>= number 8)
      (1+ number)
      number))

(defun coord-to-str (coord)
  (concatenate 'string (string (code-char (+ 65 (filter-i-char (first coord)))))
		(write-to-string (+ (second coord) 1))))



(defun get-stone (board coord)
  (aref (aref board (first coord)) (second coord)))

(defun set-stone (board coord val)
  (setf (aref (aref board (first coord)) (second coord)) val))

  

(defclass  board ()
  ((boardsize
    :initarg boardsize
   ; :initform *boardsize*
    :accessor boardsize)
   (board-def-type
    :initarg board-def-type
    :initform nil
    :accessor board-def-type)
   (board
    :accessor board)))

(defmethod initialize-instance :after ((board board) &key (from-board nil))
  (if (eql from-board nil)
      (setf (board-def-type board) (make-board (boardsize board) (board-def-type board)))
      (progn
	(setf (boardsize board) (boardsize from-board))
	(setf (board-def-type board) (board-def-type from-board))
	(setf (board board) (copy-2d-board (board from-board))))))