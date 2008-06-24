(in-package macro-utils)

;(defun test-while (n)
;  (let ((i 0))
;    (while (< i n)
;      (format t "~a~%" i)
;      (incf i))))

;(defun test-until (n)
;  (let ((i 0))
;    (until (= i n)
;      (format t "~a~%" i)
;      (incf i))))

(defmacro pdebug (&body body)
  `(format *error-output* ,@body))

(defmacro while (test-case &body body)
  `(do ()
       ((not ,test-case) t)
     ,@body))
      
(defmacro until (test-case &body body)
  `(do ()
       (,test-case t)
     ,@body))

(defmacro with-gensyms ((&rest names) &body body)
  `(let ,(loop for n in names collect `(,n (gensym)))
    ,@body))



(defmacro once-only ((&rest names) &body body)
  (let ((gensyms (loop for n in names collect (gensym))))
    `(let (,@(loop for g in gensyms collect `(,g (gensym))))
       `(let (,,@(loop for g in gensyms for n in names collect ``(,,g ,,n)))
	  ,(let (,@(loop for n in names for g in gensyms collect `(,n ,g)))
		,@body)))))
	