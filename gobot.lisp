(in-package :go-bot)

(defparameter *name* "fink")
(defparameter *version* "0.3.0-dev")
(defparameter *author* "Dan Ballard")

(defparameter *default-komi* 5.5)
(defparameter *komi* *default-komi*)
(defparameter *default-boardsize* 19)
(defparameter *boardsize* *default-boardsize*)

(defparameter *board* nil)
(defparameter *cputime* 0.0)

(defparameter *passed* nil)
(defparameter *player* nil)
(defparameter *last-player* nil)

(defclass composite-board (liberty-shape-board)
  ((final
   :initform 0)))

(defun set-komi (new-komi)
  (setf *komi* new-komi))

(defun set-boardsize (newsize)
  (setf *boardsize* newsize))

(defun init-board ()
  (setf *board* (make-instance 'composite-board :boardsize *boardsize*))
  (setf *passed* nil)
  (setf *player* nil)
  (setf *last-player* nil))


(defun init ()
  ;(init other game specific stuff)
  (setf *random-state* (make-random-state t))
  (setf *cputime* 0.0)
  (init-board))



(defun play (board coords player)
  (set-stone board coords player))
  

(defun do-play (player coord-str)
  (setf *last-player* player)
  (if (string= coord-str "PASS")
      (setf *passed* t)
      ;(set-stone *board* (str-to-coord coord-str) player)))
      (progn 
	(setf *passed* nil)
	(play *board* (str-to-coord coord-str) player))))

(defun do-genmove (player)
;  (format t "do-genmove ~a~%" player)
  (setf *player* player)
  (if (or (eql *passed* t) (eql *last-player* player))
      "pass"
      (let* ((move (genmove *board* player))
;	     (board-score (first move))
	     (coord (second move)))
	;(format t "score: ~a for player ~a ~%" board-score player)
	(if (listp coord)  ; string= coord "pass"))
	    (let ((coord-str (coord-to-str coord)))
	      (do-play player coord-str)
	      coord-str)
	    coord))))
	 
	;(if (< board-score 0)
	;    "pass"
	;    (progn
	;      (do-play player coord)
	;      coord)))))


(defun analyze-score ()
  (analyze-board-score *board* *player*))

(defun analyze-liberty ()
  (liberty-to-analyze *board*))

(defun analyze-shapes ()
  (shapes-to-analyze *board*))

(defun analyze-shape-liberties ()
  (liberty-shape-to-analyze *board*))

(defun analyze-shape-stone-liberties ()
  (liberty-shape-stone-to-analyze *board*))
