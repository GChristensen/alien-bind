;; This file is part of alien-bind library
;;
;; (C) 2010 g/christensen (gchristnsn@gmail.com)

(defpackage :alien-bind-python (:use :cl :cl-ppcre :alien-bind))

(in-package :alien-bind-python)

(defparameter *python-result-printer*
;; print to stdout
#-(and (or sbcl clisp) win32)
  "~a
print \"~a\""
;; print to file
#+(and (or sbcl clisp) win32)
  "~a
import os
open(os.path.abspath(__file__), 'w').write(\"~a\")")

(defmethod alien-strip-left (delim (lang (eql :python)))
  (format nil "~a\" + " delim))

(defmethod alien-strip-right (delim (lang (eql :python)))
  (format nil " + \"~a" delim))

(defmethod alien-escape-quotes (str (lang (eql :python)))
  (regex-replace-all "\"" str "\\\""))

(defmethod alien-inject-lisp (form code (lang (eql :python)))
  (format nil *python-result-printer* code form))

(defmethod alien-assemble-cmdline (file-name (lang (eql :python)))
   (list "python" (list file-name)))
