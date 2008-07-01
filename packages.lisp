(in-package :common-lisp)

;(clc:clc-require :cl-ppcre)
;(asdf:oos 'asdf:load-op :cl-ppcre)
(require :sb-bsd-sockets)

(defpackage macro-utils
  (:use :common-lisp)
  (:export :with-gensyms
	   :once-only
	   :while
	   :until
	   :pdebug))

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
	   :remove-stone
	   :get-player
	   :coord-to-str
	   :str-to-coord
	   :genmove
	   :do-with-copy-of-array
	   :copy-array
	   :copy-2d-array
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
	   :board-to-analyze
;	   :do-over-2d-adjacent
	   :do-over-adjacent))

(defpackage liberty-board
  (:use :common-lisp
	:macro-utils
	:board)
  (:export :liberty-board
	   :liberty-to-analyze
	   :liberty))
   
(defpackage shape-board
  (:use :common-lisp
	:macro-utils
	:board)
  (:export :shape-board
	   :shapes-to-analyze
	   :shape-id
	   :shapes-points
	   :shape-sizes
	   :next-shape-id
	   :convert-shape
	   :shape-size))

(defpackage liberty-shape-board
  (:use :common-lisp
	:macro-utils
	:board
	:liberty-board
	:shape-board)
  (:export :liberty-shape-board
	   :liberty-shape-to-analyze
	   :liberty-shape-stone-to-analyze))


(defpackage go-bot
  (:use :common-lisp
	:board
	:liberty-board
	:shape-board
	:liberty-shape-board)
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
	    :analyze-shapes
	    :analyze-shape-liberties
	    :analyze-shape-stone-liberties
	    ))

(defpackage gtp-handler
  (:use :common-lisp
	:netpipe
	:go-bot)
  (:export :gtp-client
	   :gtp-net-client))

