(in-package :go-bot)

(defun make-board (size)
  (make-array size :initial-element (make-array size :initial-element nil)))

