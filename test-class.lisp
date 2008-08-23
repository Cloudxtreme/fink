(defclass class_a ()
  ((a
   :initarg :a
   :initform (make-array 10 :initial-element 0)
   :accessor a)))

(defclass class_b (class_a)
  ((b 
   :initform (make-array 10 :initial-element 0)
   :initarg b
   :accessor b)))


(defclass class_c (class_a)
  ((b
    :initform (make-array 10 :initial-element 1)
    :initarg b
    :accessor b)))

(defclass class_d (class_b class_c)
  ((d
    :initform 0
    :accessor d)))

(defgeneric dothing (class data)
  (:method-combination progn :most-specific-last))
  

(defmethod dothing progn ((class class_a) data)
  (loop for i from 0 to 9 do (setf (aref (a class) i) (+ (aref (a class) i) 1))));data))))

(defmethod dothing progn ((class class_b) data)
  (loop for i from 0 to 9 do (progn (setf (aref (b class) i) (+ (aref (b class) i) 2)) (print (aref (b class) i)))));(aref (a class) i) data))))

(defmethod dothing progn ((class class_c) data)
  (loop for i from 0 to 9 do (progn (setf (aref (b class) i) (+ (aref (b class) i) 3)) (print (aref (b class) i)))))

(defgeneric doother4 (class data)
  );(:method-combination progn :most-specific-last))

(defmethod doother4  ((class class_a) data)
  (format t "class_a~%")
  (loop for i from 0 to 4 do (setf (aref data i) "a"))
  data)


(defmethod doother4 :after ((class class_b) data)
  (format t "class_b~%")
  (loop for i from 0 to 2 do (setf (aref data i) "b"))
  data)

(defmethod (setf a) (new-number (class class_a))
  (setf (aref (a class) 0) new-number))


;(defmethod (setf a) (new-number index (class class_a))
;  (setf (aref (a class) index) new-number))