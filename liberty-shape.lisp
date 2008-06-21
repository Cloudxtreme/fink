(in-package :liberty-shape-board)

(defclass liberty-shape-board (liberty-board shape-board)
  ((shapes-liberties
    :initform nil
    :accessor shapes-liberties) 
    ; stores lists (shape-liberties shape-libertirs-score
   
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
    
(defmacro inc-player-shape-liberty (board player delta)
  `(if (eql ,player #\B)
       (incf (black-shape-liberties ,board) ,delta)
       (incf (white-shape-liberties ,board) ,delta)))
       
(defmethod convert-shape :before ((board liberty-shape-board)  shape-id to-id)
  (let ((player (get-stone board (aref (aref (shapes-points board) shape-id) 0))))
    (inc-player-shape-liberty board player (- (second (aref (shapes-liberties board) shape-id))))
    (setf (aref (shapes-liberties board) shape-id) '(0 0))))



(defun calculate-shape-liberties (board coords player)
  (let* ((liberties 0)
	 (sid (shape-id board coords))
	 (shape-liberties-score (aref (shapes-liberties board) sid))
	 (old-score (second shape-liberties-score)))
;    (format t "sid @ ~a = ~a~%" sid coords)
    (inc-player-shape-liberty board player (- old-score))
    (loop for index from 0 to (1- (length (aref (shapes-points board) sid))) do
	 (incf liberties (liberty board (aref (aref (shapes-points board) sid) index))))
     (let ((score (* liberties (size-of-shape board sid))))
      (setf (aref (shapes-liberties board) sid) `(,liberties ,score))
      (inc-player-shape-liberty board player score))))
	


(defmethod set-stone :after ((board liberty-shape-board) coords val)
  (while (not (eql (length (shapes-liberties board)) (next-shape-id board)))
	 (vector-push-extend '(0 0) (shapes-liberties board))) ; new shape
  (calculate-shape-liberties board coords val)
  ;adjust neighebors
  (let ((sid (shape-id board coords)))
    (do-over-adjacent (coords-var board coords)
      (let ((adj-sid (shape-id board coords-var)))
	(if (not (or (eql adj-sid sid) (eql adj-sid nil)))
	    (calculate-shape-liberties board coords-var (get-stone board coords-var)))))))

(defun liberty-shape-to-analyze (board)
  (let ((lsb (make-2d-board (boardsize board) 0)))
    (do-over-board (coords board)
      (if (not (eql nil (shape-id board coords)))
	  (set-2d-stone lsb coords (second (aref (shapes-liberties board) (shape-id board coords))))))
  (concatenate 'string (board-to-analyze lsb)
	       '(#\newline) " TEXT blakc shape liberties: " (write-to-string (black-shape-liberties board)) 
	       " white shape liberties: " (write-to-string (white-shape-liberties board)))))

(defmethod score + ((board liberty-shape-board) player)
  (if (eql player #\B)
      (- (black-shape-liberties board) (white-shape-liberties board))
      (- (white-shape-liberties board) (black-shape-liberties board))))