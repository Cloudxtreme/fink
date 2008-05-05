(in-package :go-bot)

(defparameter *name* "gobot")
(defparameter *version* "0.01")
(defparameter *author* "Dan Ballard")

(defun make-board (size)
  (make-array size :initial-element (make-array size :initial-element nil)))

