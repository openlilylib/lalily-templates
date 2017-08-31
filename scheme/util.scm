;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;%                                                                             %
;% This file is part of openLilyLib,                                           %
;%                      ===========                                            %
;% the community library project for GNU LilyPond                              %
;% (https://github.com/openlilylib)                                            %
;%              -----------                                                    %
;%                                                                             %
;% Library: lalily-templates                                                   %
;%          ================                                                   %
;%                                                                             %
;% openLilyLib is free software: you can redistribute it and/or modify         %
;% it under the terms of the GNU General Public License as published by        %
;% the Free Software Foundation, either version 3 of the License, or           %
;% (at your option) any later version.                                         %
;%                                                                             %
;% openLilyLib is distributed in the hope that it will be useful,              %
;% but WITHOUT ANY WARRANTY; without even the implied warranty of              %
;% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               %
;% GNU General Public License for more details.                                %
;%                                                                             %
;% You should have received a copy of the GNU General Public License           %
;% along with openLilyLib. If not, see <http://www.gnu.org/licenses/>.         %
;%                                                                             %
;% openLilyLib is maintained by Urs Liska, ul@openlilylib.org                  %
;% lalily-templates is maintained by Jan-Peter Voigt, jp.voigt@gmx.de          %
;% and others.                                                                 %
;%       Copyright Jan-Peter Voigt, Urs Liska, 2017                            %
;%                                                                             %
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

(define-module (lalily-templates scheme util))

(use-modules
 (lily)
 (ice-9 regex)
 (srfi srfi-1)
 (lalily-templates scheme store))

(define-public (format-alist l . ind)
  "create string from (a-)list for pretty printing
example: (format-alist '((a . 1)(b . 2)))
==>  a=1
     b=2"
  (let ((i (if (> (length ind) 1) (cadr ind) 0))
        (istr (if (> (length ind) 0) (car ind) " ")))
    (define (indsp n)(if (> n 0) (string-append istr (indsp (- n 1))) ""))
    (cond
     ((and (pair? l)(markup? (cdr l)))(format "~A~A=~A~&" (indsp (+ i 1)) (car l) (markup->string (cdr l))))
     ((and (list? l)(not (dotted-list? l))(any pair? l))
      (let ((ret ""))
        (for-each (lambda (e)
                    (set! ret (string-append ret (format-alist e istr (+ i 1)))))
          l)
        ret))
     ((pair? l)(let ((k (car l))(v (cdr l)))(format "~A~A=~A~&" (indsp (+ i 1)) k v)))
     (else (format "~A~A~&" (indsp i) l)))
    ))


(define-public (set-book-headers! book header)
  (let ((bookhead (ly:book-header book)))
    (if (or (not bookhead)(list? bookhead))(begin (set! bookhead (make-module)) (ly:book-set-header! book bookhead)))
    (if (not (list? header))
        (set! header (assoc-get '_header (get-music-folder-options) '())))
    (for-each (lambda (p)
                (if (pair? p)
                    (let ((key (car p))
                          (val (cdr p)))
                      (module-define! bookhead key val)))) header)
    ))
(define-public (set-score-headers! score header)
  (let ((scorehead (ly:score-header score)))
    (if (or (not scorehead)(list? scorehead))(let ((mod (make-module))) (set! scorehead mod) (ly:score-set-header! score scorehead)))
    (if (not (list? header)) (set! header (assoc-get '_header (get-music-folder-options
                                                              (if (ly:input-location? header) header #f)) '())))
    (for-each (lambda (p)
                (if (pair? p)
                    (let ((key (car p))
                          (val (cdr p)))
                      (module-define! scorehead key val)))) header)
    ))

(define-public (lalily-test-location? parser location)
  (let ((outname (ly:parser-output-name parser))
        (locname (car (ly:input-file-line-char-column location))))
    (regexp-match? (string-match (format "^(.*/)?~A\\.i?ly$" outname) locname))
    ))

