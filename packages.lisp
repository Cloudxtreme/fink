(in-package :common-lisp)

;(clc:clc-require :cl-ppcre)
(asdf:oos 'asdf:load-op :cl-ppcre)
(require :sb-bsd-sockets)

(defpackage gtp-handler
  (:use :common-lisp :sb-bsd-sockets)
  (:export :gtp-client))

(defpackage go-bot
  (:use :common-lisp)
  (:export :*name*
	    :*version*
	    :*author*
	    :set-komi
	    :set-boardsize
	    :init-board
	    :init
	    :play
	    :genmove
	    ))