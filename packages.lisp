(in-package :cl-user)

(clc:clc-require :cl-ppcre)

(defpackage gtp-handler
  (:use :common-lisp)
  (:export gtp-client))

(defpackage go-bot
  (:use :common-lisp))