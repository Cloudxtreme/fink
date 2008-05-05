(in-package :gtp-handler)

(defparameter *quit?* nil)

(defun gtp-client ()
  (setf *quit?* nil)
   (do ()
      ((eql *quit?* t))
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
  (let* ((commands (cl-ppcre:split "\\s+" (string-upcase command-string)))
	 (command (intern (first commands))))
    (progn (format t "'~a'~%" command)
    (case command
      (name go-bot:*name*)
      (version go-bot:*version*)
      ;(boardsize (progn 
		  ; (go-bot:set-boardsize (parse-integer (second commands)))
		  ; (go-bot:init-board)))
      ;(komi (go-bot:set-komi (parse-integer (second commands))))
      ;(clearboard (go-bot:init)
      ;(play (go-bot:play (second commands) (third commands)))
      ;(genmove (go-bot:genmove (char (second commands) 0)))
      ;(known_command)
      ;(list_commands
      (quit (progn (setf *quit?* t)) "")
      (otherwise (concatenate 'string "Unkown command '" (first commands) "'"))))))
  