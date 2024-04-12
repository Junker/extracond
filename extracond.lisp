(in-package #:extracond)

(defmacro let1 (var val &body body)
  "Bind VAR to VAL and evaluate BODY.
Same as (let ((VAR VAL)) BODY)"
  `(let ((,var ,val))
     ,@body))

(defmacro if-let1 (var val &body body)
  "Bind VAR to VAL in THEN/ELSE form."
  `(uiop:if-let ((,var ,val))
     ,@body))

(defmacro when-let1 (var val &body body)
  "Bind VAR to VAL and executes BODY if VAL is non-nil."
  `(uiop:if-let ((,var ,val))
     (progn
       ,@body)))

(defmacro if-let* (bindings then-form else-form)
  "Creates new variable bindings, and conditionally executes either
THEN-FORM or ELSE-FORM. ELSE-FORM defaults to NIL.
IF-LET* is similar to IF-LET, but the bindings of variables are performed sequentially rather than in parallel."
  (let ((outer (gensym))
        (inner (gensym)))
    `(block ,outer
       (block ,inner
         (let* ,(loop :for (symbol value) :in bindings
                      :collect `(,symbol (or ,value
                                             (return-from ,inner nil))))
           (return-from ,outer ,then-form)))
       ,else-form)))


;; borrowed from https://github.com/mhayashi1120/Emacs-gauche-macros/blob/main/gauche-macros.el
(defmacro cond-list (&rest clauses)
  "Construct a list by conditionally adding entries. Each clause has a test and expressions.
When its test yields true, the result of associated expression is used to construct the resulting list.
When the test yields false, nothing is inserted.

Clause must be either one of the following form:

  (test expr …)

Test is evaluated, and when it is true, expr … are evaluated, and the return value
becomes a part of the result.
If no expr is given, the result of test is used if it is not false.
  (test => proc)

Test is evaluated, and when it is true, proc is called with the value,
and the return value is used to construct the result.
  (test @ expr …)

Like (test expr …), except that the result of the last expr must be a list,
and it is spliced into the resulting list, like unquote-splicing.
  (test => @ proc)

Like (test => proc), except that the result of proc must be a list,
and it is spliced into the resulting list, like unquote-splicing.
  (let ((alist '((x 3) (y -1) (z 6))))
   (cond-list ((assoc 'x alist) 'have-x)
              ((assoc 'w alist) 'have-w)
              ((assoc 'z alist) => cadr)))
    ⇒ (have-x 6)

  (let ((x 2) (y #f) (z 5))
    (cond-list (x @ `(:x ,x))
               (y @ `(:y ,y))
               (z @ `(:z ,z))))
    ⇒ (:x 2 :z 5)
"
  (reduce
   (lambda (clause accum)
     (when (null clause)
       (error "No matching clause ~S" clause))
     (let ((test-result (make-symbol "result"))
           (test (car clause))
           (body (cdr clause)))
       `(let ((,test-result ,test))
          (append
           (if ,test-result
               ,(cond
                  ;; (TEST => @ PROC)
                  ((and (eq (car body) '=>)
                        (eq (cadr body) '@))
                   (unless (= (length (cddr body)) 1)
                     (error "Invalid clause ~S" body))
                   (let ((proc (caddr body)))
                     (unless (functionp proc)
                       (error "Form must be a function but ~S" proc))
                     `(funcall ,proc ,test-result)))
                  ;; (TEST => PROC)
                  ((eq (car body) '=>)
                   (unless (= (length (cdr body)) 1)
                     (error "Invalid clause ~s" body))
                   (let ((proc (cadr body)))
                     (unless (functionp proc)
                       (error "Form must be a function but ~S" proc))
                     `(list (funcall ,proc ,test-result))))
                  ;; (TEST @ EXPR ...)
                  ((eq (car body) '@)
                   `(progn ,@(cdr body)))
                  ;; (TEST EXPR ...)
                  (t
                   `(list (progn ,@body))))
               nil)
           ,accum))))
   clauses
   :from-end t
   :initial-value nil))
