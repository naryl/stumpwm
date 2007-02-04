(defpackage :test-wm (:use :cl))
(in-package :test-wm)

(defmacro define-test ((n dpy screen) &body body)
  `(defun ,(intern (format nil "TEST-~d" n)) (,dpy ,screen)
     (format t "Starting test ~d~%" ,n)
     ,@body
     (format t "Done.~%")))

(define-test (1 dpy screen)
    (let ((w (xlib:create-window :parent (xlib:screen-root screen)
                                 :x 10 :y 10 :width 100 :height 100 :border-width 1)))
      (xlib:map-window w)
      (xlib:display-finish-output dpy)
      (xlib:destroy-window w)
      (xlib:display-finish-output dpy)))

(define-test (2 dpy screen)
    (let ((w (xlib:create-window :parent (xlib:screen-root screen)
                                 :x 10 :y 10 :width 100 :height 100 :border-width 1)))
      (xlib:map-window w)
      (xlib:display-finish-output dpy)
      (sleep 1)
      (setf (xlib:window-priority w) :above)
;;       (setf (xlib:drawable-border-width w) 3)
      (xlib:display-finish-output dpy)
      (xlib:destroy-window w)
      (xlib:display-finish-output dpy)))

(define-test (3 dpy screen)
    (let ((windows (loop for i from 0 to 100
		      collect (let ((w (xlib:create-window :parent (xlib:screen-root screen)
							   :x 10 :y 10 :width 100 :height 100 :border-width 1)))
				(xlib:map-window w)
				(xlib:display-finish-output dpy)
				(setf (xlib:window-priority w) :above)
				w))))
      (xlib:display-finish-output dpy)
      (loop for i in windows do
	   (xlib:unmap-window i))
      (xlib:display-finish-output dpy)
      (sleep 3)
      (loop for i in windows do
	   (xlib:destroy-window i))))

(define-test (4 dpy screen)
    (let ((windows (loop for i from 0 to 100
		      collect (let ((w (xlib:create-window :parent (xlib:screen-root screen)
							   :x 10 :y 10 :width 100 :height 100 :border-width 1)))
				(xlib:map-window w)
				(xlib:display-finish-output dpy)
				(setf (xlib:window-priority w) :above)
				w))))
      (xlib:display-finish-output dpy)
      (loop for i in windows do
	   (xlib:unmap-window i))
      (xlib:display-finish-output dpy)
      (sleep 3)
      (loop for i in windows do
	   (xlib:destroy-window i))))
    

(defun parse-display-string (display)
  "Parse an X11 DISPLAY string and return the host and display from it."
  (let* ((colon (position #\: display))
	 (host (subseq display 0 colon))
	 (rest (subseq display (1+ colon)))
	 (dot (position #\. rest))
	 (num (parse-integer (subseq rest 0 dot))))
    (values host num)))

(defvar *dpy* nil)

(defun test-wm (display-str)
  (multiple-value-bind (host display) (parse-display-string display-str)
    (setf *dpy* (xlib:open-display host :display display :protocol nil))
    (let* ((dpy *dpy*)
           (screen (first (xlib:display-roots dpy))))
      (unwind-protect 
	   (progn
	     (test-1 dpy screen)
	     (test-2 dpy screen)
	     (test-3 dpy screen))
	(xlib:close-display *dpy*)))))
