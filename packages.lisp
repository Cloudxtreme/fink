(in-package :common-lisp)

;(clc:clc-require :cl-ppcre)
;(asdf:oos 'asdf:load-op :cl-ppcre)
(require :sb-bsd-sockets)

(defpackage macro-utils
  (:use :common-lisp)
  (:export :with-gensyms
	   :once-only))

(defpackage netpipe
  (:use :common-lisp)
  (:export :tcp-connect
	   :nslookup
	   :tcp-print
	   :tcp-read))


(defpackage gtp-handler
  (:use :common-lisp
	:netpipe)
  (:export :gtp-client
	   :gtp-net-client))

(defpackage board
  (:use :common-lisp
	:macro-utils)
  (:export :basic-board
	   :ranked-board
	   :get-stone
	   :set-stone
	   :coord-to-str
	   :str-to-coord
	   :genmove))

(defpackage liberty-shape
  (:use :common-lisp
	:macro-utils
	:board)
  (:export :liberty-board))
   

(defpackage go-bot
  (:use :common-lisp
	:board)
  (:export :*name*
	    :*version*
	    :*author*
	    :*player*
	    :*cputime*
	    :set-komi
	    :set-boardsize
	    :init-board
	    :init
	    :do-play
	    :do-genmove
	    ))