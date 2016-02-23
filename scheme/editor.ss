;;
;; Fl_Highlight_Editor - extensible text editing widget
;; Copyright (c) 2013-2014 Sanel Zukan.
;;
;; This library is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public
;; License as published by the Free Software Foundation; either
;; version 2 of the License, or (at your option) any later version.
;;
;; This library is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
;; Lesser General Public License for more details.
;;
;; You should have received a copy of the GNU Lesser General Public License
;; along with this library. If not, see <http://www.gnu.org/licenses/>.

;;; setup essential editor stuff; called after boot.ss

(require 'utils)
(require 'constants)

;;; globals

(define *editor-buffer-file-name* #f)
(define *editor-current-mode* #f)

;;; hook facility

(define-macro (add-hook! hook func)
  `(set! ,hook
        (reverse ;; reverse it, so oldest functions are called first
         (cons ,func ,hook))))

(define-macro (add-to-list! list elem)
  `(set! ,list
         (cons ,elem ,list)))

(define-macro (add-to-list-once! list elem)
  `(if (null? (filter (lambda (x)
                        (eqv? x ,elem))
                      ,list))
     (set! ,list (cons ,elem ,list))))

(define (editor-run-hook hook-name hook . args)
  (for-each (lambda (func)
              (if (null? args)
                (func)
                (apply func args)))
            hook))

(define (editor-print-hook hook)
  (for-each (lambda (func)
              (println (get-closure-code func)))
            hook))

;; search for a file in *load-path*; returns full path or #f if not found
(define-with-return (editor-find-file file)
  (for-each
    (lambda (path)
      (let ([path (string-append path "/" file)])
        (if (file-exists? path)
          (return path))))
    *load-path*)
  #f)

;; (forward-char n)
(define (forward-char n)
  (goto-char (+ n (point))))

;; (backward-char n)
(define (backward-char n)
  (goto-char (- (point) n)))

;; (buffer-file-name)
(define (buffer-file-name)
  *editor-buffer-file-name*)

;;; (define-mode)

(define (quoted? val)
  (and (pair? val)
       (eq? 'quote (car val))))

(define (syn type content face)
  (vector
   (case type
     [(default) 0]
     [(eol)     1]
     [(block)   2]
     [(regex)   3]
     [(exact)   4]
     [(else
       (error 'syn "Unrecognized context type:" type))])
   content
   face))

(define (define-mode-lowlevel mode doc args)
  (set! *editor-context-table* args))

(define-macro (define-mode mode doc . args)
  `(define-mode-lowlevel ',mode ,doc (list ,@args)))

(define-macro (define-derived-mode mode parent doc . args)
  (let ([var (gensym)])
    `(begin
       (editor-try-load-mode (symbol->string ',parent))
       (let ([,var *editor-context-table*])
         (set! *editor-context-table* (list ,@args))
         (for-each (lambda (x) (add-to-list! *editor-context-table* x))
                   (reverse ,var))))))

(define (editor-try-load-mode mode)
  (if (and *editor-current-mode*
           (string=? *editor-current-mode* mode))
      #t ;; return true so we knows mode is already loaded
      (let1 path (editor-find-file (string-append mode ".ss"))
        (if path
          (begin
            (println "Loading mode " mode)
            (load path)
            ;; returns string (mode-name) so we knows mode is newly loaded
            (set! *editor-current-mode* mode))
          ;; return false if mode wasn't found
          #f))))

;; load given mode by matching against filename
(define-with-return (editor-try-load-mode-by-filename lst filename)
  (for-each
    (lambda (item)
      (let* ([rx     (regex-compile (car item) '(RX_EXTENDED))]
             [match? (and rx (regex-match rx filename))])
        (when match?
          (let* ([mode (cond
                         [(string? (cdr item)) (cdr item)]
                         [(symbol? (cdr item)) (symbol->string (cdr item))]
                         [else
                           (error "Mode name not string or symbol")])]
                 [state (editor-try-load-mode mode)])
            (when state
              (if (eq? state #t)
                (return #t)
                (begin
                  (editor-repaint-context-changed)
                  (editor-repaint-face-changed)

                  ;; now load <mode-name>-hook variable if defined
                  (let* ([mode-hook-str (string-append mode "-hook")]
                         [mode-hook-sym (string->symbol mode-hook-str)])
                    (when (defined? mode-hook-sym)
                      (editor-run-hook mode-hook-str (eval mode-hook-sym))))
                  (return #t))))))))
    lst))

;;; file types

(define *editor-auto-mode-table*
  '(("(\\.[CchH])$" . c-mode)
    ("(\\.[hHcC](pp|PP)|\\.[hc]xx|\.[hc]\\+\\+|\\.CC)$" . c++-mode)
	("(\\.lua)$" . lua-mode)
    ("(\\.py|\\.pyc)$" . python-mode)
    ("(\\.md)$" . markdown-mode)
    ("(\\.fl)$" . fltk-mode)
    ("(\\.ss|\\.scm|\\.scheme)$" . scheme-mode)
    ("(\\.ht|\\.htm|\\.html|\\.xhtml|\\.sgml)$" . html-mode)
    ("([mM]akefile|GNUMakefile|\\.make)$" . make-mode)))

;; FIXME: register 'modes' subfolder; do this better
(add-to-list! *load-path* (string-append (car *load-path*) "/modes"))

(add-hook! *editor-before-loadfile-hook*
  (lambda (f)
    (set! *editor-buffer-file-name* f)
    (editor-try-load-mode-by-filename *editor-auto-mode-table* f)))

(add-hook! *editor-after-loadfile-hook*
  (lambda (f)
    (set-tab-width 4)))

;;; default themes

;(define-theme molokai
;  "Molokai theme sample."
;  (face 'default-face "white" 12 FL_COURIER)
;  (face 'comment-face "blue"  12 FL_COURIER)
;  (face 'keyword-face FL_BLUE 12 FL_COURIER)
;  (face 'macro-face   FL_DARK_CYAN 12 FL_COURIER))

(define (default-theme-lite)
  (editor-set-background-color FL_WHITE)
  (editor-set-cursor-color FL_BLACK)
  (set! *editor-face-table*
    (list
     (vector 'default-face FL_WHITE 12 FL_COURIER)
     (vector 'comment-face FL_BLUE 12 FL_COURIER)
     (vector 'warning-face FL_BLUE 12 FL_COURIER_BOLD)
     (vector 'function-name-face FL_GREEN 12 FL_COURIER)
     (vector 'variable-name-face FL_LIGHT1 12 FL_COURIER)
     (vector 'keyword-face FL_BLUE 12 FL_COURIER)
     (vector 'comment-face FL_BLUE 12 FL_COURIER)
     (vector 'comment-delimiter-face FL_DARK_CYAN 12 FL_COURIER)
     (vector 'type-face FL_DARK_GREEN 12 FL_COURIER)
     (vector 'constant-face FL_DARK_CYAN 12 FL_COURIER)
     (vector 'builtin-face FL_GREEN 12 FL_COURIER)
     (vector 'preprocessor-face FL_DARK_CYAN 12 FL_COURIER)
     (vector 'string-face FL_DARK_RED 12 FL_COURIER)
     (vector 'doc-face FL_DARK_RED 12 FL_COURIER))))

;(define (default-theme-lite)
;  (editor-set-background-color FL_WHITE)
;  (editor-set-cursor-color FL_BLACK)
;  (set! *editor-face-table*
;    (list
;      (vector 'default-face FL_WHITE 12 FL_COURIER)
;      (vector 'comment-face FL_BLUE  12 FL_COURIER)
;      (vector 'keyword-face FL_BLUE  12 FL_COURIER)
;      (vector 'important-face FL_BLUE 12 FL_COURIER_BOLD)
;      (vector 'type-face FL_DARK_GREEN 12 FL_COURIER)
;      (vector 'attribute-face FL_DARK_CYAN 12 FL_COURIER)
;      (vector 'string-face FL_DARK_RED 12 FL_COURIER)
;      (vector 'macro-face  FL_DARK_CYAN 12 FL_COURIER)
;      (vector 'parentheses-face FL_INACTIVE_COLOR 12 FL_COURIER))))

(define (default-theme-dark)
  (editor-set-background-color FL_BLACK)
  (editor-set-cursor-color FL_GREEN)
  (editor-set-cursor-shape 'normal)
  (set! *editor-face-table*
    (list
      (vector 'default-face "#a4a3a3" 12 FL_COURIER)
      (vector 'keyword-face "#d9bd4d" 12 FL_COURIER)
      (vector 'comment-face "#7772d4" 12 FL_COURIER)
      (vector 'macro-face   "#fe8592" 12 FL_COURIER)
      (vector 'important-face "#bd3e3e" 12 FL_COURIER_BOLD)
      (vector 'string-face  "#60ffa6" 12 FL_COURIER))))

;;; theme
(default-theme-lite)
(set-tab-expand #t)
