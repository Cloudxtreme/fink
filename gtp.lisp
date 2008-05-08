(in-package :gtp-handler)

;(require :sb-bsd-sockets)

(defparameter *quit?* nil)


(defun nslookup (hostname)
   "Performs a DNS look up for HOSTNAME and returns the address as a
   four element array, suitable for socket-connect.  If HOSTNAME is
   not found, a host-not-found-error condition is thrown."
   (if hostname
       (sb-bsd-sockets:host-ent-address (sb-bsd-sockets:get-host-by-name hostname))
       nil)) 

(defun tcp-connect (server port &optional (timeout 10))
  (handler-case
      (let ((socket (make-instance 'sb-bsd-sockets:inet-socket :type :stream :protocol :tcp))) 
	(sb-bsd-sockets:socket-connect socket  (nslookup server) port) 
	socket)
    (sb-bsd-sockets:CONNECTION-REFUSED-ERROR () 
      (progn 
	(format t "Error: Connection refused~%") 
	nil))))
		

(defun tcp-print-raw (socket line)
  (when (and socket line)
    (sb-bsd-sockets:socket-send socket line nil)))

(defun tcp-print (socket line)
  (tcp-print-raw socket (concatenate 'string (format nil "~04d" (length line)) line)))

(defun tcp-read-raw (socket &key (maxsize 65536) (timeout 10))
   (when socket
     (values (sb-bsd-sockets:socket-receive socket nil maxsize))))

;(if-timeout (timeout (format t "socket-receive timed out after ~A seconds.~%" timeout) (force-output) nil)

(defun tcp-read (socket &key (timeout 10))
   (when socket
     (let ((len (parse-integer (tcp-read-raw socket :maxsize 4 :timeout timeout))))
       (tcp-read-raw socket :maxsize len :timeout timeout))))
	
       


(defun gtp-net-client (server port)
  (go-bot:init)
  (setf *quit?* nil)
  (let ((socket (tcp-connect server port)))
    (if (eql socket nil)
	()
	(progn
	  (format t "Connection establish, playing...~%")
	  (do ()
	      ((or (eql socket nil) (eql *quit?* t)))
	    (let ((cmd (tcp-read socket)))
	      ;	(print cmd)
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
      (play (go-bot:play (char (second commands) 0) (third commands)) "")
      (genmove (go-bot:genmove (char (second commands) 0)))
      (genmove_black (go-bot:genmove #\b))
      (genmove_white (go-bot:genmove #\w))
      ;(get_random_seed "0")
      ;(known_command)
      ;(list_commands)
      (game_score (format t "Score for ~c: ~s~%" go-bot:*player* (string-trim (string #\newline) (second commands))) "")
      (quit (setf *quit?* t) "")
      (otherwise (concatenate 'string "? unknown command: " (string-downcase (first commands)))))))
  