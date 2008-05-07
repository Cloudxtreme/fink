(in-package :go-bot)

(defparameter *name* "gobot")
(defparameter *version* "0.01")
(defparameter *author* "Dan Ballard")
(defparameter *default-komi* 5.5)
(defparameter *komi* *default-komi*)
(defparameter *default-boardsize* 19)
(defparameter *boardsize* *default-boardsize*)

(defparameter *board* nil)

(defparameter *score-functions* '( (score-unused 1)))

(defparameter *passed* nil)
(defparameter *player* nil)
(defparameter *last-player* nil)

(defun make-board (size &optional (initial nil))
  (let ((array (make-array size)))
    (dotimes (i size)
      (setf (aref array i) (make-array size :initial-element initial)))
    array))

(defun set-komi (new-komi)
  (setf *komi* new-komi))

(defun set-boardsize (newsize)
  (setf *boardsize* newsize))

(defun init-board ()
  (setf *board* (make-board *boardsize*))
  (setf *passed* nil)
  (setf *player* nil))

(defun init ()
  ;(init other game specific stuff)
  (init-board))

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
  

(defun play (player coord-str)
  (setf *last-player* player)
  (if (string= coord-str "PASS")
      (setf *passed* t)
      (set-stone *board* (str-to-coord coord-str) player)))

(defun genmove (player)
  (setf *player* player)
  (if (or (eql *passed* t) (eql *last-player* player))
      "pass"
      (let ((move (coord-to-str (make-move *board* player))))
	(play player move)
	move)))

(defun make-move (board player)
  (select-move (score board player)))

(defun score (board player)
  (let ((score-board (make-board (length board) 0)))
    (dolist (slist *score-functions*)
      (merge-score-board score-board (funcall (first slist) board player) (second slist)))
    score-board))
    
(defun merge-score-board (score-board scores weight)
  (dotimes (x (length score-board))
    (dotimes (y (length score-board))
      (set-stone score-board `(,x ,y) (+ (get-stone score-board `(,x ,y)) (* weight (get-stone scores `(,x ,y))))))))
      

(defun select-move (board)
  (let ((highest (get-stone board '(0 0)))
	(coords (make-array 10 :fill-pointer 0 :adjustable t)))
    (do ((x 0 (1+ x)))
	((>= x (length board)) (aref coords (random (length coords))))
      (do ((y 0 (1+ y)))
	  ((>= y (length board)))
	(let ((score (get-stone board `(,x ,y))))
	  (if (> score highest)
	      (progn
		(setf highest score)
		(setf coords (make-array 10 :fill-pointer 0 :adjustable t ))
		(vector-push-extend `(,x ,y) coords))
	      (if (= score highest)
		  (if (= (random 2) 1)
		      (vector-push-extend `(,x ,y) coords)))))))))
      

(defun score-unused (board player)
  (let ((scores (make-board (length board) 0)))
    (dotimes (x (length board))
      (dotimes (y (length board))
	;body
	(if (eql (get-stone board `(,x ,y)) nil)
	    (set-stone scores `(,x ,y) 1))
	;end
	))
    scores))