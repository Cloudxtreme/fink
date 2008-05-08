(in-package :common-lisp)

;(clc:clc-require :cl-ppcre)
;(asdf:oos 'asdf:load-op :cl-ppcre)
(require :sb-bsd-sockets)

(defpackage gtp-handler
  (:use :common-lisp)
  (:export :gtp-client
	   :gtp-net-client))

(defpackage go-bot
  (:use :common-lisp)
  (:export :*name*
	    :*version*
	    :*author*
	    :*player*
	    :set-komi
	    :set-boardsize
	    :init-board
	    :init
	    :play
	    :genmove
	    ))