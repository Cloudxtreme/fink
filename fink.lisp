(in-package :common-lisp)

(defparameter *src-root* "/home/dan/src/my/gobot/")

asdas asd asd ad  asd 

(load (concatenate 'string *src-root* "packages.fasl"))
(load (concatenate 'string *src-root* "netpipe.fasl"))
(load (concatenate 'string *src-root* "board.fasl"))
(load (concatenate 'string *src-root* "gobot.fasl"))
(load (concatenate 'string *src-root* "gtp.fasl"))