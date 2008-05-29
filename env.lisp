(in-package :common-lisp)

;(setf *invoke-debugger-hook*
;                 (lambda (condition hook)
;                   (declare (ignore hook))
                   ;; Uncomment to get backtraces on errors
                   ;; (sb-debug:backtrace 20)
;                   (format *error-output* "Error: ~A~%" condition)
;                   (quit)))


(defparameter *src-root* "/home/dan/src/my/gobot/")

(defun recompile ()
  (compile-file (concatenate 'string *src-root* "packages.lisp"))
  (compile-file (concatenate 'string *src-root* "macro-utils.lisp"))
  (compile-file (concatenate 'string *src-root* "netpipe.lisp"))
  (compile-file (concatenate 'string *src-root* "board.lisp"))
  (compile-file (concatenate 'string *src-root* "liberty-shape.lisp"))
  (compile-file (concatenate 'string *src-root* "gobot.lisp"))
  (compile-file (concatenate 'string *src-root* "gtp.lisp"))
  (compile-file (concatenate 'string *src-root* "fink.lisp")))

(recompile)

(load (concatenate 'string *src-root* "fink.fasl"))
