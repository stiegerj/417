;; CSE413 16au, Programming Languages, Homework 5

#lang racket
(provide (all-defined-out)) ;; so we can put tests in a second file

;; definition of structures for MUPL programs - Do NOT change
(struct var  (string) #:transparent)  ;; a variable, e.g., (var "foo")
(struct int  (num)    #:transparent)  ;; a constant number, e.g., (int 17)
(struct add  (e1 e2)  #:transparent)  ;; add two expressions
(struct isgreater (e1 e2)    #:transparent) ;; if e1 > e2 then 1 else 0
(struct ifnz (e1 e2 e3) #:transparent) ;; if not zero e1 then e2 else e3
(struct fun  (nameopt formal body) #:transparent) ;; a recursive(?) 1-argument function
(struct call (funexp actual)       #:transparent) ;; function call
(struct mlet (var e body) #:transparent) ;; a local binding (let var = e in body) 
(struct apair   (e1 e2) #:transparent) ;; make a new pair
(struct first   (e)     #:transparent) ;; get first part of a pair
(struct second  (e)     #:transparent) ;; get second part of a pair
(struct munit   ()      #:transparent) ;; unit value -- good for ending a list
(struct ismunit (e)     #:transparent) ;; if e1 is unit then 1 else 0

;; a closure is not in "source" programs; it is what functions evaluate to
(struct closure (env fun) #:transparent) 

;; Problem 1
(define (racketlist->mupllist lst)
  (if (equal? lst '())
      (munit)
      (apair (car lst) (racketlist->mupllist (cdr lst)))))

;; Problem 2;
(define (mupllist->racketlist muplst)
  (if (munit? muplst)
      '()
      (cons (apair-e1 muplst) (mupllist->racketlist (apair-e2 muplst)))))

;; lookup a variable in an environment
;; Do NOT change this function
(define (envlookup env str)
  (cond [(null? env) (error "unbound variable during evaluation" str)]
        [(equal? (car (car env)) str) (cdr (car env))]
        [#t (envlookup (cdr env) str)]))

;; Do NOT change the two cases given to you.  
;; DO add more cases for other kinds of MUPL expressions.
;; We will test eval-under-env by calling it directly even though
;; "in real life" it would be a helper function of eval-exp.
(define (eval-under-env e env)
  (cond [(int? e) e]
        [(closure? e) e]
        [(munit? e) e]
        [(pair? e) e]
        [(var? e) 
         (envlookup env (var-string e))]
        [(add? e) 
         (let ([v1 (eval-under-env (add-e1 e) env)]
               [v2 (eval-under-env (add-e2 e) env)])
           (if (and (int? v1)
                    (int? v2))
               (int (+ (int-num v1) 
                       (int-num v2)))
               (error "MUPL addition applied to non-number")))]
         [(isgreater? e) 
         (let ([v1 (eval-under-env (isgreater-e1 e) env)]
               [v2 (eval-under-env (isgreater-e2 e) env)])
           (if (and (int? v1)
                    (int? v2))
               (if (> (int-num v1) (int-num v2)) (int 1) (int 0))
               (error "MUPL comparison applied to non-number")))]
         [(ifnz? e) 
         (let ([v1 (eval-under-env (ifnz-e1 e) env)]
               [v2 (eval-under-env (ifnz-e2 e) env)]
               [v3 (eval-under-env (ifnz-e3 e) env)])
           (if (int? v1)
               (if (equal? (int-num v1) 0) (eval-under-env v3 env) (eval-under-env v2 env))
               (error "MUPL comparison applied to non-number")))]
         [(fun? e) (closure env e)]
         [(mlet? e) (eval-under-env (mlet-body e) (cons (cons (mlet-var e) (eval-under-env (mlet-e e) env)) env))]
         [(call? e) 
         (let ([v1 (eval-under-env (call-funexp e) env)]
               [v2 (eval-under-env (call-actual e) env)])
           (if (closure? v1)
               (if (equal? "" (fun-nameopt (closure-fun v1)))
                   (eval-under-env (fun-body (closure-fun v1)) (cons (cons (fun-formal (closure-fun v1)) v2) (closure-env v1)))
                   (eval-under-env (fun-body (closure-fun v1)) (cons (cons (fun-nameopt (closure-fun v1)) v1) (cons (cons (fun-formal (closure-fun v1)) v2) (closure-env v1)))))
               (error "MUPL call applied to non-closure")))]
         [(apair? e) (apair (eval-under-env (apair-e1 e) env) (eval-under-env (apair-e2 e) env))]
         [(first? e) (if (apair? (eval-under-env (first-e e) env)) (apair-e1 (eval-under-env (first-e e) env)) (error "MUPL first applied to nonpair"))]
         [(second? e) (if (apair? (eval-under-env (second-e e) env)) (apair-e2 (eval-under-env (second-e e) env)) (error "MUPL second applied to nonpair"))]
         [(ismunit? e) (if (munit? (eval-under-env (ismunit-e e) env)) (int 1) (int 0))]
        [#t (error (format "bad MUPL expression: ~v" e))]))


;; Do NOT change
(define (eval-exp e)
  (eval-under-env e null))
        
;; Problem 3

; isgreater 0 -> e2 > e1
; is munit 0 -> not munit

(define (ifmunit e1 e2 e3) (ifnz (isgreater (ismunit e1) (int 0)) e2 e3))

(define (mlet* bs e2)
  (if (null? bs)
      e2
      (mlet (car (car bs)) (cdr (car bs))(mlet* (cdr bs) e2))))

(define (ifeq e1 e2 e3 e4)
  (if (and (int? e1) (int? e2))
      (mlet* (list (cons "_x" e1) (cons "_y" e2))
             (ifnz (isgreater (var "_x") (var "_y")) e4 (ifnz (isgreater (var "_y") (var "_x")) e4 e3)))
      (error "MUPL ifeq applied to at least one non-int")))
  

;; Problem 4

;Bind to the Racket variable mupl-filter a mupl function that acts like filter (as we used in
;Racket). Your function should be curried: it should take a mupl function and return a mupl
;function that takes a mupl list and applies the function to every element of the list, returning
;a new mupl list with all the elements for which the function returns a number other than zero
;(causing an error if the function returns a non-number). Recall a mupl list is munit or a pair
;where the second component is a mupl list.

(define cfilter
  (lambda (fun)
    (letrec ((aux (lambda (lst)
                    (if (null? lst)
                        '()
                        (if (equal? (fun (car lst)) 0)
                            (aux (cdr lst))
                            (cons (car lst) (aux (cdr lst))))))))
      aux)))


(define mupl-filter
  (fun "returnouter" "filterfunction"
       (fun "recursiveinner" "givenlst"
            (ifmunit (var "givenlst")
                     (munit)
                     (ifnz (call (var "filterfunction") (first (var "givenlst")))
                           (apair (first (var "givenlst")) (call (var "recursiveinner") (second (var "givenlst"))))
                           (call (var "recursiveinner") (second (var "givenlst"))))))))

(define mupl-all-gt
  (mlet "filter" mupl-filter
        (fun "name" "i" (call (var "filter") (fun "" "x" (isgreater (var "x") (var "i")))))))












