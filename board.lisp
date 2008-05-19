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

  

(defclass  basic-board ()
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

(defmethod initialize-instance :after ((board basic-board) &key (from-board nil))
  (if (eql from-board nil)
      (setf (board-def-type board) (make-2d-board (boardsize board) (board-def-type board)))
      (progn
	(setf (boardsize board) (boardsize from-board))
	(setf (board-def-type board) (board-def-type from-board))
	(setf (board board) (copy-2d-board (board from-board))))))


(defgeneric prune (board)
  ()

(defmethod genmove ((board basic-board) player)
  (prune board player)
  ;(focus board player)
  (minmax board player)
  (select-move board player))
  


;(defun make-move (board player)
;  (select-move (score board player)))

;(defun score (board player)
;  (let ((score-board (make-board (length board) 0)))
;    (dolist (slist *score-functions*)
;      (merge-score-board score-board (funcall (first slist) board player) (second slist)))
;    score-board))
    
;(defun merge-score-board (score-board scores weight)
;  (dotimes (x (length score-board))
;    (dotimes (y (length score-board))
;      (set-stone score-board `(,x ,y) (+ (get-stone score-board `(,x ,y)) (* weight (get-stone scores `(,x ,y))))))))
      

;(defun select-move (board)
;  (let ((highest (get-stone board '(0 0)))
;	(coords (make-array 10 :fill-pointer 0 :adjustable t)))
;    (do ((x 0 (1+ x)))
;	((>= x (length board)) (aref coords (random (length coords))))
;      (do ((y 0 (1+ y)))
;	  ((>= y (length board)))
;	(let ((score (get-stone board `(,x ,y))))
;	  (if (> score highest)
;	      (progn
;		(setf highest score)
;		(setf coords (make-array 10 :fill-pointer 0 :adjustable t ))
;		(vector-push-extend `(,x ,y) coords))
;	      (if (= score highest)
;		  (if (= (random 2) 1)
;		      (vector-push-extend `(,x ,y) coords)))))))))
      

;(defun score-unused (board player)
;  (let ((scores (make-board (length board) 0)))
;    (dotimes (x (length board))
;      (dotimes (y (length board))
;	;body
;	(if (eql (get-stone board `(,x ,y)) nil)
;	    (set-stone scores `(,x ,y) 1))
;	;end
;	))
;    scores))