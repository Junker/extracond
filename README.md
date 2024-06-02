# Extracond

Extra set of conditional macros for Common Lisp

## Installation

This system can be installed from [UltraLisp](https://ultralisp.org/) like this:

```lisp
(ql-dist:install-dist "http://dist.ultralisp.org/"
                      :prompt nil)
(ql:quickload "extracond")
```

## Macros

```common-lisp
(defmacro let1 (var val &body body))
```
Bind VAR to VAL and evaluate BODY. Same as `(let ((VAR VAL)) BODY)`

```common-lisp
(defmacro if-let1 (var val &body body))
```
Bind VAR to VAL in THEN/ELSE form.

```common-lisp
(defmacro when-let1 (var val &body body))
```
Bind VAR to VAL and executes BODY if VAL is non-nil.

```common-lisp
(defmacro if-let* (bindings then-form else-form))
```
Creates new variable bindings, and conditionally executes either THEN-FORM or ELSE-FORM. ELSE-FORM defaults to NIL.
IF-LET* is similar to IF-LET, but the bindings of variables are performed sequentially rather than in parallel.

```common-lisp
(defmacro cond-list (&rest clauses))
```
Construct a list by conditionally adding entries. Each clause has a test and expressions.
When its test yields true, the result of associated expression is used to construct the resulting list.
When the test yields false, nothing is inserted.
Clause must be either one of the following form:
- `(test expr …)`
Test is evaluated, and when it is true, expr … are evaluated, and the return value
becomes a part of the result.
If no expr is given, the result of test is used if it is not false.

- `(test => proc)`
Test is evaluated, and when it is true, proc is called with the value,
and the return value is used to construct the result.

- `(test @ expr …)`
Like (test expr …), except that the result of the last expr must be a list,
and it is spliced into the resulting list, like unquote-splicing.

- `(test => @ proc)`
Like (test => proc), except that the result of proc must be a list,
and it is spliced into the resulting list, like unquote-splicing.

## Examples

```common-lisp
(let1 var 100
  ...)

(if-let1 var 100
  ...)

(when-let1 var 100
  ...)
  
(if-let* ((var 100))
  ...
)

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
