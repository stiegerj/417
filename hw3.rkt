#lang racket

(provide diff)

; operator
(define (get-op E) (car E))

(define (make-sum E) (cons '+ E))
(define (make-prod E) (cons '* E))
(define (make-exp E) (cons 'expt E))


; differentiate (+ x1 x2 ...)
(define (diff-sum x E)
  (map (lambda (y) (diff x y)) E)) 
  
;(* x y)
(define (diff-product x E)
  (make-sum (list (make-prod (list (caddr E) (diff x (cadr E)))) (make-prod (list (cadr E) (diff x (caddr E)))))))

;(expt x y)
(define (diff-expt x E)
  (if (equal? x (cadr E)) 
      (make-prod (list (caddr E) (make-exp (list x (- (caddr E) 1)))))
      E))
                       

;; Dispatch Table of supported operators.
 (define diff-dispatch
   (list (list '+ diff-sum)
         (list '* diff-product)
         (list 'expt diff-expt)
         ))

;; Differentiate expression E w.r.t. x.
(define (diff x E)
  (cond ((number? E) '0)
        ((equal? x E) '1)
        ((equal? E '+) E)
        ((not (pair? E)) 0)
        (else ((cadr (assoc (get-op E) diff-dispatch)) x E))))