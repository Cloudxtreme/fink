(in-package :netpipe)

(defun nslookup (hostname)
   "Performs a DNS look up for HOSTNAME and returns the address as a
   four element array, suitable for socket-connect.  If HOSTNAME is
   not found, a host-not-found-error condition is thrown."
   (if hostname
       (sb-bsd-sockets:host-ent-address (sb-bsd-sockets:get-host-by-name hostname))
       nil)) 

(defun tcp-connect (server port)
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

(defun tcp-read-raw (socket &key (maxsize 65536))
   (when socket
     (values (sb-bsd-sockets:socket-receive socket nil maxsize))))

;(if-timeout (timeout (format t "socket-receive timed out after ~A seconds.~%" timeout) (force-output) nil)

(defun tcp-read (socket)
   (when socket
     (let ((len (parse-integer (tcp-read-raw socket :maxsize 4))))
       (tcp-read-raw socket :maxsize len ))))
	
       

