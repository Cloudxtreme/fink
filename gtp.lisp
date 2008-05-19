(in-package :gtp-handler)


(defparameter *quit?* nil)
;(defparameter *cputime*)



(defun gtp-net-client (server port)
  (go-bot:init)
  (setf *quit?* nil)
  (let ((socket (tcp-connect server port)))
    (if (eql socket nil)
	()
	(progn
;	  (format t "Connection establish, playing...~%")
	  (do ()
	      ((or (eql socket nil) (eql *quit?* t)))
	    (let ((cmd (tcp-read socket)))
	      	;(format t "cmd: '~a'~%'" cmd)
	      (let ((resp (dispatch-gtp-command cmd)))
	       ;(print resp)
		(tcp-print socket (concatenate 'string "= " resp (string #\newline) (string #\newline))))))))))


(defun gtp-client ()
  (go-bot:init)
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
  (let* ((commands (split-string (string-upcase command-string) " "))
					;(cl-ppcre:split "\\s+" (string-upcase command-string)))
	 (command (intern (first commands) :gtp-handler)))
    ;(print command)
    (case command
      (name go-bot:*name*)
      (version go-bot:*version*)
      (protocol_version "gtp2ip-0.1")
      (boardsize (go-bot:set-boardsize (parse-integer (second commands)))
		 (go-bot:init-board)
		 "")
      ; warning: read-from-string pulls full reader. not safe
      (komi (go-bot:set-komi (read-from-string (second commands))) 
	    "")
      (clear_board (go-bot:init) "")
      (play (go-bot:do-play (char (second commands) 0) (third commands)) "")
      (genmove (go-bot:do-genmove (char (second commands) 0)))
      (genmove_black (go-bot:do-genmove #\b))
      (genmove_white (go-bot:do-genmove #\w))
      ;(get_random_seed "0")
      ;(known_command)
      ;(list_commands)
      (game_score (format t "Score for ~c: ~s~%" go-bot:*player* (string-trim (string #\newline) (second commands))) "")
      (quit (setf *quit?* t) "")
      (otherwise (concatenate 'string "? unknown command: " (string-downcase (first commands)))))))
  