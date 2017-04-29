#lang racket
(provide red-blue)
(provide take)
(provide combm)
(provide nats)
(provide powers-of-two)

;; Problem 1 - red/blue string stream
(define red-blue
  (letrec ([r (lambda () (cons "red" (lambda () (b))))]
           [b (lambda () (cons "blue" (lambda () (r))))]
           )
    (lambda() (r))))

;; Problem 2 - retrieve first n values from stream st
(define (take st n)
  (cond ([= n 1] (list (car (st))))
        ([= n 0] '())
        (else
      (append (list (car (st))) (take (cdr (st)) (- n 1))))))

;; Problem 3 - Return n choose k, storing values in a memoization table
;; in case the same (n choose k) question is asked again
(define combm
  (letrec((memo null)
          (fact (lambda (x) (if (or (= x 1) (= x 0)) 1 (* x (fact (- x 1))))))
          (f (lambda (n k)
               (let ((ans (assoc (cons n k) memo)))
                 (if ans
                     (cdr ans)
                     (let ((new-ans (/ (fact n) (* (fact k) (fact (- n k))))))
                       (begin
                         (set! memo (cons (cons (cons n k) new-ans) memo))
                         new-ans))))))) f))



;; another stream to test take
(define nats
  (letrec ((f (lambda (x) (cons x (lambda () (f (+ x 1)))))))
    (lambda () (f 1))))

;; yet another stream to test take
(define powers-of-two
  (letrec ((f (lambda (x) (cons x (lambda () (f (* x 2)))))))
    (lambda () (f 2))))    