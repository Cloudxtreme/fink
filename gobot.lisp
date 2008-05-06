(in-package :go-bot)

(defparameter *name* "gobot")
(defparameter *version* "0.01")
(defparameter *author* "Dan Ballard")
(defparameter *default-komi* 5.5)
(defparameter *komi* *default-komi*)
(defparameter *default-boardsize* 19)
(defparameter *boardsize* *default-boardsize*)

(defparameter *board* nil)

(defun make-board (size)
  (let ((array (make-array size)))
    (dotimes (i size)
      (setf (aref array i) (make-array size :initial-element nil)))
    array))

(defun set-komi (new-komi)
  (setf *komi* new-komi))

(defun set-boardsize (newsize)
  (setf *boardsize* newsize))

(defun init-board ()
  (setf *board* (make-board *boardsize*)))

(defun init ()
  ;(init other game specific stuff)
  (init-board))

(defun str-to-coord (str)
  `( ,(- (char-code (char (string-upcase str) 0)) 65) ,(- (parse-integer (subseq str 1)) 1)))

(defun get-board (board coord)
  (aref (aref board (first coord)) (second coord)))

(defun set-board (board coord val)
  (setf (aref (aref board (first coord)) (second coord)) val))
  

(defun play (player coord-str)