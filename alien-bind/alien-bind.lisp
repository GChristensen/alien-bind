;; This file is part of alien-bind library
;;
;; (C) 2010 g/christensen (gchristnsn@gmail.com)

(in-package :alien-bind)

(defparameter *left-delimiter* "@>")
(defparameter *right-delimiter* "<@")

(defvar *script-lang*)

(defgeneric alien-strip-left (delim lang))
(defgeneric alien-strip-right (delim lang))
(defgeneric alien-escape-quotes (str lang))
(defgeneric alien-inject-lisp (form code lang))
(defgeneric alien-assemble-cmdline (file-name lang))

(defun alien-decorate-var (var)
  (let ((var (regex-replace-all "-" (string var) "_")))
	(format nil "~a~(~a~)~a" *left-delimiter* var *right-delimiter*)))

(defun alien-decorate-num (var)
  `(read-from-string ,(alien-decorate-var var)))

(defun decorate-vars (vars)
  (mapcar #'(lambda (var)
			  (list var (alien-decorate-var var)))
		  vars))

(defun lisp-escape-backslashes (str)
  (quote-meta-chars str))

(defun lisp-escape-quotes (str)
  (regex-replace-all "\"" str (quote-meta-chars "\\\"")))

(defun lisp-quote (str)
  (lisp-escape-quotes (lisp-escape-backslashes str)))

(defun alien-strip-vars (str)
  (regex-replace-all *left-delimiter* 
					 (regex-replace-all *right-delimiter* str 
										(alien-strip-right *right-delimiter*
                                                           *script-lang*))
					 (alien-strip-left *left-delimiter* *script-lang*)))

(defun alien-strip-values (str)
  (regex-replace-all (format nil "~a(.*)?~a" *left-delimiter*
							 *right-delimiter*)
					 str #'(lambda (str &rest registers)
							 (declare (ignore str))
							 (lisp-quote (car registers)))
					 :simple-calls t))

(defmacro with-dumped-code ((code file-name) &body body)
  `(let ((,file-name (concatenate 'string (get-env-var "TEMP") 
								  "/alien-bind." (string (gensym)))))
	   (unwind-protect
			(progn
			  (with-open-file (strm ,file-name 
									:direction :output :if-exists :supersede)
				(princ ,code strm))
			  ,@body)
		 (delete-file ,file-name))))

(defun alien-execute-code (code)
  (with-dumped-code (code script-file)
	(with-output-to-string (strm)
	  (apply #'run `(,@(alien-assemble-cmdline script-file *script-lang*)
					   #-(and (or sbcl clisp) win32) ,@`(:output ,strm))))
	  #+(and (or sbcl clisp) win32)
	  (with-open-file (strm script-file :direction :input)
		(read-line strm))))

(defun alien-eval (form code)
  (let ((form (alien-strip-vars (alien-escape-quotes 
                                  (format nil "~s" form) *script-lang*))))
    (read-from-string
     (alien-strip-values 
	  (alien-execute-code
	   (alien-inject-lisp form code *script-lang*))))))

(defmacro alien-bind ((&rest vars) lang code &body body)
  `(let ((*script-lang* ,lang))
	 (eval `(let ,(alien-eval (decorate-vars ',vars) ,code)
			  ,@',body))))