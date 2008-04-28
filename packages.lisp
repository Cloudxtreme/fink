(in-package :cl-user)

(clc:clc-require :cl-ppcre)

(defpackage gtp-handler
  (:use :common-lisp)
  (:export gtp-client))