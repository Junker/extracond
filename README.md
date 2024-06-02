# Extracond

Extra set of conditional macros for Common Lisp

## Installation

This system can be installed from [UltraLisp](https://ultralisp.org/) like this:

```lisp
(ql-dist:install-dist "http://dist.ultralisp.org/"
                      :prompt nil)
(ql:quickload "extracond")
```

## Usage

```common-lisp
(let1 var 100
  ...)

(if-let1 var 100
  ...)

(when-let1 var 100
  ...)

;; cond-list
(let ((alist '((x 3) (y -1) (z 6))))
   (cond-list ((assoc 'x alist) 'have-x)
              ((assoc 'w alist) 'have-w)
              ((assoc 'z alist) => cadr)))
   ;; ⇒ (have-x 6)

(let ((x 2) (y #f) (z 5))
  (cond-list (x @ `(:x ,x))
             (y @ `(:y ,y))
             (z @ `(:z ,z))))
  ;; ⇒ (:x 2 :z 5)

```
