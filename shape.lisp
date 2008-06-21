(in-package :shape-board)

(defclass shape-board (basic-board)
  ((shape-board
    :initform nil
    :accessor shape-board)
   (shape-sizes
    :initform nil
    :accessor shape-sizes)
   (shapes-points
    :initform nil
    :accessor shapes-points)
   (next-shape-id
    :initform 0
    :accessor next-shape-id)))

(defmethod initialize-instance :after ((board shape-board) &key from-board)
  (if (eql from-board nil)
      (progn 
	(setf (shape-board board) (make-2d-board (boardsize board) nil))
	(setf (shape-sizes board) (make-array 1 :fill-pointer 0 :adjustable t))
	(setf (shapes-points board) (make-array 1 :fill-pointer 0 :adjustable t)))
      (progn
	(setf (shape-board board) (copy-2d-board (shape-board from-board)))
	(setf (shape-sizes board) (copy-array (shape-sizes from-board)))
	(setf (shapes-points board) (copy-2d-array (shapes-points from-board)))
	(copy-slots (next-shape-id) board from-board))))

(defmacro shape-id (board coords)
  `(get-2d-stone (shape-board ,board) ,coords))

(defun add-shape (board coords)
  (set-2d-stone (shape-board board) coords (next-shape-id board))
  (vector-push-extend 1 (shape-sizes board))
  (vector-push-extend (make-array  1 :fill-pointer 0 :adjustable t) (shapes-points board))
  (vector-push-extend coords (aref (shapes-points board) (next-shape-id board)))
  (incf (next-shape-id board)))
		      
(defun add-to-shape (board coords shape-id)
  (set-2d-stone (shape-board board) coords shape-id)
  (vector-push-extend coords (aref (shapes-points board) shape-id))
  (incf (aref (shape-sizes board) shape-id)))

(defmacro size-of-shape (board shape-id)
  `(aref (shape-sizes ,board) ,shape-id))

(defgeneric convert-shape (board shape-id to-id))

(defmethod convert-shape ((board shape-board) shape-id to-id)
;  (format t "convert-shape ~a to ~a~%" shape-id to-id)
  (loop for index from 0 to (1- (length (aref (shapes-points board) shape-id))) do
       (add-to-shape board (aref (aref (shapes-points board) shape-id) index ) to-id))
  (setf (aref (shapes-points board) shape-id) (make-array 1 :fill-pointer 0 :adjustable t))
  (setf (aref (shape-sizes board) shape-id) 0))

(defgeneric join-shapes (board nexus shapes-list))

(defmethod join-shapes ((board shape-board) nexus shapes-list)
  (let ((biggest-shape (first shapes-list)))
    (loop for shape-id in shapes-list do 
	 (if (>  (size-of-shape board shape-id) (size-of-shape board biggest-shape))
	     (setf biggest-shape shape-id)))
    
    (loop for shape-id in shapes-list do
	 (if (not (= shape-id biggest-shape))
	       (convert-shape board shape-id biggest-shape)))
    (add-to-shape board nexus biggest-shape)))
	 

(defmethod set-stone :after ((board shape-board) coords val)
  (let ((alist nil))
    (do-over-adjacent (coords-var board coords)
      (if (eql val (get-stone board coords-var))
	  (push (get-2d-stone (shape-board board) coords-var) alist)))
    (if (eql alist nil)
	(add-shape board coords)
	(if (eql (cdr alist) nil) ; one item
	    (add-to-shape board coords (car alist))
	    (join-shapes board coords alist)))))
	    
;(defun shape-to-analyze ())

(defun shapes-to-analyze (board)
  (concatenate 'string (board-to-analyze (shape-board board))
	       '(#\newline) " TEXT next-shape-id: " (write-to-string (next-shape-id board)) " length(shapes-points): " (write-to-string (length (shapes-points board)))))
	       