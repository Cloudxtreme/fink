(in-package :common-lisp)

;(setf *invoke-debugger-hook*
;                 (lambda (condition hook)
;                   (declare (ignore hook))
                   ;; Uncomment to get backtraces on errors
                   ;; (sb-debug:backtrace 20)
;                   (format *error-output* "Error: ~A~%" condition)
;                   (quit)))


(defparameter *src-root* "/home/dan/src/my/gobot/")


(defparameter *src-files* '("packages" "macro-utils" "netpipe" "board" "liberty" "shape" "gobot" "gtp"  "fink"))
(defun recompile ()
  (loop for file in *src-files* do (compile-file (concatenate 'string *src-root* file ".lisp"))))

(recompile)

(load (concatenate 'string *src-root* "fink.fasl"))
