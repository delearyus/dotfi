#lang br/quicklang
(require brag/support)

(define (make-tokenizer port)
  (port-count-lines! port)
  (define (next-token)
    (define dotfi-lexer
      (lexer
       ["```" (token 'TRIPLE-QUOTE lexeme)]
       [(from/to "⯁{" "}")
        (token 'SEXP (trim-ends "⯁{" lexeme "}"))]
       ["\n" (token 'NEWLINE lexeme
                    #:position (pos lexeme-start)
                    #:line (line lexeme-start)
                    #:column (col lexeme-start)
                    #:span (- (pos lexeme-end)
                              (pos lexeme-start)))]
       ["#"  (token 'HASH lexeme)]
       [(repetition 0 +inf.0 (char-complement (union "`" "⯁" "\n" "#"))) (token 'CHAR lexeme)]
       [any-char (token 'CHAR lexeme)]))
    (dotfi-lexer port))
  next-token)
(provide make-tokenizer)
