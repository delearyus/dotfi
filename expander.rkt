#lang br/quicklang

(require racket/cmdline)

(define-macro (dotfi-mb PARSE-TREE)
  #'(#%module-begin
     (main PARSE-TREE)))
(provide (rename-out [dotfi-mb #%module-begin]))

(define (dotfi-program . stanzas) (clean stanzas))
(define (dotfi-stanza . lines) (apply stanza (clean lines)))
(provide dotfi-program dotfi-stanza)

(define (dotfi-header . tokens)
  (convert-path
    (string-trim (string-append* "" tokens) #px"[\\s#]+")))
(define (dotfi-filebody . args) (cadr (clean args)))
(provide dotfi-header dotfi-filebody)

(define-macro (dotfi-filetype ARG ...) #'void) ; dont like this
(define-macro (dotfi-filecontents ARG ...) #'(string-append ARG ...))
(provide dotfi-filetype dotfi-filecontents)

(define-macro (dotfi-sexp SEXP-STR)
  (with-pattern ([SEXP-DATUM (format-datum '~a #'SEXP-STR)])
                #'(eval-in-module theme-path 'SEXP-DATUM)))
(provide dotfi-sexp)

(struct stanza (path contents) #:transparent)

(define (convert-path pathstr)
  (if (string-prefix? pathstr "/")
    pathstr
    (build-path
      (find-system-path 'home-dir)
      pathstr)))

(define (not-newline-or-triple-quote? x)
  (not (or (equal? x "\n") (equal? x "```"))))
(define (clean xs) (filter not-newline-or-triple-quote? xs))

(define (eval-in-module mod-file datum)
  (parameterize ([current-namespace (make-base-namespace)])
    (namespace-require `(file ,mod-file))
    (format "~a" (eval datum))))

; =================================

(define flag-dryrun #f)

(define theme-path
  (command-line
    #:program "./[filename]"
    #:once-each
    [("-d" "--dry-run") 
     "Template files and display without installing"
     (set! flag-dryrun #t)]
    #:args (theme)
    theme))

(define (main program)
  (if flag-dryrun
      (print-stanzas theme-path program)
      (install-stanzas theme-path program)))


(define (print-stanzas theme-path stanzas)
  (void (map print-stanza stanzas)))
(define (print-stanza stanza) 
  (displayln (stanza-path stanza))
  (displayln "------------")
  (display (stanza-contents stanza))
  (displayln "------------\n"))

(define (install-stanzas theme-path stanzas)
  (void (map install-stanza stanzas)))
(define (install-stanza stanza)
  (let ([outfile (open-output-file 
                   (stanza-path stanza)
                   #:mode 'binary
                   #:exists 'replace)])
    (display (stanza-contents stanza) outfile)
    (close-output-port outfile)))

