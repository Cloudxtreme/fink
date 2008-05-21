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



(defun get-2d-stone (board coord)
  (aref (aref board (first coord)) (second coord)))

(defun set-2d-stone (board coord val)
  (setf (aref (aref board (first coord)) (second coord)) val))



(defclass  basic-board ()
  ((boardsize
    :initarg :boardsize
    :initform 19
    :accessor boardsize)
   (board-def-type
    :initarg :board-def-type
    :initform nil
    :accessor board-def-type)
   (board
    :accessor board
    :initform nil)))


(defgeneric set-stone (board coords val))
(defgeneric get-stone (board coords))

(defmethod set-stone ((board basic-board) coords val)
  (set-2d-stone (board board) coords val))

(defmethod get-stone ((board basic-board) coords)
  (get-2d-stone (board board) coords))


;(defgeneric (setf stone) (val coords

(defmethod initialize-instance :after ((board basic-board) &key from-board)
  (if (eql from-board nil)
      (setf (board board) (make-2d-board (boardsize board) (board-def-type board)))
      (progn
	(setf (boardsize board) (boardsize from-board))
	(setf (board-def-type board) (board-def-type from-board))
	(setf (board board) (copy-2d-board (board from-board))))))



(defmacro do-over-board ((coord board) &body body)
  `(dotimes (x (boardsize ,board))
     (dotimes (y (boardsize ,board))
       (let ((,coord `(,x ,y)))
	 (progn ,@body)))))


(defmacro def-over-board (name (coord board &rest vars)  &rest body)
  `(defun ,name (,board ,@vars)
     (do-over-board (,coord ,board)
       (progn ,@body))))




(defgeneric prune (board prune-board)
 (:documentation "board is the board we are working from, prune-board is an initially all t's board and each no go place is set to nil"))


(defmethod prune ((board basic-board) prune-board)
  (prune-placed-stones board prune-board))


(def-over-board prune-placed-stones (coord board prune-board)
  (if (not (eql (get-stone board coord) nil))
	(set-stone prune-board coord nil)))

;(defun prune-placed-stones (board prune-board)
;  (do-over-board (coord board)
;    (if (not (eql (get-stone board coord) nil))
;	(set-stone prune-board coord nil))))

;(defgeneric prune :after ((board liberty-board) prune-board)
;  (prunce-suicide board prunce-board)) 


(defgeneric focus (board prune-board focus-board player)
  (:documentation "prunce-board: t or nil, focus board: ranked board with scores"))


(defmethod focus ((board basic-board) prune-board focus-board player)
  (do-over-board (coord prune-board)
    (if (not (eql (get-stone prune-board coord) nil))
	(set-stone focus-board coord 1))))





; generate a same sized board with a def type
(defmacro gen-board (board def-type)
  `(make-instance 'basic-board :boardsize (boardsize ,board) :board-def-type ,def-type))

(defmethod genmove ((board basic-board) player)
  (let ((prune-board (gen-board board t))
	(focus-board (gen-board board nil))
	(score-board (gen-board board nil)))
    
    (prune board prune-board)))
    (focus board prune-board focus-board player)
;    (score board focus-board score-board player)
;    (select-move score-board)))
  





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
      

