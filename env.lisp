(in-package :common-lisp)

;(setf *invoke-debugger-hook*
;                 (lambda (condition hook)
;                   (declare (ignore hook))
                   ;; Uncomment to get backtraces on errors
                   ;; (sb-debug:backtrace 20)
;                   (format *error-output* "Error: ~A~%" condition)
;                   (quit)))


(defparameter *src-root* "/home/dan/src/my/gobot/")

(load (compile-file (concatenate 'string *src-root* "packages.lisp")))
(load (compile-file (concatenate 'string *src-root* "gobot.lisp")))
(load (compile-file (concatenate 'string *src-root* "gtp.lisp")))

;(load (concatenate 'string *src-root* "packages.lisp"))
;(load (concatenate 'string *src-root* "gobot.lisp"))
;(load (concatenate 'string *src-root* "gtp.lisp"))
