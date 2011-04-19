alien-bind (C) 2010 g/christensen (gchristnsn@gmail.com)

alien-bind is a macro which allows to seamlessly execute alien code from the
Common Lisp code with alien (currently only string) variable values bound to 
the specified lisp symbols. Emacs Lisp port is also available.


Supported external languages:

  Python
  VBScript


Dependencies

  Common Lisp

    * cl-ppcre
    * trivial-shell
    * external-program

  Emacs Lisp
   
    none


Example (get processor info from the Windows system registry):

(asdf:oos 'asdf:load-op :cl-interpol)
(asdf:oos 'asdf:load-op :alien-bind)

(use-package :cl-interpol)
(use-package :alien-bind)

(enable-interpol-syntax)

(alien-bind (processor-info)
  :vbs #?{
    On Error Resume Next
    Dim objShell
    Dim processor_info

    Set objShell = CreateObject("WScript.Shell")
    processor_info = objShell.RegRead("HKLM\\HARDWARE\\DESCRIPTION\\System\\" & _
                                      "CentralProcessor\\0\\ProcessorNameString")
  }
  (format t processor-info))
