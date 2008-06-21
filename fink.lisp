(in-package :common-lisp)

(defparameter *src-root* "/home/dan/src/my/gobot/")

(defparameter *src-files* '("packages" "macro-utils" "netpipe" "board" "liberty" "shape" "liberty-shape" "gobot" "gtp"))

(defun load-files ()
  (loop for file in *src-files* do (load (concatenate 'string *src-root* file ".fasl"))))


(load-files)

