(in-package :common-lisp)

(defparameter *src-root* "/home/dan/src/my/gobot/")

(load (compile-file (concatenate 'string *src-root* "packages.lisp")))
(load (compile-file (concatenate 'string *src-root* "gtp.lisp")))
(load (compile-file (concatenate 'string *src-root* "gobot.lisp")))