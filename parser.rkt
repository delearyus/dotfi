#lang brag
dotfi-program   : NEWLINE* dotfi-stanza (NEWLINE+ dotfi-stanza)* NEWLINE*
dotfi-stanza    : dotfi-header NEWLINE* dotfi-filebody

dotfi-header    : HASH CHAR* NEWLINE
dotfi-filebody  : TRIPLE-QUOTE dotfi-filetype? NEWLINE dotfi-filecontents TRIPLE-QUOTE

dotfi-filetype  : CHAR*
dotfi-filecontents : (dotfi-sexp | CHAR | NEWLINE | HASH)*
dotfi-sexp      : SEXP
