;; This file is part of alien-bind library
;;
;; (C) 2010 g/christensen (gchristnsn@gmail.com)

(defpackage :alien-bind-vbs (:use :cl :cl-ppcre :alien-bind))

(in-package :alien-bind-vbs)

(defparameter *vbs-result-printer*
;; print to stdout
#-(and (or sbcl clisp) win32)
  "~a
   Wscript.StdOut.WriteLine \"~a\""
;; print to file
#+(and (or sbcl clisp) win32)
  "~a
   CreateObject(\"Scripting.FileSystemObject\") _
    .GetFile(Wscript.ScriptFullName) _
      .OpenAsTextStream(2) _
        .WriteLine \"~a\"")

(defmethod alien-strip-left (delim (lang (eql :vbs)))
  (format nil "~a\" & " delim))

(defmethod alien-strip-right (delim (lang (eql :vbs)))
  (format nil " & \"~a" delim))

(defmethod alien-escape-quotes (str (lang (eql :vbs)))
  (regex-replace-all "\"" str "\"\""))

(defmethod alien-inject-lisp (form code (lang (eql :vbs)))
  (format nil *vbs-result-printer* code form))

(defmethod alien-assemble-cmdline (file-name (lang (eql :vbs)))
   (list "cscript" `("//Nologo" "//E:vbs" ,file-name)))
