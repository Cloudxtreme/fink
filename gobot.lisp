(in-package :go-bot)

(defparameter *name* "fink")
(defparameter *version* "0.2.0")
(defparameter *author* "Dan Ballard")

(defparameter *default-komi* 5.5)
(defparameter *komi* *default-komi*)
(defparameter *default-boardsize* 19)
(defparameter *boardsize* *default-boardsize*)

(defparameter *board* nil)

(defparameter *passed* nil)
(defparameter *player* nil)
(defparameter *last-player* nil)


(defun set-komi (new-komi)
  (setf *komi* new-komi))

(defun set-boardsize (newsize)
  (setf *boardsize* newsize))

(defun init-board ()
  (setf *board* (make-instance 'basic-board :boardsize *boardsize*))
  (setf *passed* nil)
  (setf *player* nil))

(defun init ()
  ;(init other game specific stuff)
  (init-board))



(defun play (board coords player)
  (set-stone board coords player))
  

(defun do-play (player coord-str)
  (setf *last-player* player)
  (if (string= coord-str "PASS")
      (setf *passed* t)
      ;(set-stone *board* (str-to-coord coord-str) player)))
      (play *board* (str-to-coord coord-str) player)))

(defun do-genmove (player)
  (setf *player* player)
  (if (or (eql *passed* t) (eql *last-player* player))
      "pass"
      (let* ((move (coord-to-str (genmove *board* player)))
	     (score (first move))
	     (coord (coord-to-str (second move))))
	(if (< score 0)
	    "pass"
	    (progn
	      (do-play player coord)
	      coord)))))

