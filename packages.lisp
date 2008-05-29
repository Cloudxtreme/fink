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




(defpackage board
  (:use :common-lisp
	:macro-utils)
  (:export :basic-board
	   :boardsize
	   :ranked-board
	   :get-stone
	   :set-stone
	   :coord-to-str
	   :str-to-coord
	   :genmove
	   :copy-2d-board
	   :make-2d-board
	   :do-over-board
	   :def-over-board
	   :set-2d-stone
	   :get-2d-stone
	   :invert-player
	   :prune
	   :focus
	   :score
	   :copy-slots
	   :analyze-board-score
	   :board-to-analyze))

(defpackage liberty-shape
  (:use :common-lisp
	:macro-utils
	:board)
  (:export :liberty-board
	   :liberty-to-analyze))
   

(defpackage go-bot
  (:use :common-lisp
	:board
	:liberty-shape)
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
	    :composite-board
	    :analyze-score
	    :analyze-liberty
	    ))

(defpackage gtp-handler
  (:use :common-lisp
	:netpipe
	:go-bot)
  (:export :gtp-client
	   :gtp-net-client))

