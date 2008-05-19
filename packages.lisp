(in-package :common-lisp)

;(clc:clc-require :cl-ppcre)
;(asdf:oos 'asdf:load-op :cl-ppcre)
(require :sb-bsd-sockets)

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
  (:use :common-lisp)
  (:export :basic-board
	   :get-stone
	   :set-stone
	   :coord-to-str
	   :str-to-coord))

(defpackage go-bot
  (:use :common-lisp
	:board)
  (:export :*name*
	    :*version*
	    :*author*
	    :*player*
	    :set-komi
	    :set-boardsize
	    :init-board
	    :init
	    :do-play
	    :do-genmove
	    ))