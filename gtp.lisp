(in-package :gtp-handler)

(defun gtp-client ()
  (do ((quit? nil))
      ((eql quit? t))
    (format t "= ~a~%~%" (dispatch-gtp-command (read-line t)))))

(defun split-string (string pivot-str)
  (do ((pivot (char pivot-str 0))
       (i 0 (+ i 1))
       (beg 0)
       (strings '()))
      ((> i (length string)) (reverse strings))
    (if (or (eql (length string) i) (eql (aref string i) pivot))
	(progn (push (subseq string beg i) strings) (setf beg (+ i 1))))))



(defun dispatch-gtp-command (command-string)
  (let* ((commands (split-string (string-downcase command-string) " "))
	 (command (intern (first commands))))
    (progn (format t "'~a'~%" command)
    (case command
      (name "GoBot")
      (version "0.1")
      (otherwise (concatenate 'string "Unkown command '" (first commands) "'"))))))
  