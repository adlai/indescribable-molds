;; Copyright 2008 Kat Marchan

;; Permission is hereby granted, free of charge, to any person
;; obtaining a copy of this software and associated documentation
;; files (the "Software"), to deal in the Software without
;; restriction, including without limitation the rights to use,
;; copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the
;; Software is furnished to do so, subject to the following
;; conditions:

;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
;; OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
;; OTHER DEALINGS IN THE SOFTWARE.

;; tests/sheeple.lisp
;;
;; Unit tests for src/sheeple.lisp
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(in-package :sheeple-test)

(export 'sheeple-tests)

(def-suite sheeple)
(defun sheeple-tests ()
  (run! 'sheeple))
(def-suite sheep-cloning-tests :in sheeple)
(def-suite sheep-properties-tests :in sheeple)

(in-suite sheep-cloning-tests)
(test clone-basic
  "Basic cloning tests. Confirm the CLONE macro works correctly, and that cyclic hierarchy lists
properly signal SHEEP-HIERARCHY-ERROR."
  (is (eql (car (sheep-direct-parents (clone ()))) (fetch-dolly)))

  (is (= (length (available-properties (clone () ((foo "bar")))))
	 1))

  (let ((obj1 (clone ())))
    (is (eql obj1
	     (car (sheep-direct-parents (clone (obj1)))))))

  (let ((obj1 (clone ()))
	(obj2 (clone ())))
    (add-parent obj1 obj2)
    (is (eql obj1
	     (car (sheep-direct-parents obj2)))))

  (let ((obj (clone () ((foo "bar")))))
    (is (equal "bar" (get-property obj 'foo))))

  (let ((obj (clone () ((foo "bar") (baz "quux")))))
    (is (equal "quux" (get-property obj 'baz))))
  
  (signals sheep-hierarchy-error (let ((obj1 (clone ()))
				       (obj2 (clone ())))
				   (add-parent obj1 obj2)
				   (clone (obj1 obj2))))

  (signals sheep-hierarchy-error (let* ((obj1 (clone ()))
					(obj2 (clone (obj1))))
				    (clone (obj1 obj2)))))

(in-suite sheep-properties-tests)
(test properties-basic
  "Basic property-setting and property-access tests. Ensures they follow spec."
  (let* ((main-sheep (clone ()))
	(child-sheep (clone (main-sheep))))
    (is (eql nil (available-properties main-sheep)))
    (signals unbound-property (get-property main-sheep 'foo))
    (is (eql "bar" 
	     (setf (get-property main-sheep 'foo) "bar")))
    (is (eql t
	     (has-direct-property-p main-sheep 'foo)))
    (is (eql t
	     (has-property-p main-sheep 'foo)))
    (is (eql nil
	     (has-direct-property-p child-sheep 'foo)))
    (is (eql t
	     (has-property-p child-sheep 'foo)))
    (is (eql "bar" (get-property main-sheep 'foo)))
    (is (equal '(foo) (available-properties main-sheep)))
    (is (eql main-sheep (who-sets main-sheep 'foo)))
    (is (eql main-sheep (who-sets child-sheep 'foo)))
    (is (eql t (remove-property main-sheep 'foo)))
    (signals unbound-property (get-property main-sheep 'foo))
    (signals unbound-property (get-property child-sheep 'foo))
    (is (eql nil (remove-property main-sheep 'foo)))))