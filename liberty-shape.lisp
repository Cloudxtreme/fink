(in-package :liberty-shape-board)


(defgeneric inc-score (board player delta))

(defmacro def-counter-board (name (core-var def-core-type) (black-var white-var))
  (with-gensyms ()
    `(progn
       (defclass ,name (liberty-board shape-board)
	 ((,core-var :initform nil :accessor ,core-var)
	 (,black-var :initform 0 :accessor ,black-var)
	 (,white-var :initform 0 :accessor ,white-var)))

       (defmethod initialize-instance :after ((board ,name) &key from-board)
	 (if (eql from-board nil)
	     (progn
	       (setf (,core-var board) (make-array 1 :fill-pointer 0 :adjustable t)))
	     (progn
	       (setf (,core-var board) (copy-2d-array (,core-var from-board)))
	       (copy-slots (,black-var ,white-var) board from-board))))

       (defmethod inc-score ((board ,name)  player delta)
	 (if (eql player #\B)
	      (incf (,black-var board) delta)
	      (incf (,white-var board) delta)))


)))


(def-counter-board liberty-shape-board 
    (shapes-free-points-list '(make-array 1 :fill-pointer 0 :adjustable t))
  (black-shape-liberties white-shape-liberties))


(defmacro shape-liberty (board sid)
  `(length (aref (shapes-free-points-list ,board) ,sid)))
;  `(* (shape-size ,board ,sid) (length (aref (shapes-free-points-list ,board) ,sid))))


(defun add-free-point (board coord sid player)
  (pdebug "add-free-point at ~a to ~a for ~a~%" coord sid player)
  (inc-score board player (- (shape-liberty board sid)))
   (let* ((found nil)
	 (free-points (aref (shapes-free-points-list board) sid)))
    (loop for i from 0 to (1- (length free-points)) do
	 (if (coords-eql coord (aref free-points i))
	     (progn 
	       (setf found t)
	       (return))))
    (if (eql found nil)
	(progn
	  (vector-push-extend coord free-points)))
    (let ((newscore (* (shape-size board sid) (length free-points))))
      (inc-score board player newscore))))

(defun add-free-points-around (board nexus player)
  (pdebug "add-free-points-around ~a ~a~%" nexus player)
  (let ((sid (shape-id board nexus)))
    (do-over-adjacent (coords-var board nexus)
      (pdebug "looking at ~a~%" coords-var)
      (if (eql (get-stone board coords-var) nil)
	  (add-free-point board coords-var sid player)))))


(defun remove-free-point (board coord sid player)
;  (pdebug "remove-free-point ~a ~a ~a" coord sid player)
  (let ((free-points (aref (shapes-free-points-list board) sid)))
    (if (> (length free-points) 0)
	(let ((tmp (aref free-points (1- (length free-points)))))
	  (loop for i from 0 to (1- (length free-points)) do
	       (if (coords-eql coord (aref free-points i))
		   (progn
		     (inc-score board player (- (shape-liberty board sid)))
		     (setf (aref free-points i) tmp)
		     (vector-pop free-points)
		     (inc-score board player (* (length free-points) (shape-size board sid)))
		     (return))))
	  (if (= 0 (length free-points))
	      (progn (pdebug "remve-shape ~a~%" sid)
	      (remove-shape board sid)))))))


(defmethod set-stone :after ((board liberty-shape-board) coords val)
  (pdebug "liberty-shape-board:set-stone ~a ~a~%" coords val)
  (while (not (eql (length (shapes-free-points-list board)) (next-shape-id board)))
    (vector-push-extend (make-array 1 :fill-pointer 0 :adjustable t) (shapes-free-points-list board)))
  (add-free-points-around board coords val)

     ;adjust neighebors, removing this free point
  (pdebug "Searching for shapes around ~a to notify to remove free point~%" coords)
  (do-over-adjacent (coords-var board coords)
    (pdebug "looking at ~a~%" coords-var)
    (let ((adj-sid (shape-id board coords-var)))
      (if (not (eql adj-sid nil))
	  (remove-free-point board coords adj-sid (get-player board coords-var))))))


(defmethod convert-shape :before ((board liberty-shape-board) shape-id to-id)
  (pdebug "convert-shape ~a to ~a~%" shape-id to-id)
  (pdebug "shape-points ~a~%"  (aref (shapes-points board) shape-id))
  (pdebug "player: ~a~%" (get-stone board (aref (aref (shapes-points board) shape-id) 0)))
  (if (> (length (aref (shapes-points board) shape-id)) 0)
      (let ((player (get-stone board (aref (aref (shapes-points board) shape-id) 0))))
	(inc-score board player (- (shape-liberty board shape-id)))
	(let
	    ((from-free (aref (shapes-free-points-list board) shape-id))
	     (to-free (aref (shapes-free-points-list board) shape-id)))
	  
	  (loop for i from 0 to (1- (length from-free)) do
	       (add-free-point board (aref from-free i) to-id player))
	  (setf (aref (shapes-free-points-list board) shape-id) (make-array 1 :fill-pointer 0 :adjustable t))))))
;    (inc-score board player (shape-liberty board to-id)))
    ;(setf (aref (shapes-free-points-list board) shape-id) (make-array 1 :fill-pointer 0 :adjustable t))))

;(defmethod convert-shape :after ((board liberty-shape-board) shape-id to-id)
;  (let ((player (get-stone board (aref (aref (shapes-points board) shape-id) 0)))



(defmethod score + ((board liberty-shape-board) player)
  (if (eql player #\B)
      (- (black-shape-liberties board) (white-shape-liberties board))
      (- (white-shape-liberties board) (black-shape-liberties board))))


(defun liberty-shape-to-analyze (board)
  (let ((lsb (make-2d-board (boardsize board) 0)))
    (do-over-board (coords board)
      (if (not (eql nil (shape-id board coords)))
          (set-2d-stone lsb coords (shape-liberty board (shape-id board coords)))))
  (concatenate 'string (board-to-analyze lsb)
               '(#\newline) " TEXT black shape liberties: " (write-to-string (black-shape-liberties board))
               " white shape liberties: " (write-to-string (white-shape-liberties board)))))



;(defmacro calc-shape-score (board var sid)
;  `(* (shape-size ,board ,sid) (aref (,var ,board) ,sid)))		  
	 

;(defclass liberty-shape-board (liberty-board shape-board)
;  (
;    ; stores lists (shape-liberties shape-libertirs-score)
;   (shapes-liberties
;    :initform nil
;    :accessor shapes-liberties) 
;   ; stores lists of free stones adjacent to shape
;   (shapes-free-points
;    :initform nil
;    :accessor shapes-free-points)
;   (shapes-free-scores
;    :initform nil
;    :accessor shapes-free-scores)
;   (black-shape-stone-liberties
;    :initform 0
;    :accessor black-shape-stone-liberties)
;   (white-shape-stone-liberties
;    :initform 0
;    :accessor white-shape-stone-liberties)
;   (black-shape-liberties
;    :initform 0
;    :accessor black-shape-liberties)
;   (white-shape-liberties
;    :initform 0
;    :accessor white-shape-liberties)))

;(defmethod initialize-instance :after ((board liberty-shape-board) &key from-board)
;  (if (eql from-board nil)
;      (progn
;        (setf (shapes-liberties board) (make-array 1 :fill-pointer 0 :adjustable t))
;	(setf (shapes-free-points board) (make-array 1 :fill-pointer 0 :adjustable t))
;	(setf (shapes-free-scores board) (make-array 1 :fill-pointer 0 :adjustable t)))
;      
;      (progn
;	(setf (shapes-liberties board) (copy-array (shapes-liberties from-board)))
;	(setf (shapes-free-points board) (copy-2d-array (shapes-free-points from-board)))
;	(setf (shapes-free-scores board) (copy-array (shapes-free-scores from-board)))
;	(copy-slots (white-shape-liberties black-shape-liberties black-shape-stone-liberties white-shape-stone-liberties) board from-board))))

;(defmacro shape-stone-liberties

;(defmacro calc-shape-stones-liberties (board sid)

    
;(defmacro inc-player-shape-stone-liberty (board player delta)
;  `(if (eql ,player #\B)
;       (incf (black-shape-stone-liberties ,board) ,delta)
;       (incf (white-shape-stone-liberties ,board) ,delta)))

;(defmacro inc-player-shape-liberty (board player delta)
;  `(if (eql ,player #\B)
;       (incf (black-shape-liberties ,board) ,delta)
;       (incf (white-shape-liberties ,board) ,delta)))
       

;(defmethod convert-shape :before ((board liberty-shape-board)  shape-id to-id)
;  (let ((player (get-stone board (aref (aref (shapes-points board) shape-id) 0))))
;    (inc-player-shape-stone-liberty board player (- (second (aref (shapes-liberties board) shape-id))))
;    (setf (aref (shapes-liberties board) shape-id) '(0 0))))


;(defun calculate-shape-liberties (board coords player)
;  (let* ((liberties 0)
;	 (sid (shape-id board coords))
;	 (shape-liberties-score (aref (shapes-liberties board) sid))
;	 (old-score (second shape-liberties-score)))
; ;   (pdebug "calculate-shape-liberties for sid:~a score:~a~%" sid shape-liberties-score)
;    (inc-player-shape-stone-liberty board player (- old-score))
;;    (pdebug "loop add liberties~%")
;    (loop for index from 0 to (1- (length (aref (shapes-points board) sid))) do
;;	 (pdebug "adding on ~a~%" index)
;	 (incf liberties (liberty board (aref (aref (shapes-points board) sid) index))))
;    (let ((score (* liberties (shape-size board sid))))
;;      (pdebug "sets shape-liberties for ~a (~a ~a)~%" sid liberties score)
;      (setf (aref (shapes-liberties board) sid) `(,liberties ,score))
;      (inc-player-shape-stone-liberty board player score))))
	


;(defun add-free-point (board coord sid player)
;  (inc-player-shape-liberty board player (- (aref (shapes-free-scores board) sid)))
;  (let* ((found nil)
;	 (free-points (aref (shapes-free-points board) sid)))
;    (loop for i from 0 to (1- (length free-points)) do
;	 (if (coords-eql coord (aref free-points i))
;	     (progn 
;	       (setf found t)
;	       (return))))
;    (if (eql found nil)
;	(progn
;	  (vector-push-extend coord free-points)))
;    (let ((newscore (* (shape-size board sid) (length free-points))))
;      (setf (aref (shapes-free-scores board) sid) newscore)
;      (inc-player-shape-liberty board player newscore))))

;(defun add-free-points-around (board nexus player)
;  (let ((sid (shape-id board nexus)))
;    (do-over-adjacent (coords-var board nexus)
;      (if (eql (get-stone board coords-var) nil)
;	  (add-free-point board coords-var sid player)))))
  
;(defun remove-shape (board sid)
;  (pdebug "remove-shape ~a~%" sid)
;  (let ((stones (aref (shapes-points board) sid)))
;    (loop for index from 0 to (1- (length stones)) do 
;	 (progn (pdebug "removing stone ~a~%" (aref stones index))
;	 (remove-stone board (aref stones index))))))
	 

;(defun remove-free-point (board coord sid player)
;  (let ((free-points (aref (shapes-free-points board) sid)))
;    (if (> (length free-points) 0)
;	(let ((tmp (aref free-points (1- (length free-points)))))
;	 ; (pdebug "dec inc-player-shape-liberty~%")
;
;	  ;(pdebug "search for point~%")
;	  (loop for i from 0 to (1- (length free-points)) do
;	   ;    (pdebug "search ~a" i)
;	       (if (coords-eql coord (aref free-points i))
;		   (progn
;		;     (pdebug "found on ~a @ ~a" i  (aref free-points i))
;		     (setf (aref free-points i) tmp)
;		 ;    (pdebug "do vector pop~%")
;		     (vector-pop free-points)
;		;   (pdebug "inc-player-shape-liberty~%")
;		     (inc-player-shape-liberty board player (- (aref (shapes-free-scores board) sid)))
;		     (inc-player-shape-liberty board player (* (length free-points) (shape-size board sid)))
;		   ;  (pdebug "set shapes-free-scores new score for ~a~%" sid)
;		     (setf (aref (shapes-free-scores board) sid)  (* (length free-points) (shape-size board sid)))
;		     (return))))
;	  (if (= 0 (length free-points))
;	      (remove-shape board sid))))))
	 


;(defmethod set-stone :after ((board liberty-shape-board) coords val)
;  (while (not (eql (length (shapes-liberties board)) (next-shape-id board)))
;    (vector-push-extend '(0 0) (shapes-liberties board)) ; new shape
;    (vector-push-extend 0 (shapes-free-scores board)) 
;    (vector-push-extend (make-array 1 :fill-pointer 0 :adjustable t) (shapes-free-points board)))
;  (calculate-shape-liberties board coords val)
; ; (pdebug "about to add-free-points~%")
;  (add-free-points-around board coords val)
;  ;adjust neighebors
; ; (pdebug "about to adjust neighbors~%")
;  (let ((sid (shape-id board coords)))
;    (do-over-adjacent (coords-var board coords)
;      (let ((adj-sid (shape-id board coords-var))
;	    (adj-player (get-player board coords-var)))
;	(if (not (eql adj-sid nil))
;	    (progn
;	      (pdebug "adjusting: from coord:~a removing free: ~a and sid:~a player ~a~%" coords coords-var adj-sid adj-player)
;	      (remove-free-point board coords adj-sid adj-player)
;	      (pdebug "remove-free-point done~%")
;	      (if (not(eql adj-sid sid))
;		  (calculate-shape-liberties board coords-var (get-stone board coords-var)))
;	      (pdebug "done calculate-shape-liberties~%")))))))



;(defmethod score + ((board liberty-shape-board) player)
;  (if (eql player #\B)
;      (- (black-shape-liberties board) (white-shape-liberties board))
;      (- (white-shape-liberties board) (black-shape-liberties board))))


;(defmethod score + ((board liberty-shape-board) player)
;  (if (eql player #\B)
;      (- (black-shape-stone-liberties board) (white-shape-stone-liberties board))
;      (- (white-shape-stone-liberties board) (black-shape-stone-liberties board))))