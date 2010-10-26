;; This file is part of alien-bind library
;;
;; (C) 2010 g/christensen (gchristnsn@gmail.com)

(defpackage :alien-bind-asd
  (:use :common-lisp :asdf))

(in-package :alien-bind-asd)

(defsystem :alien-bind
  :description "Seamlessly eval alien code inside the Lisp."
  :version "0.1"
  :components ((:file "packages")
               (:file "alien-bind")
               (:file "alien-bind-vbs")
               (:file "alien-bind-python"))
  :depends-on (:cl-ppcre :external-program :trivial-shell))