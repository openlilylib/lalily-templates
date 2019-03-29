%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% This file is part of openLilyLib,                                           %
%                      ===========                                            %
% the community library project for GNU LilyPond                              %
% (https://github.com/openlilylib)                                            %
%              -----------                                                    %
%                                                                             %
% Library: lalily-templates                                                   %
%          ================                                                   %
%                                                                             %
% openLilyLib is free software: you can redistribute it and/or modify         %
% it under the terms of the GNU General Public License as published by        %
% the Free Software Foundation, either version 3 of the License, or           %
% (at your option) any later version.                                         %
%                                                                             %
% openLilyLib is distributed in the hope that it will be useful,              %
% but WITHOUT ANY WARRANTY; without even the implied warranty of              %
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               %
% GNU General Public License for more details.                                %
%                                                                             %
% You should have received a copy of the GNU General Public License           %
% along with openLilyLib. If not, see <http://www.gnu.org/licenses/>.         %
%                                                                             %
% openLilyLib is maintained by Urs Liska, ul@openlilylib.org                  %
% lalily-templates is maintained by Jan-Peter Voigt, jp.voigt@gmx.de          %
% and others.                                                                 %
%       Copyright Jan-Peter Voigt, Urs Liska, 2017                            %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\include "oll-core/package.ily"
\include "oll-core/util/include-pattern.ily"
#(load-from-path "lalily-templates/scheme/bootstrap.scm")
\loadPackage edition-engraver
#(use-modules
  (lalily-templates scheme util)
  (srfi srfi-1))

\includePattern "templates" ".*\\.ily"

#(define (add-sco-mup pre-markup score post-markup)
   (begin
    (cond ((markup? pre-markup)
           (begin
            (add-score (list pre-markup))
            (add-music #{ \noPageBreak #})))
      ((markup-list? pre-markup)
       (add-score pre-markup))
      )
    (add-score score)
    (cond ((markup? post-markup)
           (begin
            (add-music #{ \noPageBreak #})
            (add-score (list post-markup))))
      ((markup-list? post-markup)
       (add-score post-markup))
      )
    ))

% command to create one score based on the current "music folder"
lalilyCreate =
#(define-void-function ()()
   (let ((score #{
     \score {
       \createScore #'()
       \header { }
     }
           #})
         (bookpart #{
           \bookpart {
             \paper {
               $(get-music-folder-paper)
             }
             \header { }
           }
           #})
         (pre-markup (ly:assoc-get 'pre-markup (get-default-options (get-music-folder)) #f #f))
         (post-markup (ly:assoc-get 'post-markup (get-default-options (get-music-folder)) #f #f))
         (headers (ly:assoc-get '_header (get-music-folder-options) '()))
         (edition-id (ly:assoc-get '_edition-id (get-music-folder-options) (get-music-folder)))
         (copyright (get-registry-val '(lalily header copyright) #f))
         (dolayout (not (eq? (get-registry-val lalily:create #t) 'NoLayout)))
         (domidi (not (eq? (get-registry-val lalily:create #t) 'NoMidi)))
         )
     (if dolayout
         (begin
          (ly:score-add-output-def! score #{
            \layout {
              $(get-music-folder-layout)
              \context {
                \Score
                "lalily:music-folder" = $(get-music-folder)
                edition-id = $(if (list? edition-id) edition-id '())
              }
              \context {
                \Voice
              }
            }
            #})
          ))
     (if domidi (ly:score-add-output-def! score (get-music-folder-midi)))
     (if (and copyright (not (ly:assoc-get 'copyright headers)))
         (set! headers (assoc-set! headers 'copyright copyright)))
     (set-book-headers! bookpart headers)
     (log-music-folder)
     (ly:parser-define! '$current-bookpart bookpart)
     (add-sco-mup pre-markup score post-markup)
     (collect-bookpart-for-book bookpart)
     (write-lalily-log-file)
     ))

lalilyTest =
#(define-void-function ()()
   (if ((get-registry-val lalily:test-predicate lalily-test-location?) (*parser*) (*location*))
       (lalilyCreate)
       ))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create one score based on current music folder
lalilyScore =
#(define-void-function (options)(list?)
   (let* ((domidi (ly:assoc-get 'midi options #f #f))
          (extra (ly:assoc-get 'extra options '() #f))
          (addopt (ly:assoc-get 'options options '() #f))
          (score #{
            \score {
              \createScoreWithOptions #extra #addopt
              \layout {
                $(get-music-folder-layout)
                \context {
                  \Score
                  "lalily:music-folder" = $(get-music-folder)
                }
              }
              \header { }
            }
            #})
          (headers (ly:assoc-get '_header (get-music-folder-options) '()))
          (clear-headers (ly:assoc-get '_clear-headers options '() #f))
          (pre-markup (ly:assoc-get '_pre-markup (get-default-options (get-music-folder)) #f #f))
          (post-markup (ly:assoc-get '_post-markup (get-default-options (get-music-folder)) #f #f))
          )
     (set! headers (assoc-set-all! (map (lambda (p) `(,(car p) . #f)) clear-headers) headers))
     (set-score-headers! score headers)
     (log-music-folder)
     (if domidi (ly:score-add-output-def! score (get-music-folder-midi)))
     (let ((title (get-music-folder-header-field 'toc-label)))
       (if (not (markup? title))(set! title (get-music-folder-header-field 'title)))
       (if (markup? title) (add-music #{ \tocItem $title #}))) ; tocPart
     (add-sco-mup pre-markup score post-markup)
     ))

% create one bookpart containing named music folders
lalilyBookpart =
#(define-void-function (options)(list?)
   (let* ((options (assoc-set-all! (get-music-folder-options) options))
          (cbp (ly:parser-lookup '$current-bookpart))
          (keys (ly:assoc-get 'keys options (ly:assoc-get 'keys (get-music-folder-options)) #f))
          (mus (ly:assoc-get 'music options
                 (let ((p (get-music-folder)))
                   (map
                    (lambda (k) (create-music-path #f (list k)))
                    (if (and (list? keys)(> (length keys) 0))
                        keys
                        (let* ((keys (get-music-keys p))
                               (kformat (lambda (k) (if (number? k) (format "~5,'0d" k)(format "~A" k))))
                               (sfun (lambda (k1 k2) (string<? (kformat k1) (kformat k2)))))
                          (sort keys sfun)) )))
                 #f))
          (print-all-headers (ly:assoc-get 'print-all-headers options (or (list? keys)(list? mus)) #f))
          (bookpart #{
            \bookpart {
              \paper {
                $(get-music-folder-paper)
                print-all-headers = $print-all-headers
              }
              \header { }
            }
            #})
          (doScore (ly:music-function-extract lalilyScore))
          (doPart (ly:assoc-get 'toc-part options #f #f))
          (headers (ly:assoc-get '_header (get-music-folder-options) '()))
          )
     (set-book-headers! bookpart headers)
     (log-music-folder)
     (ly:parser-define! '$current-bookpart bookpart)

     (let ((title (get-music-folder-header-field 'toc-label)))
       (if (not (markup? title))(set! title (get-music-folder-header-field 'title)))
       (if (markup? title)
           (if doPart (add-music #{ \tocItem $title #}) ; tocPart
               (add-music #{ \tocItem $title #})))) ; tocCollection

     (if print-all-headers (set! options (assoc-set! options 'clear-headers headers)))
     (for-each
      (lambda (music)
        (cond ((eq? (last music) 'PAGE-BREAK!)
               (add-music #{ \pageBreak #}))
          ((eq? (last music) 'PAGE-TURN!)
           (add-music #{ \pageTurn #}))
          ((eq? (last music) 'NO-PAGE-BREAK!)
           (add-music #{ \noPageBreak #}))
          ((eq? (last music) 'NO-PAGE-TURN!)
           (add-music #{ \noPageTurn #}))
          ((and (list? (last music))(eq? (car (last music)) 'MARKUP))
           (let* ((ctx (get-music-folder))
                  (alist (cdr (last music)))
                  (stl (ly:assoc-get 'style alist #f #t))
                  (mkey (ly:assoc-get 'key alist #f #t))
                  (music (append (reverse (cdr (reverse music))) (list mkey)))
                  (dopre (ly:assoc-get 'pre-markup alist #f #f))
                  (dopost (ly:assoc-get 'post-markup alist #f #f))
                  (opts (get-default-options music))
                  (header (ly:assoc-get 'header opts))
                  (text (ly:assoc-get 'text alist "" #f))
                  (pre-markup (if dopre (ly:assoc-get 'pre-markup opts #f #f) #f))
                  (post-markup (if dopre (ly:assoc-get 'post-markup opts #f #f) #f))
                  )
             (cond ((markup? pre-markup)
                    (begin
                     (add-score (list pre-markup))
                     (add-music #{ \noPageBreak #})))
               ((markup-list? pre-markup)
                (add-score pre-markup))
               )
             (add-score #{
               \markuplist {
                 \with-props #(append
                               (map (lambda (p)
                                      (cons (string->symbol (format "header:~A" (car p)))
                                        (cdr p))) header)
                               (map (lambda (p)
                                      (cons (string->symbol (format "lalily:~A" (car p)))
                                        (cdr p))) alist)
                               )
                 \style #stl $text
               } #})
             (cond ((markup? post-markup)
                    (begin
                     (add-music #{ \noPageBreak #})
                     (add-score (list post-markup))))
               ((markup-list? post-markup)
                (add-score post-markup))
               )
             ))
          ((and (list? (last music))(eq? (car (last music)) 'MARKUPLIST))
           (let* ((ctx (get-music-folder))
                  (muslist (cdr (last music)))
                  (list-style (if (not (pair? (car muslist)))
                                  (let ((sym (car muslist)))
                                    (set! muslist (cdr muslist))
                                    sym) #f))
                  (muplist
                   (map
                    (lambda (mus)
                      (let* (
                              (alist (cdr mus))
                              (stl (ly:assoc-get 'style alist #f #t))
                              (mkey (ly:assoc-get 'key alist #f #t))
                              (music (append (reverse (cdr (reverse music))) (list mkey)))
                              (dopre (ly:assoc-get 'pre-markup alist #f #f))
                              (dopost (ly:assoc-get 'post-markup alist #f #f))
                              (opts (get-default-options music))
                              (header (ly:assoc-get 'header opts))
                              (text (ly:assoc-get 'text alist "" #f))
                              (pre-markup (if dopre (ly:assoc-get 'pre-markup opts #f #f) #f))
                              (post-markup (if dopre (ly:assoc-get 'post-markup opts #f #f) #f))
                              )
                        (if (list? header)
                            #{
                              \markup {
                                \with-props #(map (lambda (p)
                                                    (cons (string->symbol (format "header:~A" (car p)))
                                                      (cdr p))) header)
                                \style #stl $text
                              }
                            #}
                            #{ \markup \style #stl $text #})
                        )) muslist)))
             (if list-style
                 (add-score
                  (cond
                   ((symbol? list-style) (list #{ \markup { \style #list-style \left-column $muplist } #}))
                   (else (list #{ \markup { \left-column $muplist } #}))
                   ))
                 (add-score muplist))
             ))

          (else (let ((ctx (get-music-folder)))
                  (set-music-folder! music)
                  (doScore options)
                  (set-music-folder! ctx))))
        ) mus)

     (let ((book (ly:parser-lookup '$current-book)))
       (if book
           (ly:book-add-bookpart! book bookpart)
           (collect-bookpart-for-book bookpart)))
     (ly:parser-define! '$current-bookpart cbp)
     ))

% test versions of above commands, executed only, if test predicate is met
% default: name of location equals name of parser output
lalilyTestScore =
#(define-void-function (options)(list?)
   (if ((get-registry-val lalily:test-predicate lalily-test-location?) (*parser*) (*location*))
       (begin
        ((ly:music-function-extract lalilyScore)  options)
        (write-lalily-log-file)
        ))
   )
lalilyTestBookpart =
#(define-void-function (options)(list?)
   (if ((get-registry-val lalily:test-predicate lalily-test-location?) (*parser*) (*location*))
       (begin
        ((ly:music-function-extract lalilyBookpart)  options)
        (write-lalily-log-file)
        ))
   )

