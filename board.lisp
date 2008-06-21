(in-package :board)

(defmacro do-with-copy-of-array ((itr-name copy-name array) &body body)
    `(let ((,copy-name (make-array (length ,array) :fill-pointer (fill-pointer ,array)  :adjustable t)))
       (dotimes (,itr-name (length ,array))
	 ,@body)
       ,copy-name))

(defun copy-array (array)
  (do-with-copy-of-array (i copy array)
    (setf (aref copy i) (aref array i))))

(defun copy-2d-array (array)
  (do-with-copy-of-array (i copy array)
    (setf (aref copy i) 
	  (if (eql (aref array i) nil)
	      nil
	      (copy-array (aref array i))))))


(defun make-2d-board (size &optional (initial nil))
  (let ((array (make-array size)))
    (dotimes (i size)
      (setf (aref array i) (make-array size :initial-element initial)))
    array))

(defun copy-2d-board (board)
  (let ((copy (make-array (length board))))
    (dotimes (i (length board))
      (setf (aref copy i) (copy-seq (aref board i))))
    copy))


(defun filter-i-number (number)
  (if (> number 8) 
      (1- number)
      number))

(defun str-to-coord (str)
 `(,(abs (- (parse-integer (subseq str 1)) 19))  ,(filter-i-number (- (char-code (char (string-upcase str) 0)) 65))))

;  `( ,(filter-i-number (- (char-code (char (string-upcase str) 0)) 65)) ,(- (parse-integer (subseq str 1)) 1)))

(defun filter-i-char (number)
  (if (>= number 8)
      (1+ number)
      number))

(defun coord-to-str (coord)
  (concatenate 'string (string (code-char (+ 65 (filter-i-char (second coord)))))
	       (write-to-string (+ (- (first coord)) 19))))

;  (concatenate 'string (string (code-char (+ 65 (filter-i-char (first coord)))))
;		(write-to-string (+ (second coord) 1))))



(defun get-2d-stone (board coord)
  (if (not (listp coord))
      (progn
	(format t "MASSIVE ERROR!~%trying to access coord:~a on board" coord))
      (aref (aref board (first coord)) (second coord))))

(defun set-2d-stone (board coord val)
  (setf (aref (aref board (first coord)) (second coord)) val))



(defclass  basic-board ()
  ((boardsize
    :initarg :boardsize
    :initform 19
    :accessor boardsize)
   (board-def-type
    :initarg :board-def-type
    :initform nil
    :accessor board-def-type)
   (board
    :accessor board
    :initform nil)))


(defgeneric set-stone (board coords val))
(defgeneric get-stone (board coords))

(defmethod set-stone ((board basic-board) coords val)
  (set-2d-stone (board board) coords val))

(defmethod get-stone ((board basic-board) coords)
  (get-2d-stone (board board) coords))


;(defgeneric (setf stone) (val coords

(defmethod initialize-instance :after ((board basic-board) &key from-board)
;  (format t "init basic-board~%")
  (if (eql from-board nil)
      (setf (board board) (make-2d-board (boardsize board) (board-def-type board)))
      (progn
	(setf (boardsize board) (boardsize from-board))
	(setf (board-def-type board) (board-def-type from-board))
	(setf (board board) (copy-2d-board (board from-board))))))



(defmacro do-over-board ((coord board) &body body)
  `(dotimes (x (boardsize ,board))
     (dotimes (y (boardsize ,board))
       (let ((,coord `(,x ,y)))
	 (progn ,@body)))))


(defmacro def-over-board (name (coord board &rest vars)  &rest body)
  `(defun ,name (,board ,@vars)
     (do-over-board (,coord ,board)
       (progn ,@body))))

(defmacro do-over-adjacent  ((coords-var board coords) &body body)
  `(let* ((x (first ,coords))
	  (y (second ,coords))
	  (up (1- x))
	  (down (1+ x))
	  (left (1- y))
	  (right (1+ y)))
     (if (>= up 0) (let ((,coords-var `(,up ,y))) ,@body))
     (if (>= left 0) (let ((,coords-var `(,x ,left))) ,@body))
     (if (< down (boardsize ,board)) (let ((,coords-var `(,down ,y))) ,@body))
     (if (< right (boardsize ,board)) (let ((,coords-var `(,x ,right))) ,@body))))


(defclass ranked-board (basic-board)
  ((rank-list
    :initarg rank-list
    :initform nil
    :accessor rank-list)
   (rank-top-list
    :initarg rank-top-list
    :initform nil
    :accessor rank-top-list)
   (rank-highest
    :initarg rank-highest
    :initform nil
    :accessor rank-highest)
   (rank-count
    :initarg rank-count
    :initform 0
    :accessor rank-count)
   (rank-top-count
    :initarg rank-top-count
    :initform 0
    :accessor rank-top-count)))

(defmacro copy-slots (slots dst src)
  `(progn ,@(loop for slot in slots collect `(setf (,slot ,dst) (,slot ,src)))))

(defmethod initialize-instance :after ((board ranked-board) &key from-board)
  (if (not (eql from-board nil))
      (progn
	(copy-slots (rank-highest rank-count rank-top-count) board from-board)
	(setf (rank-list board) (copy-seq (rank-list from-board)))
	(setf (rank-top-list board) (copy-seq (rank-top-list from-board))))))
      


(defun insert (list comp var)
  (if (funcall comp (car list) var)
      (cons var list)
      (cons (car list) (insert (cdr list) comp var))))


(defmethod set-stone :after ((board ranked-board) coords val)
;  (format t "~a ~a~%" coords val)
  (incf (rank-count board))
  (if (or (eql (rank-highest board) nil) (>= val (rank-highest board)))
      (progn
	(setf (rank-list board) (cons `(,val ,coords) (rank-list board)))
	(if (or (eql (rank-highest board) nil) (> val (rank-highest board)))
	    (progn 
	      (setf (rank-highest board) val)
	      (setf (rank-top-count board) 1)
	      (setf (rank-top-list board) `((,val ,coords))))
	    (progn
	      (incf (rank-top-count board))
	      (setf (rank-top-list board) (cons `(,val ,coords) (rank-top-list board))))))
      (if (= (rank-count board) 1)
	  (setf (rank-list board) `((,val ,coords)))
	  (setf (rank-list board) (insert (rank-list board) #'(lambda (a b) (>= (first a) (first b))) `(,val ,coords))))))
	
	
	
	     

		  

(defgeneric prune (board prune-board)
 (:documentation "board is the board we are working from, prune-board is an initially all t's board and each no go place is set to nil"))

(def-over-board prune-placed-stones (coord board prune-board)
  (if (not (eql (get-stone board coord) nil))
	(set-stone prune-board coord nil)))


(defmethod prune ((board basic-board) prune-board)
  (prune-placed-stones board prune-board))




;(defgeneric prune :after ((board liberty-board) prune-board)
;  (prunce-suicide board prunce-board)) 


(defgeneric focus (board prune-board focus-board player)
  (:documentation "prunce-board: t or nil, focus board: ranked board with scores"))


(defmethod focus ((board basic-board) prune-board focus-board player)
  (do-over-board (coord prune-board)
    (if (not (eql (get-stone prune-board coord) nil))
	(set-stone focus-board coord 1))))

(defgeneric search-space (board focus-board score-board player depth)
    )

(defmacro invert-player (player)
  `(if (eql ,player #\W)
      #\B
      #\W))

; multiplex the search here
(defmethod search-space ((board basic-board) focus-board score-board player depth)
  ; (rank-count board) / basic-proc-unit 
  (do-over-board (coord board)
    (if (not (eql (get-stone focus-board coord) nil))
	(let ((newboard (make-instance (class-of board) :from-board board)))
	  (set-stone newboard coord player)
	  (set-stone score-board coord (first (genmove newboard  (invert-player player):depth (1- depth))))))))
  
  
(defgeneric score (board player)
   (:method-combination + :most-specific-last))

(defmethod score + ((board basic-board) player)
  1)


(defgeneric select-move (board) 
  )

(defmethod select-move ((board ranked-board))
  (if (eql (rank-top-count board) 0)
      '(-1 (-1 -1))
      (car (nthcdr (random (rank-top-count board)) (rank-top-list board)))))



(defgeneric genmove (board player &key))

; generate a same sized board with a def type
(defmacro gen-board (board def-type &optional (class ''basic-board))
  `(make-instance ,class :boardsize (boardsize ,board) :board-def-type ,def-type))

(defmethod genmove ((board basic-board) player &key (depth 1))
;  (format t "genmove depth ~a player ~a~%" depth player)
  (if (= depth 0)
      `( ,(score board (invert-player player)) nil)
      (let ((score-board (make-instance 'ranked-board :boardsize (boardsize board) :board-def-type nil))   ;(gen-board board 0 'ranked-board))
	    (prune-board (gen-board board t))
	    (focus-board (gen-board board nil)))
	(progn
	  (prune board prune-board)
	  (focus board prune-board focus-board player)
	  (search-space board focus-board score-board player depth)
	  (select-move score-board)))))

(defun board-to-analyze (board)
  (let ((resp "LABEL "))
    (dotimes (x (length board))
      ;(format t "x:~a~%" x)
      (dotimes (y (length board))
	;(format t "y:~a~%" y)
	(let ((coord `(,x ,y)))
	  
	  (setf resp (concatenate 'string resp (coord-to-str coord) " "
		       (if (eql (get-2d-stone board coord) nil)
			   "0 "
			   (write-to-string (get-2d-stone board coord))) " ")))
      (concatenate 'string resp '(#\newline))))
	resp))

(defun analyze-board-score (board player)
  (let ((score-board (make-instance 'basic-board :boardsize (boardsize board) :board-def-type nil)))
    (progn
      (do-over-board (coord board)
	(if (eql (get-stone board coord) nil)
	    (let ((newboard (make-instance (class-of board) :from-board board)))
	      (set-stone newboard coord player)
	      (set-stone score-board coord (first (score newboard player))))))
      (board-to-analyze (board score-board)))))


  
;(defun make-move (board player)
;  (select-move (score board player)))

;(defun score (board player)
;  (let ((score-board (make-board (length board) 0)))
;    (dolist (slist *score-functions*)
;      (merge-score-board score-board (funcall (first slist) board player) (second slist)))
;    score-board))
    
;(defun merge-score-board (score-board scores weight)
;  (dotimes (x (length score-board))
;    (dotimes (y (length score-board))
;      (set-stone score-board `(,x ,y) (+ (get-stone score-board `(,x ,y)) (* weight (get-stone scores `(,x ,y))))))))
      

;(defun select-move (board)
;  (let ((highest (get-stone board '(0 0)))
;	(coords (make-array 10 :fill-pointer 0 :adjustable t)))
;    (do ((x 0 (1+ x)))
;	((>= x (length board)) (aref coords (random (length coords))))
;      (do ((y 0 (1+ y)))
;	  ((>= y (length board)))
;	(let ((score (get-stone board `(,x ,y))))
;	  (if (> score highest)
;	      (progn
;		(setf highest score)
;		(setf coords (make-array 10 :fill-pointer 0 :adjustable t ))
;		(vector-push-extend `(,x ,y) coords))
;	      (if (= score highest)
;		  (if (= (random 2) 1)
;		      (vector-push-extend `(,x ,y) coords)))))))))
      

