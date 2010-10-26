;; This file is part of alien-bind library
;;
;; (C) 2010 g/christensen (gchristnsn@gmail.com)

(defpackage :alien-bind
  (:use :common-lisp
		:cl-ppcre
		:external-program
		:trivial-shell)
  (:export :alien-bind
		   :alien-strip-right
		   :alien-strip-left
		   :alien-escape-quotes
		   :alien-inject-lisp
		   :alien-assemble-cmdline))
