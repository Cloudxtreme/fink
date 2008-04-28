(in-package :gtp-handler)

(defun gtp-client ()
  (do ((quit? nil))
      (= quit? nil)
    (dispatch-gtp-command (read-line t))))

(defun dispatch-gtp-command (command-string)
  (let* ((commands (split-string (string-downcase command-string) " "))
	 (command (intern (first commands))))
    (case (command)
      (thing
  