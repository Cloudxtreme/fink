(in-package :liberty-shape-board)

(defclass liberty-shape-board (liberty-board shape-board)
  (
    ; stores lists (shape-liberties shape-libertirs-score)
   (shapes-liberties
    :initform nil
    :accessor shapes-liberties) 
   ; stores lists of free stones adjacent to shape
   (shapes-free-points
    :initform nil
    :accessor shapes-free-points)
   (shapes-free-scores
    :initform nil
    :accessor shapes-free-scores)
   (black-shape-stone-liberties
    :initform 0
    :accessor black-shape-stone-liberties)
   (white-shape-stone-liberties
    :initform 0
    :accessor white-shape-stone-liberties)
   (black-shape-liberties
    :initform 0
    :accessor black-shape-liberties)
   (white-shape-liberties
    :initform 0
    :accessor white-shape-liberties)))

(defmethod initialize-instance :after ((board liberty-shape-board) &key from-board)
  (if (eql from-board nil)
      (progn
        (setf (shapes-liberties board) (make-array 1 :fill-pointer 0 :adjustable t))
	(setf (shapes-free-points board) (make-array 1 :fill-pointer 0 :adjustable t))
	(setf (shapes-free-scores board) (make-array 1 :fill-pointer 0 :adjustable t)))
      
      (progn
	(setf (shapes-liberties board) (copy-array (shapes-liberties from-board)))
	(setf (shapes-free-points board) (copy-2d-array (shapes-free-points from-board)))
	(setf (shapes-free-scores board) (copy-array (shapes-free-scores from-board)))
	(copy-slots (white-shape-liberties black-shape-liberties black-shape-stone-liberties white-shape-stone-liberties) board from-board))))
    
(defmacro inc-player-shape-stone-liberty (board player delta)
  `(if (eql ,player #\B)
       (incf (black-shape-stone-liberties ,board) ,delta)
       (incf (white-shape-stone-liberties ,board) ,delta)))

(defmacro inc-player-shape-liberty (board player delta)
  `(if (eql ,player #\B)
       (incf (black-shape-liberties ,board) ,delta)
       (incf (white-shape-liberties ,board) ,delta)))
       
(defmethod convert-shape :before ((board liberty-shape-board)  shape-id to-id)
  (let ((player (get-stone board (aref (aref (shapes-points board) shape-id) 0))))
    (inc-player-shape-stone-liberty board player (- (second (aref (shapes-liberties board) shape-id))))
    (setf (aref (shapes-liberties board) shape-id) '(0 0))))



(defun calculate-shape-liberties (board coords player)
  (let* ((liberties 0)
	 (sid (shape-id board coords))
	 (shape-liberties-score (aref (shapes-liberties board) sid))
	 (old-score (second shape-liberties-score)))
 ;   (pdebug "calculate-shape-liberties for sid:~a score:~a~%" sid shape-liberties-score)
    (inc-player-shape-stone-liberty board player (- old-score))
;    (pdebug "loop add liberties~%")
    (loop for index from 0 to (1- (length (aref (shapes-points board) sid))) do
;	 (pdebug "adding on ~a~%" index)
	 (incf liberties (liberty board (aref (aref (shapes-points board) sid) index))))
    (let ((score (* liberties (shape-size board sid))))
;      (pdebug "sets shape-liberties for ~a (~a ~a)~%" sid liberties score)
      (setf (aref (shapes-liberties board) sid) `(,liberties ,score))
      (inc-player-shape-stone-liberty board player score))))
	
(defmacro coords-eql (a b)
  `(and (eql (first ,a) (first ,b)) (eql (second ,a) (second ,b))))


(defun add-free-point (board coord sid player)
  ;(pdebug "1st (dec) inc score ~a by ~a " (if (eql player #\B) (black-shape-liberties board) (white-shape-liberties board))  (- (aref (shapes-free-scores board) sid)))
  (inc-player-shape-liberty board player (- (aref (shapes-free-scores board) sid)))
  ;(pdebug " = ~a~%"  (if (eql player #\B) (black-shape-liberties board) (white-shape-liberties board)))
  (let* ((found nil)
	 (free-points (aref (shapes-free-points board) sid)))
    (loop for i from 0 to (1- (length free-points)) do
	 (if (coords-eql coord (aref free-points i))
	     (progn 
	       (setf found t)
	       (return))))
    (if (eql found nil)
	(progn
	  (vector-push-extend coord free-points)))
;	  (inc-player-shape-liberty board player 1)))
    (let ((newscore (* (shape-size board sid) (length free-points))))
    ;  (format t "newscore ~a*~a = ~a~%" (shape-size board sid) (length free-points)  newscore)
;      (pdebug "2nd inc score ~a by ~a " (if (eql player #\B) (black-shape-liberties board) (white-shape-liberties board))  newscore)
      (setf (aref (shapes-free-scores board) sid) newscore)
      ;  (format t "set shape-free-scores~%")
      (inc-player-shape-liberty board player newscore))))
 ;     (pdebug " = ~a~%" (if (eql player #\B) (black-shape-liberties board) (white-shape-liberties board))))))

(defun add-free-points-around (board nexus player)
  (let ((sid (shape-id board nexus)))
    (do-over-adjacent (coords-var board nexus)
      (if (eql (get-stone board coords-var) nil)
	  (add-free-point board coords-var sid player)))))
  
(defun remove-free-point (board coord sid player)
  (let ((free-points (aref (shapes-free-points board) sid)))
    (if (> (length free-points) 0)
	(let ((tmp (aref free-points (1- (length free-points)))))
	 ; (pdebug "dec inc-player-shape-liberty~%")

	  ;(pdebug "search for point~%")
	  (loop for i from 0 to (1- (length free-points)) do
	   ;    (pdebug "search ~a" i)
	       (if (coords-eql coord (aref free-points i))
		   (progn
		;     (pdebug "found on ~a @ ~a" i  (aref free-points i))
		     (setf (aref free-points i) tmp)
		 ;    (pdebug "do vector pop~%")
		     (vector-pop free-points)
		;   (pdebug "inc-player-shape-liberty~%")
		     (inc-player-shape-liberty board player (- (aref (shapes-free-scores board) sid)))
		     (inc-player-shape-liberty board player (* (length free-points) (shape-size board sid)))
		   ;  (pdebug "set shapes-free-scores new score for ~a~%" sid)
		     (setf (aref (shapes-free-scores board) sid)  (* (length free-points) (shape-size board sid)))
		     (return))))))))
	 


(defmethod set-stone :after ((board liberty-shape-board) coords val)
  (while (not (eql (length (shapes-liberties board)) (next-shape-id board)))
    (vector-push-extend '(0 0) (shapes-liberties board)) ; new shape
    (vector-push-extend 0 (shapes-free-scores board)) 
    (vector-push-extend (make-array 1 :fill-pointer 0 :adjustable t) (shapes-free-points board)))
  (calculate-shape-liberties board coords val)
 ; (pdebug "about to add-free-points~%")
  (add-free-points-around board coords val)
  ;adjust neighebors
 ; (pdebug "about to adjust neighbors~%")
  (let ((sid (shape-id board coords)))
    (do-over-adjacent (coords-var board coords)
      (let ((adj-sid (shape-id board coords-var))
	    (adj-player (get-player board coords-var)))
	(if (not (eql adj-sid nil))
	    (progn
	 ;     (pdebug "adjusting: from coord:~a removing free: ~a and sid:~a player ~a~%" coords coords-var adj-sid adj-player)
	      (remove-free-point board coords adj-sid adj-player)
	  ;    (pdebug "remove-free-point done~%")
	      (if (not(eql adj-sid sid))
		  (calculate-shape-liberties board coords-var (get-stone board coords-var)))))))))

(defun liberty-shape-stone-to-analyze (board)
  (let ((lsb (make-2d-board (boardsize board) 0)))
    (do-over-board (coords board)
      (if (not (eql nil (shape-id board coords)))
	  (set-2d-stone lsb coords (second (aref (shapes-liberties board) (shape-id board coords))))))
  (concatenate 'string (board-to-analyze lsb)
	       '(#\newline) " TEXT black shape stone liberties: " (write-to-string (black-shape-stone-liberties board)) 
	       " white shape stone liberties: " (write-to-string (white-shape-stone-liberties board)))))

(defun shape-liberties-score (board sid)
  (* (shape-size board sid) (length (aref (shapes-free-points board) sid))))

(defun liberty-shape-to-analyze (board)
  (let ((lsb (make-2d-board (boardsize board) 0)))
    (do-over-board (coords board)
      (if (not (eql nil (shape-id board coords)))
	  (set-2d-stone lsb coords (shape-liberties-score board (shape-id board coords)))))
    (concatenate 'string (board-to-analyze lsb)
		 '(#\newline) " TEXT black shape liberties: " (write-to-string (black-shape-liberties board)) 
		 " white shape liberties: " (write-to-string (white-shape-liberties board)))))



;(defmethod score + ((board liberty-shape-board) player)
;  (if (eql player #\B)
;      (- (black-shape-liberties board) (white-shape-liberties board))
;      (- (white-shape-liberties board) (black-shape-liberties board))))


(defmethod score + ((board liberty-shape-board) player)
  (if (eql player #\B)
      (- (black-shape-stone-liberties board) (white-shape-stone-liberties board))
      (- (white-shape-stone-liberties board) (black-shape-stone-liberties board))))