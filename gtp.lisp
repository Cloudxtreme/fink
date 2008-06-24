(in-package :gtp-handler)


(defparameter *quit?* nil)
;(defparameter *cputime* 0)

(defmacro inc-cpu-timer (body)
  `(let ((start (get-internal-run-time)) 
	 (val ,body)
	 (end (get-internal-run-time)))
     (setf go-bot:*cputime* (+ go-bot:*cputime* (float (/ (- end start) 1000))))
     val))



(defun gtp-net-client (server port)
  (go-bot:init)
  (setf *quit?* nil)
  (let ((socket (netpipe:tcp-connect server port)))
    (if (eql socket nil)
	()
	(progn
;	  (format t "Connection establish, playing...~%")
	  (do ()
	      ((or (eql socket nil) (eql *quit?* t)))
	    (let ((cmd (netpipe:tcp-read socket)))
	      	;(format t "cmd: '~a'~%" cmd)
	      (let ((resp (inc-cpu-timer (dispatch-gtp-command cmd))))
		;(format t "resp: '~a'~%" resp)
		(netpipe:tcp-print socket (concatenate 'string "= " resp (string #\newline) (string #\newline))))))))))

(defun gtp-client ()
  (go-bot:init)
  (setf *quit?* nil)
   (do ()
      ((eql *quit?* t))
    (format t "= ~a~%~%" (inc-cpu-timer (dispatch-gtp-command (read-line t))))))

(defun split-string (string pivot-str)
  (do ((pivot (char pivot-str 0))
       (i 0 (+ i 1))
       (beg 0)
       (strings '()))
      ((> i (length string)) (reverse strings))
    (if (or (eql (length string) i) (eql (aref string i) pivot))
	(progn (push (subseq string beg i) strings) (setf beg (+ i 1))))))


(defparameter *supported_commands* '("name" "version" "protocol_version" "komi" "boardsize" "clear_board" "play" "genmove" "cputime" "quit" "game_score" "list_commands" "known_command" "gogui-analyze_commands" ))

(defparameter *analyze_commands* '("gfx/Liberties/liberties" "gfx/Shapes/shapes" "gfx/Shape-Liberties/shape-liberties" "gfx/Shape-Stone-Liberties/shape-stone-liberties"))





(defun match-string (str)
  (lambda (elem) (string-equal str elem)))

(defun dispatch-gtp-command (command-string)
  (let* ((commands (split-string (string-trim #(#\newline #\space) (string-upcase command-string)) " "))
					;(cl-ppcre:split "[\\s\\n]+" (string-upcase command-string)))
	 (command (intern (first commands) :gtp-handler)))
    ;(format t "~a~%" commands)
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
      (cputime (write-to-string go-bot:*cputime*))
      ;(get_random_seed "0")
      (known_command (write-to-string (count-if (match-string (second commands)) *supported_commands*)))
      (list_commands (let ((str ""))
		       (loop for command in *supported_commands* do (setf str (concatenate 'string str command " ")))
		       str))
      (gogui-analyze_commands (let ((str ""))
				(loop for command in *analyze_commands* do (setf str (concatenate 'string str command (string #\newline))))
				(string-trim #(#\newline) str)))
      (game_score (format t "Score for ~c: ~s~%" go-bot:*player* (string-trim (string #\newline) (second commands))) "")
      (liberties (string-trim #(#\newline) (analyze-liberty)))
      (shapes (string-trim #(#\newline) (analyze-shapes)))
      (shape-liberties (string-trim #(#\newline) (analyze-shape-liberties)))
      (shape-stone-liberties (string-trim #(#\newline) (analyze-shape-stone-liberties)))
      ;(scores  (string-trim #(#\newline)(analyze-score)))
      (quit (setf *quit?* t) "")
      (otherwise (concatenate 'string "? unknown command: " (string-downcase (first commands)))))))
  