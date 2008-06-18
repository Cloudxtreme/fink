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

(defun copy-array (array &optional)
    (let ((copy (make-array (1+ (length array)) :adjustable t)))
      (dotimes (i (length array))
	(setf (aref copy i) (aref array i)))))


(defmethod initialize-instance :after ((board shape-board) &key from-board)
  (if (eql from-board nil)
      (progn 
	(setf (shape-board board) (make-2d-board (boardsize board) nil))
	(setf (shape-sizes board) (make-array 2 :fill-pointer 0 :adjustable t))
      
      (progn
	(setf (shape-board board) (copy-2d-board (shape-board from-board)))
	(setf (shape-sizes board) (copy-array (shape-sizes from-board)))
	(copy-slots (next-shape-id) board from-board)))))

(defmethod add-shape ((board shape-board) coords)
  (set-2d-stone (shape-board board) coords (next-shape-id board))
  (vector-push-extend 1 (shape-sizes board))
  (incf (next-shape-id board)))
		      
(defmethod add-to-shape ((board shape-board) coords shape-id)
  (set-2d-stone (shape-board board) coords shape-id)
  (incf (aref (shape-sizes board) shape-id)))

(defmacro size-of-shape ((board shape-board) shape-id)
  (aref (shape-sizes board) shape-id))

(defmethod join-shapes ((board shape-board) nexus shapes-list)
  (let ((biggest-shape (first (shapes-list))))
    (loop for shape-id in shape-list do 
	 (if (>  (size-of-shape board shape-id) (size-of-shape board biggest-shape))
	     (setf biggest-shape shape-id)))
    
    (loop for shape-id in shape-list do
	 (if (not (= shape-id biggest-shape))
	       (convert-shape board shape-id biggest-shape)))
    (add-to-shape board nexus biggest-shape)))
	 

(defmethod set-stone :after ((board shape-board) coords val)
  (let ((alist nil))
    (do-over-adjacent (coords-var board coords)
      (if (not (eql nil (get-2d-stone (shape-board board) coords-var)))
	  (push (get-2d-stone (shape-board board) coords-var) alist))
      (if (eql alist nil)
	  (add-shape board coords)
	  (if (eql (cdr alist) nil) ; one item
	      (add-to-shape board coords (car (first alist)))
	      (join-shapes board coords alist))))
	    
  

      
;(defun shape-to-analyze ())